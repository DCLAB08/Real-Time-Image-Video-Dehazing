module command(
        CLK,
        RESET_N,
        SADDR,
        NOP,
        READA,
        WRITEA,
        REFRESH,
        PRECHARGE,
        LOAD_MODE,
        REF_REQ,
        INIT_REQ,
        PM_STOP,
        PM_DONE,
        REF_ACK,
        CM_ACK,
        OE,
        SA,
        BA,
        CS_N,
        CKE,
        RAS_N,
        CAS_N,
        WE_N
        );

`include        "Sdram_Params.h"
// ---------------------------------------------------------------------------
// PORT declarations
input                           CLK;                    // System Clock
input                           RESET_N;                // System Reset
input   [`ASIZE-1:0]            SADDR;                  // Address
input                           NOP;                    // Decoded NOP command
input                           READA;                  // Decoded READA command
input                           WRITEA;                 // Decoded WRITEA command
input                           REFRESH;                // Decoded REFRESH command
input                           PRECHARGE;              // Decoded PRECHARGE command
input                           LOAD_MODE;              // Decoded LOAD_MODE command
input                           REF_REQ;                // Hidden refresh request
input                           INIT_REQ;               // Hidden initial request
input                           PM_STOP;                // Page mode stop
input                           PM_DONE;                // Page mode done
output reg                      REF_ACK;                // Refresh request acknowledge
output reg                      CM_ACK;                 // Command acknowledge
output reg                      OE;                     // OE signal for data path module
output reg  [11:0]              SA;                     // SDRAM address
output reg  [1:0]               BA;                     // SDRAM bank address
output reg  [1:0]               CS_N;                   // SDRAM chip selects
output reg                      CKE;                    // SDRAM clock enable
output reg                      RAS_N;                  // SDRAM RAS
output reg                      CAS_N;                  // SDRAM CAS
output reg                      WE_N;                   // SDRAM WE_N

            
// ---------------------------------------------------------------------------
// Signals declarations
reg                             do_reada;
reg                             do_writea;
reg                             do_refresh;
reg                             do_precharge;
reg                             do_load_mode;
reg                             do_initial;
reg                             command_done; //processing
reg     [7:0]                   command_delay;
reg     [1:0]                   rw_shift;
//reg                             do_act;
reg                             rw_flag;
reg                             do_rw;
reg     [6:0]                   oe_shift;
reg                             oe1;
reg                             oe2;
reg                             oe3;
reg                             oe4;
reg     [3:0]                   rp_shift;
reg                             rp_done;
reg                             ex_read;
reg                             ex_write;

wire    [`ROWSIZE - 1:0]        rowaddr;
wire    [`COLSIZE - 1:0]        coladdr;
wire    [`BANKSIZE - 1:0]       bankaddr;

assign   rowaddr   = SADDR[`ROWSTART  + `ROWSIZE - 1: `ROWSTART];          // assignment of the row address bits from SADDR
assign   coladdr   = SADDR[`COLSTART  + `COLSIZE - 1: `COLSTART];          // assignment of the column address bits
assign   bankaddr  = SADDR[`BANKSTART + `BANKSIZE- 1: `BANKSTART];         // assignment of the bank address bits



// This always block monitors the individual command lines and issues a command
// to the next stage if there currently another command already running.
//
always @(posedge CLK or negedge RESET_N) begin
    if (!RESET_N)  begin
        do_reada        <= 0;
        do_writea       <= 0;
        do_refresh      <= 0;
        do_precharge    <= 0;
        do_load_mode    <= 0;
        do_initial      <= 0;
        command_done    <= 0;
        command_delay   <= 0;
        rw_flag         <= 0;
        rp_shift        <= 0;
        rp_done         <= 0;
        ex_read	        <= 0;
        ex_write        <= 0;
    end
    else begin
        if(INIT_REQ) begin            // Issue the appropriate command if the sdram is not currently busy
            do_reada        <= 0;
            do_writea       <= 0;
            do_refresh      <= 0;
            do_precharge    <= 0;
            do_load_mode    <= 0;
            do_initial      <= 1;
            command_done    <= 0;
            command_delay   <= 0;
            rw_flag         <= 0;
            rp_shift        <= 0;
            rp_done         <= 0;
            ex_read	        <= 0;
            ex_write        <= 0;
        end
        else begin
            do_initial      <= 0;

            if ((REF_REQ || REFRESH) && (!command_done) && (!do_refresh) && (!rp_done) && (!do_reada) && (!do_writea))   // Refresh      
                do_refresh <= 1;         
            else
                do_refresh <= 0;

            if (READA && (!command_done) && (!do_reada) && (!rp_done) && (!REF_REQ)) begin   // READA
                do_reada <= 1;
                ex_read  <= 1;
            end
            else
                do_reada <= 0;
                
            if (WRITEA && (!command_done) && (!do_writea) && (!rp_done) && (!REF_REQ)) begin// WRITEA
                do_writea <= 1;
                ex_write  <= 1;
            end
            else
                do_writea <= 0;

            if (PRECHARGE && (!command_done) && (!do_precharge))                              // PRECHARGE
                do_precharge <= 1;
            else
                do_precharge <= 0;
 
            if (LOAD_MODE && (!command_done) && (!do_load_mode))                              // LOADMODE
                do_load_mode <= 1;
            else
                do_load_mode <= 0;
                                               
