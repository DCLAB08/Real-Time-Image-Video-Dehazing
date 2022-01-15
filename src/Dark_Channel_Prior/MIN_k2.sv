// `include "MIN_k.sv"
module MIN_k2 (
    input        clk,
    input        rst_n,
    input        in_en,
    input  [7:0] column_min,
    input  [7:0] t_feedback,
    output       out_en,
    output [7:0] min
);
`include "DCP_Param.h"
integer i , m, n;
genvar  j;

// ---------------------------------------------------------------------------
// Wires and Registers
logic [8*k-1:0] col_s;  
logic [7:0]     window_min;
logic [7:0]     DA_buff_r [0:k-1];
logic [7:0]     DA_buff_w [0:k-1];
logic           EN_buff_r [0:k-1];
logic           EN_buff_w [0:k-1];

// ---------------------------------------------------------------------------
// Continuous Assignment
assign col_s[(8*k-1) -:8]     = column_min;    
assign col_s[(8*(k-1)-1) -:8] = t_feedback; 
assign col_s[(8*(k-2)-1) -:8] = DA_buff_r[k-3];
assign out_en                 = EN_buff_r[k-1];
assign min                    = DA_buff_r[k-1];
// ---------------------------------------------------------------------------
// Instance
MIN_k stage1(.data_group(col_s), .data_min(window_min));

// ---------------------------------------------------------------------------
// Combinational Blocks
always_comb begin 
    //DATA_en
    EN_buff_w[0] = in_en; 
    for (n = 1; n < k; n = n + 1) begin
        EN_buff_w[n] = EN_buff_r[n-1];
    end
    
    //DATA
    DA_buff_w[0]   = column_min;
    DA_buff_w[k-1] = window_min;
    for (m = 1; m < (k-1) ; m = m + 1) begin
        DA_buff_w[m] = DA_buff_r[m-1];
    end

end

// ---------------------------------------------------------------------------
// Sequential Block
always @(posedge clk) begin

    if(!rst_n) begin
        for (i = 0; i < k ; i = i + 1) begin
            DA_buff_r[i] <= 0;
            EN_buff_r[i] <= 0;
        end
    end

    else begin
        for (i = 0; i < k ; i = i + 1) begin
            DA_buff_r[i] <= DA_buff_w[i];
            EN_buff_r[i] <= EN_buff_w[i];
        end
    end
end

endmodule