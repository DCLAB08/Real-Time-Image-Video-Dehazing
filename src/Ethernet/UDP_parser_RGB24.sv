module UDP_parser_RGB24(
    input               i_clk,
    input               i_rst_n,

    input               i_udp_rx_valid,
    input               i_udp_rx_last,
    input   [7:0]       i_udp_rx_data,

    output  [7:0]       o_channel_B,
    output  [7:0]       o_channel_G,
    output  [7:0]       o_channel_R,
    // When o_valid is asserted, it means that 3-channel values are all available at that time
    output              o_valid,

    // for debug usage
    output  [7:0]       o_test_len,         // this is inavailable
    output  [7:0]       o_test_last_byte,   // last byte of the package
    output  [7:0]       o_test_first_byte   // first byte of the package

);

// The waveform should be as follows (Maybe)
//           __    __    __    __    __    __    __    __    __
// clk    __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__
//                 _____ _____ _____ _____ _____ _____
// tdata  XXXXXXXXX_A0__X_A1__X_A2__X_B0__X_B1__X_B2__XXXXXXXXXXXX
//                 ___________________________________
// tvalid ________/                                   \___________
//                             _____             _____
// tlast  ____________________/     \___________/     \___________


localparam S_IDLE   = 3'd0;
localparam S_READ   = 3'd1;

logic [2:0]     state_r, state_w;
logic [23:0]    payload_r, payload_w;
logic [7:0]     counter_r, counter_w;
logic           valid_r, valid_w;

logic [7:0]     test_len_r, test_len_w;
logic [7:0]     test_last_byte_r, test_last_byte_w;
logic [7:0]     test_first_byte_r, test_first_byte_w;

assign o_channel_B = payload_r[23:16];
assign o_channel_G = payload_r[15:8];
assign o_channel_R = payload_r[7:0];
assign o_test_len = test_len_r;
assign o_test_last_byte = test_last_byte_r;
assign o_test_first_byte = test_first_byte_r;
assign o_valid = valid_r;


always_comb begin
    state_w             = state_r;
    payload_w           = payload_r;
    counter_w           = counter_r;
    valid_w             = 0;
    
    test_len_w          = test_len_r;
    test_last_byte_w    = test_last_byte_r;
    test_first_byte_w   = test_first_byte_r;

    case (state_r)
        S_IDLE: begin             
            if (i_udp_rx_valid) begin
                test_first_byte_w = i_udp_rx_data;
                payload_w[counter_r-8'd1 -: 8] = i_udp_rx_data;
                counter_w = counter_r - 8'd8;
                test_len_w = test_len_r + 1;
                state_w = S_READ;
            end
            else begin
                counter_w = 8'd24;
                state_w = S_IDLE;
            end
        end
        S_READ: begin
            payload_w[counter_r-8'd1 -: 8] = i_udp_rx_data;
            counter_w = counter_r - 8'd8;
            state_w = S_READ;
            test_len_w  = test_len_r + 1;
            
            if(counter_r == 8'd8) begin // last channel(R in BGR) is set, reset the counter and give OK signal
                counter_w = 8'd24;
                valid_w = 1;
            end
            
            if(i_udp_rx_last) begin // end of the package
                state_w = S_IDLE;
                test_len_w  = 0;
                counter_w = 8'd24;
                test_last_byte_w = i_udp_rx_data;
            end
        end
        default: begin
            state_w = state_r;
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state_r                 <= 0;
        counter_r               <= 8'd24;
        payload_r               <= 0;
        valid_r                 <= 0;
        
        test_len_r              <= 0;
        test_last_byte_r        <= 0;
        test_first_byte_r       <= 0;
    end
    else begin
        state_r                 <= state_w;
        counter_r               <= counter_w;
        payload_r               <= payload_w;
        valid_r                 <= valid_w;
        
        test_len_r              <= test_len_w;
        test_last_byte_r        <= test_last_byte_w;
        test_first_byte_r       <= test_first_byte_w;
    end
end

endmodule