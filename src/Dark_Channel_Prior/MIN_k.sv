module MIN_k (
    input      [8*k-1:0] data_group,
    output reg [7:0]      data_min
);
genvar  i;
integer m , n;
`include "DCP_Param.h"

// ---------------------------------------------------------------------------
// Wires and Registers    
logic [7:0] data [k:1];    
generate
    for (i = 1; i <= k; i = i + 1) begin:APPLE
       assign data[i] = data_group[(i*8-1) -: 8]; //data[1] = data_group[7:0], data[2] = data_group[14:8]...
    end
endgenerate

// ---------------------------------------------------------------------------
// Combinational Blocks
always_comb begin  //can't reuse with parameter
    if     ((data[1] <= data[2]) && (data[1] <= data[3])) data_min = data[1];
    else if(data[2] <= data[3])                           data_min = data[2];
    else                                                  data_min = data[3];
end

endmodule