// set command_delay shift register and command_done flag
// The command delay shift register is a timer that is used to ensure that
// the SDRAM devices have had sufficient time to finish the last command.

            if ((do_refresh) || (do_reada) || (do_writea) || (do_precharge) || (do_load_mode)) begin
                command_delay <= 8'b11111111;  //delay 8 cycles
                command_done  <= 1;
                rw_flag       <= do_reada;                                                  
            end 
            else begin
                command_done  <= command_delay[0];                // the command_delay shift operation
                command_delay <= (command_delay>>1);
            end 
                
 
 // start additional timer that is used for the refresh, writea, reada commands               
            if ((!command_delay[0]) && command_done) begin
                rp_shift <= 4'b1111;
                rp_done  <= 1;
            end
            else begin
                if(SC_PM == 0) begin
                    rp_shift    <= (rp_shift>>1);
                    rp_done     <= rp_shift[0];
                end
                else begin
                    if( (ex_read == 0) && (ex_write == 0) ) begin
                        rp_shift	<= (rp_shift>>1);
                        rp_done		<= rp_shift[0];
                    end
                    else if(PM_STOP) begin
                        rp_shift    <= (rp_shift>>1);
                        rp_done     <= rp_shift[0];
                        ex_read	    <= 1'b0;
                        ex_write    <= 1'b0;
                    end
                end
            end
        end
    end
end


// logic that generates the OE signal for the data path module
// For normal burst write he duration of OE is dependent on the configured burst length.
// For page mode accesses(SC_PM=1) the OE signal is turned on at the start of the write command
// and is left on until a PRECHARGE(page burst terminate) is detected.
//
always @(posedge CLK or negedge RESET_N) begin
        if (!RESET_N) begin
            oe_shift <= 0;
            oe1      <= 0;
            oe2      <= 0;
            OE       <= 0;
        end
        else if (SC_PM == 0) begin
            if (do_writea == 1) begin
                if (SC_BL == 1)                       //  Set the shift register to the appropriate
                    oe_shift <= 0;                // value based on burst length.
                else if (SC_BL == 2)
                    oe_shift <= 1;
                else if (SC_BL == 4)
                    oe_shift <= 7;
                else if (SC_BL == 8)
                    oe_shift <= 127;
                oe1 <= 1;
            end
            else begin
                oe_shift <= (oe_shift>>1);
                oe1  <= oe_shift[0];
                oe2  <= oe1;
                oe3  <= oe2;
                oe4  <= oe3;
                if (SC_RCD == 2)
                    OE <= oe3;
                else
                    OE <= oe4;
            end
        end
        else begin
            if (do_writea)                                    // OE generation for page mode accesses
                oe4   <= 1;
            else if (do_precharge || do_reada || do_refresh || do_initial || PM_STOP)
                oe4   <= 0;
            OE <= oe4;
        end
                               
end




// This always block tracks the time between the activate command and the
// subsequent WRITEA or READA command, RC.  The shift register is set using
// the configuration register setting SC_RCD. The shift register is loaded with
// a single '1' with the position within the register dependent on SC_RCD.
// When the '1' is shifted out of the register it sets so_rw which triggers
// a writea or reada command
//
always @(posedge CLK or negedge RESET_N) begin
    if (!RESET_N) begin
        rw_shift <= 0;
        do_rw    <= 0;
    end
    else begin  
        if (do_reada || do_writea) begin
            if (SC_RCD == 1)                          // Set the shift register
                do_rw <= 1;
            else if (SC_RCD == 2)
                rw_shift <= 1;
            else if (SC_RCD == 3)
                rw_shift <= 2;
        end
        else begin
            rw_shift <= (rw_shift>>1);
            do_rw    <= rw_shift[0];
        end 
    end
