//`include "TEM.sv"
// `include ""

module DCP(
    input i_clk,
    input i_rst_n,
    input i_in_valid,
    input [9:0] i_RED_data,
    input [9:0] i_GREEN_data, 
    input [9:0] i_BLUE_data,
    input i_VGA_request,
    input [2:0] i_display_option,


    output logic  o_SDRAM_read,
    output[9:0] R_data_out,
    output[9:0] G_data_out,
    output[9:0] B_data_out,
    output[25:0] debug_LED
    );
`include "DCP_Param.h"


localparam IDLE       = 5'd0,
           WAITING    = 5'd1,
           PROCESSING = 5'd2;
localparam WAIT_CYCLE = 32'h1ffffff;
integer i, m, n, q, j;


// ---------------------------------------------------------------------------
// Wires and Registers
//INPUT
logic [23:0] pixel_in;
//FSM
logic [4:0]  state_r, state_w;
logic [31:0] wait_cout_r, wait_cout_w;
//TEM
logic [71:0] in_line;
logic [7:0]  t_appr, t_appr_R, t_appr_G, t_appr_B;
logic        in_en;
logic        out_en;

logic [23:0] stream1_r [width-1:0];
logic [23:0] stream2_r [width-1:0];
logic [23:0] stream3_r [width-1:0];
logic [23:0] stream1_w [width-1:0];
logic [23:0] stream2_w [width-1:0];
logic [23:0] stream3_w [width-1:0];

logic [7:0]  delay1_r [(k-1):0];
logic [7:0]  delay2_r [(k-1):0];
logic [7:0]  delay3_r [(k-1):0];
logic [7:0]  delay1_w [(k-1):0];
logic [7:0]  delay2_w [(k-1):0];
logic [7:0]  delay3_w [(k-1):0];

// display mode
localparam D_ORIGIN = 0;
localparam D_TRANSMISSION = 1;
localparam D_DEHAZE = 2;

// pre-fetch
localparam PREFETCH_NUM = 640*5;

logic [19:0] prefetch_counter_r, prefetch_counter_w;
logic shift_r, shift_w; // 1 for shifting, 0 for holding
logic err_r, err_w;     // debug use

logic [31:0] valid_counter_r, valid_counter_w;
assign debug_LED = valid_counter_r;
// ---------------------------------------------------------------------------
// Instance
TEM TEM_1(.clk(i_clk), 
          .rst_n(i_rst_n), 
          .in_en(in_en), 
          .in_line(in_line), 
          .out_en(out_en), 
          .t_appr(t_appr), 
          .t_appr_R(t_appr_R), 
          .t_appr_G(t_appr_G), 
          .t_appr_B(t_appr_B)
          );

// ---------------------------------------------------------------------------
// Continuous Assignment
assign pixel_in = {i_RED_data[9:2], i_GREEN_data[9:2], i_BLUE_data[9:2]};   
assign in_line  = {stream1_r[width-1], stream2_r[width-1], stream3_r[width-1]};

always_comb begin
    o_SDRAM_read = i_VGA_request;
    shift_w = shift_r;
    prefetch_counter_w = prefetch_counter_r;
    if (state_r == PROCESSING) begin
        if (prefetch_counter_r < PREFETCH_NUM) begin // prefetch before VGA ask
            o_SDRAM_read = 1;
            shift_w = 1;
            prefetch_counter_w = prefetch_counter_r + 1;
        end
        else if (i_VGA_request) begin // if VGA request, then ask for SDRAM & shift FIFO
            o_SDRAM_read = 1;
            shift_w = 1;
            prefetch_counter_w = prefetch_counter_r;
        end
        else begin // hold when not asked by VGA and not prefetching
            o_SDRAM_read = 0;
            shift_w = 0;
            prefetch_counter_w = prefetch_counter_r;
        end
        
    end

    // debug use
    // if (err_r || (prefetch_counter_r < PREFETCH_NUM && i_VGA_request)) begin
    //     err_w = 1;
    // end
    // else err_w = 0;
    // debug_LED[0] = err_r;
end

// FIFO
always_comb begin
    
    if (shift_r) begin // shift
        stream1_w[0] = pixel_in;
        stream2_w[0] = stream1_r[width-1];
        stream3_w[0] = stream2_r[width-1];
        for (j = 1; j <= (width - 1); j = j + 1) begin
            stream1_w[j] = stream1_r[j-1];
            stream2_w[j] = stream2_r[j-1];
            stream3_w[j] = stream3_r[j-1];
        end

        delay1_w[0] = stream3_r[width-1][23:16];
        delay2_w[0] = stream3_r[width-1][15:8];
        delay3_w[0] = stream3_r[width-1][7:0];

        for (j = 1; j <= (k - 1); j = j + 1) begin
            delay1_w[j] = delay1_r[j-1];
            delay2_w[j] = delay2_r[j-1];
            delay3_w[j] = delay3_r[j-1];
        end
    end
    else begin // hold
        for (j = 0; j <= (width - 1); j = j + 1) begin
            stream1_w[j] = stream1_r[j];
            stream2_w[j] = stream2_r[j];
            stream3_w[j] = stream3_r[j];
        end

        for (j = 0; j <= (k - 1); j = j + 1) begin
            delay1_w[j] = delay1_r[j];
            delay2_w[j] = delay2_r[j];
            delay3_w[j] = delay3_r[j];
        end
    end
    
    
    
end

always_comb begin
    case (i_display_option)
        D_ORIGIN: begin // original display (camera)
            R_data_out = {delay1_r[2], 2'b0};
            G_data_out = {delay2_r[2], 2'b0};
            B_data_out = {delay3_r[2], 2'b0};
        end
        D_TRANSMISSION: begin // transmission map
            R_data_out = {t_appr_R, 2'b0};
            G_data_out = {t_appr_G, 2'b0};
            B_data_out = {t_appr_B, 2'b0};
        end
        D_DEHAZE: begin // dehaze
            R_data_out = {R3_r, 2'b0};
            G_data_out = {G3_r, 2'b0};
            B_data_out = {B3_r, 2'b0};
        end
        default: begin // default original
            R_data_out = {delay1_r[2], 2'b0};
            G_data_out = {delay2_r[2], 2'b0};
            B_data_out = {delay3_r[2], 2'b0};
        end
    endcase
end

//OUTPUT
logic signed [19:0] R1_r, R1_w; 
logic signed [30:0] R2_r, R2_w;
logic signed [7:0]  R3_r, R3_w;

logic signed [19:0] G1_r, G1_w; 
logic signed [30:0] G2_r, G2_w;
logic signed [7:0]  G3_r, G3_w;

logic signed [19:0] B1_r, B1_w; 
logic signed [30:0] B2_r, B2_w;
logic signed [7:0]  B3_r, B3_w;

logic [7:0] t_appr_r, t_appr_w, t;
assign t_appr_w = t_appr;
assign t = (t_appr_r <= 256)? 256 : t_appr_r;

logic [7:0] t_r, t_g, t_b;
assign t_r = (t_appr_R <= 26)? 26 : t_appr_R;
assign t_g = (t_appr_G <= 26)? 26 : t_appr_G;
assign t_b = (t_appr_B <= 26)? 26 : t_appr_B;

logic [19:0] num;

// assign R1_w = (t_r >= 500) ? ; 
// assign R2_w = {R1_r, 10'd0}/t_r;
assign R1_w = num[19:0];//A_red/t_r;  
assign R2_w = {10'd0, R1_r}*({10'd0,(A_red - delay1_r[2])});
assign R3_w = A_red - R2_r[23:16];

// assign G1_w = (~delay2_r[2]);  
// assign G2_w = {G1_r, 10'd0}/t_g;
assign G1_w = num[19:0];//A_green/t_g;
assign G2_w = {10'd0, G1_r}*({10'd0,(A_green - delay2_r[2])});
assign G3_w = A_green - G2_r[23:16];

// assign B1_w = (~delay3_r[2]);  
// assign B2_w = {B1_r, 10'd0}/t_b;
assign B1_w = num[19:0];//A_blue/t_b;
assign B2_w = {10'd0, B1_r}*({10'd0,(A_blue - delay3_r[2])});
assign B3_w = A_blue - B2_r[23:16];

// ---------------------------------------------------------------------------
// Combinational Blocks
//FSM
always_comb begin  
    state_w     = state_r;
    wait_cout_w = wait_cout_r;
    valid_counter_w = valid_counter_r;


    case(state_r)
        IDLE: begin
            in_en       = 0;
            // if (i_in_valid) begin // for camera use
            if (valid_counter_r == WAIT_CYCLE) begin
                state_w      = WAITING;
                wait_cout_w  = wait_cout_r + 1;
            end
            else begin
                valid_counter_w = valid_counter_r + 1;
                state_w      = state_r;
                wait_cout_w  = 0;
            end
        end
        WAITING: begin
            in_en       = 0;
            if(wait_cout_r <= (width*3)) begin    //1 640    //0 639 
                state_w      = state_r;
                wait_cout_w  = wait_cout_r + 1;
            end
            else begin
                state_w      = PROCESSING;
                wait_cout_w  = 0;
            end
        end
        PROCESSING: begin
            in_en   = 1;
            state_w = state_r;
        end

    endcase
end


// ---------------------------------------------------------------------------
// Sequential Block
always @(posedge i_clk) begin
    if(!i_rst_n) begin
        shift_r <= 0;
        prefetch_counter_r <= 0;
        valid_counter_r <= 0;

        state_r     <= IDLE;
        wait_cout_r <= 0;
        for (i = 0; i <= (width-1); i = i + 1) begin
        	stream1_r[i] <= 0;
            stream2_r[i] <= 0;
            stream3_r[i] <= 0;
        end


        for (j = 0; j <= (k-1); j = j + 1) begin
            delay1_r[j] <= 0;
            delay2_r[j] <= 0;
            delay3_r[j] <= 0;
        end

        R1_r <= 0;
        R2_r <= 0;
        R3_r <= 0;
        G1_r <= 0;
        G2_r <= 0;
        G3_r <= 0;        
        B1_r <= 0;
        B2_r <= 0;
        B3_r <= 0;

    end
    else begin
        shift_r <= shift_w;
        prefetch_counter_r <= prefetch_counter_w;
        valid_counter_r <= valid_counter_w;

        state_r     <= state_w;
        wait_cout_r <= wait_cout_w;
        for (i = 0; i <= (width-1); i = i + 1) begin
        	stream1_r[i] <= stream1_w[i];
            stream2_r[i] <= stream1_w[i];
            stream3_r[i] <= stream1_w[i];
        end


        for (i = 0; i <= (k-1); i = i + 1) begin
            delay1_r[i] <= delay1_w[i];
            delay2_r[i] <= delay2_w[i];
            delay3_r[i] <= delay3_w[i];
        end

        
        R1_r <= R1_w;
        R2_r <= R2_w;
        R3_r <= R3_w;
        G1_r <= G1_w;
        G2_r <= G2_w;
        G3_r <= G3_w;        
        B1_r <= B1_w;
        B2_r <= B2_w;
        B3_r <= B3_w;
        t_appr_r<= t_appr_w;

    end
end

always_comb begin : blockName
    case(t_r)
        0: num = 20'b1010_0000000000000000;
        1: num = 20'b1010_0000000000000000;
        2: num = 20'b1010_0000000000000000;
        3: num = 20'b1010_0000000000000000;
        4: num = 20'b1010_0000000000000000;
        5: num = 20'b1010_0000000000000000;
        6: num = 20'b1010_0000000000000000;
        7: num = 20'b1010_0000000000000000;
        8: num = 20'b1010_0000000000000000;
        9: num = 20'b1010_0000000000000000;
        10: num = 20'b1010_0000000000000000;
        11: num = 20'b1010_0000000000000000;
        12: num = 20'b1010_0000000000000000;
        13: num = 20'b1010_0000000000000000;
        14: num = 20'b1010_0000000000000000;
        15: num = 20'b1010_0000000000000000;
        16: num = 20'b1010_0000000000000000;
        17: num = 20'b1010_0000000000000000;
        18: num = 20'b1010_0000000000000000;
        19: num = 20'b1010_0000000000000000;
        20: num = 20'b1010_0000000000000000;
        21: num = 20'b1010_0000000000000000;
        22: num = 20'b1010_0000000000000000;
        23: num = 20'b1010_0000000000000000;
        24: num = 20'b1010_0000000000000000;
        25: num = 20'b1010_0000000000000000;
        26: num = 20'b1001_1100111011000100;
        27: num = 20'b1001_0111000111000111;
        28: num = 20'b1001_0001101101101101;
        29: num = 20'b1000_1100101100001000;
        30: num = 20'b1000_1000000000000000;
        31: num = 20'b1000_0011100111001110;
        32: num = 20'b0111_1111100000000000;
        33: num = 20'b0111_1011101000101110;
        34: num = 20'b0111_1000000000000000;
        35: num = 20'b0111_0100100100100100;
        36: num = 20'b0111_0001010101010101;
        37: num = 20'b0110_1110010001010011;
        38: num = 20'b0110_1011010111100101;
        39: num = 20'b0110_1000100111011000;
        40: num = 20'b0110_0110000000000000;
        41: num = 20'b0110_0011100000110001;
        42: num = 20'b0110_0001001001001001;
        43: num = 20'b0101_1110111000100011;
        44: num = 20'b0101_1100101110100010;
        45: num = 20'b0101_1010101010101010;
        46: num = 20'b0101_1000101100100001;
        47: num = 20'b0101_0110110011101111;
        48: num = 20'b0101_0101000000000000;
        49: num = 20'b0101_0011010000111110;
        50: num = 20'b0101_0001100110011001;
        51: num = 20'b0101_0000000000000000;
        52: num = 20'b0100_1110011101100010;
        53: num = 20'b0100_1100111110110010;
        54: num = 20'b0100_1011100011100011;
        55: num = 20'b0100_1010001011101000;
        56: num = 20'b0100_1000110110110110;
        57: num = 20'b0100_0111100101000011;
        58: num = 20'b0100_0110010110000100;
        59: num = 20'b0100_0101001001110000;
        60: num = 20'b0100_0100000000000000;
        61: num = 20'b0100_0010111000101001;
        62: num = 20'b0100_0001110011100111;
        63: num = 20'b0100_0000110000110000;
        64: num = 20'b0011_1111110000000000;
        65: num = 20'b0011_1110110001001110;
        66: num = 20'b0011_1101110100010111;
        67: num = 20'b0011_1100111001010100;
        68: num = 20'b0011_1100000000000000;
        69: num = 20'b0011_1011001000010110;
        70: num = 20'b0011_1010010010010010;
        71: num = 20'b0011_1001011101101111;
        72: num = 20'b0011_1000101010101010;
        73: num = 20'b0011_0111111000111111;
        74: num = 20'b0011_0111001000101001;
        75: num = 20'b0011_0110011001100110;
        76: num = 20'b0011_0101101011110010;
        77: num = 20'b0011_0100111111001010;
        78: num = 20'b0011_0100010011101100;
        79: num = 20'b0011_0011101001010100;
        80: num = 20'b0011_0011000000000000;
        81: num = 20'b0011_0010010111101101;
        82: num = 20'b0011_0001110000011000;
        83: num = 20'b0011_0001001010000001;
        84: num = 20'b0011_0000100100100100;
        85: num = 20'b0011_0000000000000000;
        86: num = 20'b0010_1111011100010001;
        87: num = 20'b0010_1110111001011000;
        88: num = 20'b0010_1110010111010001;
        89: num = 20'b0010_1101110101111011;
        90: num = 20'b0010_1101010101010101;
        91: num = 20'b0010_1100110101011100;
        92: num = 20'b0010_1100010110010000;
        93: num = 20'b0010_1011110111101111;
        94: num = 20'b0010_1011011001110111;
        95: num = 20'b0010_1010111100101000;
        96: num = 20'b0010_1010100000000000;
        97: num = 20'b0010_1010000011111101;
        98: num = 20'b0010_1001101000011111;
        99: num = 20'b0010_1001001101100100;
        100: num = 20'b0010_1000110011001100;
        101: num = 20'b0010_1000011001010110;
        102: num = 20'b0010_1000000000000000;
        103: num = 20'b0010_0111100111001001;
        104: num = 20'b0010_0111001110110001;
        105: num = 20'b0010_0110110110110110;
        106: num = 20'b0010_0110011111011001;
        107: num = 20'b0010_0110001000010111;
        108: num = 20'b0010_0101110001110001;
        109: num = 20'b0010_0101011011100110;
        110: num = 20'b0010_0101000101110100;
        111: num = 20'b0010_0100110000011011;
        112: num = 20'b0010_0100011011011011;
        113: num = 20'b0010_0100000110110010;
        114: num = 20'b0010_0011110010100001;
        115: num = 20'b0010_0011011110100110;
        116: num = 20'b0010_0011001011000010;
        117: num = 20'b0010_0010110111110010;
        118: num = 20'b0010_0010100100111000;
        119: num = 20'b0010_0010010010010010;
        120: num = 20'b0010_0010000000000000;
        121: num = 20'b0010_0001101110000001;
        122: num = 20'b0010_0001011100010100;
        123: num = 20'b0010_0001001010111011;
        124: num = 20'b0010_0000111001110011;
        125: num = 20'b0010_0000101000111101;
        126: num = 20'b0010_0000011000011000;
        127: num = 20'b0010_0000001000000100;
        128: num = 20'b0001_1111111000000000;
        129: num = 20'b0001_1111101000001011;
        130: num = 20'b0001_1111011000100111;
        131: num = 20'b0001_1111001001010010;
        132: num = 20'b0001_1110111010001011;
        133: num = 20'b0001_1110101011010011;
        134: num = 20'b0001_1110011100101010;
        135: num = 20'b0001_1110001110001110;
        136: num = 20'b0001_1110000000000000;
        137: num = 20'b0001_1101110001111111;
        138: num = 20'b0001_1101100100001011;
        139: num = 20'b0001_1101010110100011;
        140: num = 20'b0001_1101001001001001;
        141: num = 20'b0001_1100111011111010;
        142: num = 20'b0001_1100101110110111;
        143: num = 20'b0001_1100100010000000;
        144: num = 20'b0001_1100010101010101;
        145: num = 20'b0001_1100001000110100;
        146: num = 20'b0001_1011111100011111;
        147: num = 20'b0001_1011110000010100;
        148: num = 20'b0001_1011100100010100;
        149: num = 20'b0001_1011011000011110;
        150: num = 20'b0001_1011001100110011;
        151: num = 20'b0001_1011000001010001;
        152: num = 20'b0001_1010110101111001;
        153: num = 20'b0001_1010101010101010;
        154: num = 20'b0001_1010011111100101;
        155: num = 20'b0001_1010010100101001;
        156: num = 20'b0001_1010001001110110;
        157: num = 20'b0001_1001111111001011;
        158: num = 20'b0001_1001110100101010;
        159: num = 20'b0001_1001101010010000;
        160: num = 20'b0001_1001100000000000;
        161: num = 20'b0001_1001010101110111;
        162: num = 20'b0001_1001001011110110;
        163: num = 20'b0001_1001000001111101;
        164: num = 20'b0001_1000111000001100;
        165: num = 20'b0001_1000101110100010;
        166: num = 20'b0001_1000100101000000;
        167: num = 20'b0001_1000011011100101;
        168: num = 20'b0001_1000010010010010;
        169: num = 20'b0001_1000001001000101;
        170: num = 20'b0001_1000000000000000;
        171: num = 20'b0001_0111110111000001;
        172: num = 20'b0001_0111101110001000;
        173: num = 20'b0001_0111100101010111;
        174: num = 20'b0001_0111011100101100;
        175: num = 20'b0001_0111010100000111;
        176: num = 20'b0001_0111001011101000;
        177: num = 20'b0001_0111000011010000;
        178: num = 20'b0001_0110111010111101;
        179: num = 20'b0001_0110110010110001;
        180: num = 20'b0001_0110101010101010;
        181: num = 20'b0001_0110100010101001;
        182: num = 20'b0001_0110011010101110;
        183: num = 20'b0001_0110010010111000;
        184: num = 20'b0001_0110001011001000;
        185: num = 20'b0001_0110000011011101;
        186: num = 20'b0001_0101111011110111;
        187: num = 20'b0001_0101110100010111;
        188: num = 20'b0001_0101101100111011;
        189: num = 20'b0001_0101100101100101;
        190: num = 20'b0001_0101011110010100;
        191: num = 20'b0001_0101010111000111;
        192: num = 20'b0001_0101010000000000;
        193: num = 20'b0001_0101001000111101;
        194: num = 20'b0001_0101000001111110;
        195: num = 20'b0001_0100111011000100;
        196: num = 20'b0001_0100110100001111;
        197: num = 20'b0001_0100101101011110;
        198: num = 20'b0001_0100100110110010;
        199: num = 20'b0001_0100100000001010;
        200: num = 20'b0001_0100011001100110;
        201: num = 20'b0001_0100010011000110;
        202: num = 20'b0001_0100001100101011;
        203: num = 20'b0001_0100000110010011;
        204: num = 20'b0001_0100000000000000;
        205: num = 20'b0001_0011111001110000;
        206: num = 20'b0001_0011110011100100;
        207: num = 20'b0001_0011101101011100;
        208: num = 20'b0001_0011100111011000;
        209: num = 20'b0001_0011100001011000;
        210: num = 20'b0001_0011011011011011;
        211: num = 20'b0001_0011010101100010;
        212: num = 20'b0001_0011001111101100;
        213: num = 20'b0001_0011001001111010;
        214: num = 20'b0001_0011000100001011;
        215: num = 20'b0001_0010111110100000;
        216: num = 20'b0001_0010111000111000;
        217: num = 20'b0001_0010110011010100;
        218: num = 20'b0001_0010101101110011;
        219: num = 20'b0001_0010101000010101;
        220: num = 20'b0001_0010100010111010;
        221: num = 20'b0001_0010011101100010;
        222: num = 20'b0001_0010011000001101;
        223: num = 20'b0001_0010010010111100;
        224: num = 20'b0001_0010001101101101;
        225: num = 20'b0001_0010001000100010;
        226: num = 20'b0001_0010000011011001;
        227: num = 20'b0001_0001111110010011;
        228: num = 20'b0001_0001111001010000;
        229: num = 20'b0001_0001110100010000;
        230: num = 20'b0001_0001101111010011;
        231: num = 20'b0001_0001101010011000;
        232: num = 20'b0001_0001100101100001;
        233: num = 20'b0001_0001100000101011;
        234: num = 20'b0001_0001011011111001;
        235: num = 20'b0001_0001010111001001;
        236: num = 20'b0001_0001010010011100;
        237: num = 20'b0001_0001001101110001;
        238: num = 20'b0001_0001001001001001;
        239: num = 20'b0001_0001000100100011;
        240: num = 20'b0001_0001000000000000;
        241: num = 20'b0001_0000111011011111;
        242: num = 20'b0001_0000110111000000;
        243: num = 20'b0001_0000110010100100;
        244: num = 20'b0001_0000101110001010;
        245: num = 20'b0001_0000101001110010;
        246: num = 20'b0001_0000100101011101;
        247: num = 20'b0001_0000100001001010;
        248: num = 20'b0001_0000011100111001;
        249: num = 20'b0001_0000011000101011;
        250: num = 20'b0001_0000010100011110;
        251: num = 20'b0001_0000010000010100;
        252: num = 20'b0001_0000001100001100;
        253: num = 20'b0001_0000001000000110;
        254: num = 20'b0001_0000000100000010;
        255: num = 20'b0001_0000000000000000;
        default: num = 0;
    endcase
end




endmodule