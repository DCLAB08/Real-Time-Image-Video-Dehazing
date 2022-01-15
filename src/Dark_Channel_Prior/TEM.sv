
// `include "MIN_k2.sv"
//Transmission Estimation Module
module TEM (
    input clk,
    input rst_n, 
    input in_en,
    input [24*k-1:0] in_line,
    output out_en,
    output[7:0] t_appr,
    output[7:0] t_appr_R,
    output[7:0] t_appr_G,
    output[7:0] t_appr_B
    
);
`include "DCP_Param.h"

// ---------------------------------------------------------------------------
// Wires and Registers
logic [8*k-1:0] line [0:k-1];
logic [8*k-1:0] R_column, G_column, B_column;
logic R_out_en, G_out_en, B_out_en;
logic [7:0]  R_min, G_min, B_min;
logic [7:0]  column_min;
logic [7:0]  dark_channel;
logic [12:0] wt; 
//output
logic [7:0]  t_appr_R_r, t_appr_G_r, t_appr_B_r;

// ---------------------------------------------------------------------------
// Continuous Assignment
assign R_column = {line[0][23:16], line[1][23:16], line[k-1][23:16]};
assign G_column = {line[0][15:8], line[1][15:8], line[k-1][15:8]};
assign B_column = {line[0][7:0], line[1][7:0], line[k-1][7:0]};

assign out_en   = B_out_en;
assign t_appr   = dark_channel; 
assign t_appr_R = t_appr_R_r;
assign t_appr_G = t_appr_G_r;
assign t_appr_B = t_appr_B_r;


assign line[0] = in_line[71:48];
assign line[1] = in_line[47:24];
assign line[2] = in_line[23:0];

assign wt = dark_channel * w;
// ---------------------------------------------------------------------------
// Instance
MIN_k  R_MIN(.data_group(R_column), .data_min(R_min));
MIN_k  G_MIN(.data_group(G_column), .data_min(G_min));
MIN_k  B_MIN(.data_group(B_column), .data_min(B_min));
MIN_k  COL_MIN(.data_group({R_min, G_min, B_min}), .data_min(column_min));
MIN_k2 DC(    .clk(clk), 
              .rst_n(rst_n), 
              .in_en(in_en), 
              .column_min(column_min), 
              .t_feedback(t_appr_R_r), 
              .out_en(B_out_en), 
              .min(dark_channel)
          );


always @(posedge clk) begin

    if(!rst_n) begin
        t_appr_R_r <= 0; 
        t_appr_G_r <= 0;
        t_appr_B_r <= 0;
    end

    else begin
        t_appr_R_r <= A_red   - wt[9:2]; 
        t_appr_G_r <= A_green - wt[9:2];
        t_appr_B_r <= A_blue  - wt[9:2];
    end

end


endmodule