end              

// This always block generates the command acknowledge, CM_ACK, signal.
// It also generates the acknowledge signal, REF_ACK, that acknowledges
// a refresh request that was generated by the internal refresh timer circuit.
always @(posedge CLK or negedge RESET_N)  begin
    if (!RESET_N) begin
        CM_ACK   <= 0;
        REF_ACK  <= 0;
    end
    else begin
        if (do_refresh == 1 && REF_REQ == 1)                   // Internal refresh timer refresh request
            REF_ACK <= 1;
        else if ((do_refresh) || (do_reada) || (do_writea) || (do_precharge) || (do_load_mode))  // externa  commands
            CM_ACK <= 1;
        else begin
            REF_ACK <= 0;
            CM_ACK  <= 0;
        end
    end
end 
                    


// This always block generates the address, cs, cke, and command signals(ras,cas,wen)
// 
always @(posedge CLK) begin
    if (!RESET_N) begin
        SA    <= 0;
        BA    <= 0;
        CS_N  <= 1;
        RAS_N <= 1;
        CAS_N <= 1;
        WE_N  <= 1;
        CKE   <= 0;
    end
    else begin
        CKE <= 1;
// Generate SA 	
        if (do_writea || do_reada)    // ACTIVATE command is being issued, so present the row address
            SA <= rowaddr;
        else
            SA <= coladdr;                 // else alway present column address

        if (do_rw || do_precharge)
            SA[10] <= !SC_PM;              // set SA[10] for autoprecharge read/write or for a precharge all command
                                               // don't set it if the controller is in page mode.           
        if (do_precharge || do_load_mode)
            BA <= 0;                       // Set BA=0 if performing a precharge or load_mode command
        else
            BA <= bankaddr[1:0];           // else set it with the appropriate address bits

        if (do_refresh || do_precharge || do_load_mode || do_initial)
            CS_N <= 0;                                    // Select both chip selects if performing
        else begin                                        // refresh, precharge(all) or load_mode
            CS_N[0] <= SADDR[`ASIZE-1];                   // else set the chip selects based off of the
            CS_N[1] <= ~SADDR[`ASIZE-1];                  // msb address bit
        end

        if(do_load_mode)
		    SA	<= {2'b00,SDR_CL,SDR_BT,SDR_BL}; 
		
//Generate the appropriate logic levels on RAS_N, CAS_N, and WE_N
//depending on the issued command.
//		
        if (do_refresh) begin                        // Refresh: S=00, RAS=0, CAS=0, WE=1
            RAS_N <= 0;
            CAS_N <= 0;
            WE_N  <= 1;
        end
        else if (do_precharge && ((oe4 == 1) || rw_flag)) begin      // burst terminate if write is active  ???????
            RAS_N <= 1;
            CAS_N <= 1;
            WE_N  <= 0;
        end
        else if (do_precharge) begin                 // Precharge All: S=00, RAS=0, CAS=1, WE=0
            RAS_N <= 0;
            CAS_N <= 1;
            WE_N  <= 0;
        end
        else if (do_load_mode) begin                 // Mode Write: S=00, RAS=0, CAS=0, WE=0
            RAS_N <= 0;
            CAS_N <= 0;
            WE_N  <= 0;
        end
        else if (do_reada || do_writea) begin        // Activate: S=01 or 10, RAS=0, CAS=1, WE=1
            RAS_N <= 0;
            CAS_N <= 1;
            WE_N  <= 1;
        end
        else if (do_rw) begin                         // Read/Write: S=01 or 10, RAS=1, CAS=0, WE=0 or 1
            RAS_N <= 1;
            CAS_N <= 0;
            WE_N  <= rw_flag;
        end
		else if (do_initial) begin
            RAS_N <= 1;
            CAS_N <= 1;
            WE_N  <= 1;				
		end
        else begin                                      // No Operation: RAS=1, CAS=1, WE=1
            RAS_N <= 1;
            CAS_N <= 1;
            WE_N  <= 1;
        end
    end 
end

endmodule