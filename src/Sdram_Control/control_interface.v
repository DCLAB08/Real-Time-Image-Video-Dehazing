module control_interface(
        CLK,
        RESET_N,
        CMD,     
        ADDR,
        REF_ACK,
        //INIT_ACK
        CM_ACK,
        NOP,
        READA,
        WRITEA,
        REFRESH,
        PRECHARGE,
        LOAD_MODE,
        SADDR,
        REF_REQ,
        INIT_REQ,
        CMD_ACK
        );

`include "Sdram_Params.h"

// ---------------------------------------------------------------------------
// PORT declarations
input                           CLK;          // System Clock
input                           RESET_N;      // System Reset
input   [2:0]                   CMD;          // Command input
input   [`ASIZE-1:0]            ADDR;         // Address
input                           REF_ACK;      // Refresh request acknowledge
//input                           INIT_ACK;     // Initial request acknowledge
input                           CM_ACK;       // Command acknowledge
output reg                      NOP;          // Decoded NOP command
output reg                      READA;        // Decoded READA command
output reg                      WRITEA;       // Decoded WRITEA command
output reg                      REFRESH;      // Decoded REFRESH command
output reg                      PRECHARGE;    // Decoded PRECHARGE command
output reg                      LOAD_MODE;    // Decoded LOAD_MODE command
output reg  [`ASIZE-1:0]        SADDR;        // Registered version of ADDR
output reg                      REF_REQ;      // Hidden refresh request
output reg                      INIT_REQ;     // Hidden initial request
output reg                      CMD_ACK;      // Command acknowledge

// ---------------------------------------------------------------------------
// Signals declarations
reg     [15:0]                  timer;
reg     [15:0]                  init_timer;

// Command decode and ADDR register
always @(posedge CLK or negedge RESET_N) begin
    if (!RESET_N) begin
        SADDR   <= 0;
        NOP     <= 0;
        READA   <= 0;
        WRITEA  <= 0;
    end 
    else begin
        SADDR   <= ADDR;        // alignment with the command   

        if (CMD == 3'b000)      // NOP command
            NOP <= 1;
        else
            NOP <= 0;
                
        if (CMD == 3'b001)      // READA command
            READA <= 1;
        else
            READA <= 0;
         
        if (CMD == 3'b010)      // WRITEA command
            WRITEA <= 1;
        else
            WRITEA <= 0;
                        
    end
end


//  Generate CMD_ACK
always @(posedge CLK or negedge RESET_N) begin
    if (!RESET_N)
        CMD_ACK <= 0;
    else if (CM_ACK && (!CMD_ACK)) //CMD_ACK is a one cycle pulse
        CMD_ACK <= 1;
    else
        CMD_ACK <= 0;
end


// refresh timer
always @(posedge CLK or negedge RESET_N) begin
    if (!RESET_N) begin
        timer    <= 0;
        REF_REQ  <= 0;
    end        
    else begin
        if (REF_ACK) begin
            timer   <= REF_PER; //0.01us*768 = 7.68 < 7.8125
            REF_REQ	<= 0; //We are in refresh mode, pull up until the timer counts down to 0
        end
        else if (INIT_REQ) begin
            timer   <= REF_PER + 200;
            REF_REQ	<= 0;
        end
        else
        	timer <= timer - 1'b1;
        if (timer==0)
            REF_REQ    <= 1;
    end
end


// initial timer
always @(posedge CLK or negedge RESET_N) begin
    if (!RESET_N) begin
        init_timer <= 0;
        REFRESH    <= 0;
        PRECHARGE  <= 0; 
        LOAD_MODE  <= 0;
        INIT_REQ   <= 0;
    end        
    else begin
        if (init_timer < (INIT_PER + 201))
            init_timer  <= init_timer + 1;

        if (init_timer < INIT_PER) begin
            REFRESH     <= 0;
            PRECHARGE   <= 0;
            LOAD_MODE   <= 0;
            INIT_REQ    <= 1; //waitng for precharge
        end
        else if(init_timer == (INIT_PER + 20)) begin
            REFRESH     <= 0;
            PRECHARGE   <= 1;
            LOAD_MODE   <= 0;
            INIT_REQ    <= 0;
        end
        else if((init_timer == (INIT_PER + 40))   ||
                (init_timer == (INIT_PER + 60))   ||
                (init_timer == (INIT_PER + 80))   ||
                (init_timer == (INIT_PER + 100))  ||
                (init_timer == (INIT_PER + 120))  ||
                (init_timer == (INIT_PER + 140))  ||
                (init_timer == (INIT_PER + 160))  ||
                (init_timer == (INIT_PER + 180))  )
                begin
                    REFRESH     <= 1;
                    PRECHARGE   <= 0;
                    LOAD_MODE   <= 0;
                    INIT_REQ    <= 0;
                end
        else if(init_timer == (INIT_PER + 200)) begin
            REFRESH     <= 0;
            PRECHARGE   <= 0;
            LOAD_MODE   <= 1;
            INIT_REQ    <= 0;
        end
        else begin
            REFRESH     <= 0;
            PRECHARGE   <= 0;
            LOAD_MODE   <= 0;
            INIT_REQ    <= 0;
        end
    end
end

endmodule