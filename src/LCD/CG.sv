module CG ( // character generator for LCD
	input  [7:0]   i_message,
	output [255:0] o_string
);

logic [255:0] bit_string;
logic [255:0] reverse_string;

assign o_string = reverse_string;

integer i;
always_comb begin
	// Since the sentence starts from LSB but assigned from MSB, need reversion
	for (i = 0; i < 32; i = i+1) begin
		reverse_string[(i<<3)+:8] = bit_string[(((32-i)<<3)-1)-:8];
	end
end

localparam C_space = 8'b0001_0000;

localparam C_0 = 8'b0011_0000;
localparam C_1 = 8'b0011_0001;
localparam C_2 = 8'b0011_0010;
localparam C_3 = 8'b0011_0011;
localparam C_4 = 8'b0011_0100;
localparam C_5 = 8'b0011_0101;
localparam C_6 = 8'b0011_0110;
localparam C_7 = 8'b0011_0111;
localparam C_8 = 8'b0011_1000;
localparam C_9 = 8'b0011_1001;

localparam C_A = 8'b0100_0001;
localparam C_B = 8'b0100_0010;
localparam C_C = 8'b0100_0011;
localparam C_D = 8'b0100_0100;
localparam C_E = 8'b0100_0101;
localparam C_F = 8'b0100_0110;
localparam C_G = 8'b0100_0111;
localparam C_H = 8'b0100_1000;
localparam C_I = 8'b0100_1001;
localparam C_J = 8'b0100_1010;
localparam C_K = 8'b0100_1011;
localparam C_L = 8'b0100_1100;
localparam C_M = 8'b0100_1101;
localparam C_N = 8'b0100_1110;
localparam C_O = 8'b0100_1111;

localparam C_P = 8'b0101_0000;
localparam C_Q = 8'b0101_0001;
localparam C_R = 8'b0101_0010;
localparam C_S = 8'b0101_0011;
localparam C_T = 8'b0101_0100;
localparam C_U = 8'b0101_0101;
localparam C_V = 8'b0101_0110;
localparam C_W = 8'b0101_0111;
localparam C_X = 8'b0101_1000;
localparam C_Y = 8'b0101_1001;
localparam C_Z = 8'b0101_1010;

localparam C_a = 8'b0110_0001;
localparam C_b = 8'b0110_0010;
localparam C_c = 8'b0110_0011;
localparam C_d = 8'b0110_0100;
localparam C_e = 8'b0110_0101;
localparam C_f = 8'b0110_0110;
localparam C_g = 8'b0110_0111;
localparam C_h = 8'b0110_1000;
localparam C_i = 8'b0110_1001;
localparam C_j = 8'b0110_1010;
localparam C_k = 8'b0110_1011;
localparam C_l = 8'b0110_1100;
localparam C_m = 8'b0110_1101;
localparam C_n = 8'b0110_1110;
localparam C_o = 8'b0110_1111;

localparam C_p = 8'b0111_0000;
localparam C_q = 8'b0111_0001;
localparam C_r = 8'b0111_0010;
localparam C_s = 8'b0111_0011;
localparam C_t = 8'b0111_0100;
localparam C_u = 8'b0111_0101;
localparam C_v = 8'b0111_0110;
localparam C_w = 8'b0111_0111;
localparam C_x = 8'b0111_1000;
localparam C_y = 8'b0111_1001;
localparam C_z = 8'b0111_1010;

localparam C_ex = 8'b0010_0001;   // ! Exclamation mark
localparam C_colon = 8'b0011_1010; // : Colon


logic [127:0] first_row, second_row;
assign bit_string = {first_row, second_row};
always_comb begin
	// First row shows display mode
	case (i_message)
		// Original picture
		8'd0: first_row = {{C_O}, {C_r}, {C_i}, {C_g}, {C_i}, {C_n}, {C_a}, {C_l},{C_space}, {C_P}, {C_i}, {C_c}, {C_t}, {C_u}, {C_r}, {C_e}};

		// Transmission Map
		8'd1: first_row = {{C_T}, {C_r}, {C_a}, {C_n}, {C_s}, {C_m}, {C_i}, {C_s}, {C_s}, {C_i}, {C_o}, {C_n},  {C_space}, {C_M}, {C_a}, {C_p}};

		// Dehazed picture
		8'd2: first_row = {{C_D}, {C_e}, {C_h}, {C_a}, {C_z}, {C_e}, {C_d}, {C_space}, {C_P}, {C_i}, {C_c}, {C_t}, {C_u}, {C_r}, {C_e}, {C_space}};

		// Debug use
		// 8'd3: first_row = {{C_D}, {C_e}, {C_b}, {C_u}, {C_g}, {11{C_space}}};

		// All clear
		8'b1111_1111: first_row = {16{C_space}};

		default: begin
			// I love DCLab
			first_row = {{C_I}, {C_space}, {C_l}, {C_o}, {C_v}, {C_e}, {C_space}, {C_D}, {C_C}, {C_L}, {C_a}, {C_b}, {C_ex}, {3{C_space}}};
		end
	endcase

	second_row = {16{C_space}};
end
endmodule