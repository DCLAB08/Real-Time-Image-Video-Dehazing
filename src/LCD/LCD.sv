module LCD (
	input 	i_clk,      // Clock, f = 800kHz, 1250ns
	input   i_rst_n,    // Asynchronous reset active low
	input   [7:0] i_message,
	inout   [7:0] o_LCD_DATA,
	output  o_LCD_EN,
	output  o_LCD_RS,
	output  o_LCD_RW,
	output  o_LCD_ON,  // always 1
	output	o_LCD_BLON, // always 0
	output  o_finish_init,
	output  [7:0] o_debug
);

assign o_LCD_ON = 1;
assign o_LCD_BLON = 0;

// state
localparam S_IDLE = 1;
localparam S_WAIT_15 = 2; 				// wait for 15ms
localparam S_WAIT_41 = 3; 				// wait for 4.1ms
localparam S_WAIT_100 = 4; 				// wait for 100us
localparam S_WAIT_1 = 5;   				// wait for 1ms
localparam S_INIT_FUNC_1 = 6; 			// send instruction: function set
localparam S_INIT_FUNC_2 = 7; 			// send instruction: function set
localparam S_INIT_DISPLAY_ON = 8; 		// send instruction: display on
localparam S_INIT_DISPLAY_CLEAR = 9; 	// send instruction: display on
localparam S_INIT_ENTRY_MODE = 10; 		// send instruction: entry mode
// localparam S_INIT_BUBBLE = 11; 			// send bubble, 8'b0000_0000
localparam S_SET_ADDR = 12;   			// set DDRAM address
localparam S_WRITE_DATA = 13; 			// write data to DDRAM
localparam S_CHECK_BF = 0; 				// check for busy flag, 1 for internal busy, 0 for not busy

// subset
localparam S_SUB_SET  = 0;
localparam S_SUB_EN   = 1;

localparam COUNT_WAIT_15  = 15000; // 15 ms, 12000
localparam COUNT_WAIT_41  = 5000;  // 4.1 ms, 3280
localparam COUNT_WAIT_100 = 5000;  // 100 us, 80
localparam COUNT_WAIT_1   = 5000;

// for tb
// localparam COUNT_WAIT_15  = 10;
// localparam COUNT_WAIT_41  = 10;
// localparam COUNT_WAIT_100 = 10;


localparam EN_HOLD_CYCLE = 0; // hold en for 5 cycles

// init state
localparam I_INITIATING = 0; // initializing
localparam I_LAST_STEP  = 1; // set entry mode
localparam I_FINISH     = 2; // entry mode finished

logic [3:0]  state_r, state_w;
logic        substate_r, substate_w;         // S_SUB_SET, S_SUB_EN
logic [3:0]  next_state_r, next_state_w;     // save next state for after checking BF
logic [15:0] addr_counter_r, addr_counter_w; // for DDRAM address
logic [7:0]  data_r, data_w;                 // for o_LCD_DATA
logic [7:0]  i_message_r, i_message_w;

logic RS_r, RS_w;
logic RW_r, RW_w;
logic EN_r, EN_w;
logic BF_r, BF_w;

logic [31:0]  counter_r, counter_w;             // counter for waiting
logic [1:0]   end_init_flag_r, end_init_flag_w;
logic [255:0] display_data_r, display_data_w;   // save data to display
logic [7:0]   send_data_r, send_data_w;         // data to send (for WriteData)

assign o_LCD_RW = RW_r;
assign o_LCD_RS = RS_r;
assign o_LCD_DATA = (state_r == S_CHECK_BF) ? 8'bz : data_r;
assign o_LCD_EN = EN_r;
assign o_finish_init = (end_init_flag_r == I_FINISH);
assign o_state = state_r;
assign BF_w = (state_r == S_CHECK_BF && o_LCD_EN) ? o_LCD_DATA[7] : 1;

//////////////// debug //////////////////////


logic show_r, show_w;
logic [10:0] bf_counter_r, bf_counter_w;
assign o_show = state_r;
always_comb begin
	if (state_r > bf_counter_r) bf_counter_w = state_r;
	else bf_counter_w = bf_counter_r;
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		show_r <= 0;
		bf_counter_r <= 0;
	end else begin
		show_r <= show_w;
		bf_counter_r <= bf_counter_w;
	end
end

//////////////// end of debug //////////////


task InitFunc1;
	begin
		RS_w = 0;
		RW_w = 0;
		data_w = 8'b0011_1000;
	end
endtask

task InitFunc2;
	begin
		RS_w = 0;
		RW_w = 0;
		data_w = 8'b0011_1000;
	end
endtask

task InitDisplayOn;
	begin
		RS_w = 0;
		RW_w = 0;
		data_w = 8'b0000_1100;
	end
endtask

task InitDisplayClear;
	begin
		RS_w = 0;
		RW_w = 0;
		data_w = 8'b0000_0001;
	end
endtask

task InitEntryMode;
	begin
		RS_w = 0;
		RW_w = 0;
		data_w = 8'b0000_0110;
	end
endtask

task InitBubble;
	begin
		RS_w = 0;
		RW_w = 1;
		data_w = 8'b0000_0000;
	end
endtask

task CheckBF;
	begin
		RS_w = 0;
		RW_w = 1;
		data_w = 8'bz;
	end
endtask

task SetAddr;
	input [6:0] addr;
	begin
		RS_w = 0;
		RW_w = 0;

		// valid addr 
		// first row from 00 ~ 0F
		// second row from 40 ~ 4F
		if (addr[4]) begin
			data_w = {1'b1, 3'b100, addr[3:0]};
		end
		else begin
		data_w = {1'b1, addr};
		end
	end
endtask

task WriteData;
	input [7:0] data;
	begin
		RS_w = 1;
		RW_w = 0;
		data_w = data;
	end
endtask

task InsertBubble;
	begin
		RS_w = 0;
		RW_w = 0;
		data_w = 8'b0000_0000;
	end
endtask

task MoveAddr;
	begin
		if (addr_counter_r == 7'h1f) addr_counter_w = 7'h00;
		else addr_counter_w = addr_counter_r+1;
	end
endtask

always_comb begin
	i_message_w = i_message;
end

logic [255:0] cg_output;
logic [7:0]   cg_input;

CG characterGenerator (
	.i_message(cg_input),
	.o_string (cg_output)
);

// display control
always_comb begin
	if (end_init_flag_r) begin
		cg_input = i_message;
	end
	else begin
		cg_input = 8'b1111_1111; // all clear
	end

	display_data_w = cg_output;
end


// counter
// use for waiting initializing
always_comb begin
	counter_w = counter_r;
	case (state_r)
		S_WAIT_15: begin
			if (counter_r == COUNT_WAIT_15) begin
				counter_w = 0;
			end
			else begin
				counter_w = counter_r + 1;
			end
		end
		S_WAIT_41: begin
			if (counter_r == COUNT_WAIT_41) begin
				counter_w = 0;
			end
			else begin
				counter_w = counter_r + 1;
			end
		end
		S_WAIT_100: begin
			if (counter_r == COUNT_WAIT_100) begin
				counter_w = 0;
			end
			else begin
				counter_w = counter_r + 1;
			end
		end
		S_WAIT_1: begin
			if (counter_r == COUNT_WAIT_1) begin
				counter_w = 0;
			end
			else begin
				counter_w = counter_r + 1;
			end
		end
		default: begin
			counter_w = 0;
		end
	endcase
end

// FSM
always_comb begin
	state_w = state_r;
	next_state_w = next_state_r;
	substate_w = substate_r;
	case (state_r)
		S_IDLE: begin
			state_w = S_SET_ADDR;
		end
		S_WAIT_15: begin
			if (counter_r == COUNT_WAIT_15) begin
				state_w = S_INIT_FUNC_1;
				next_state_w = S_WAIT_41;
			end
			else begin
				state_w = S_WAIT_15;
			end
		end
		S_WAIT_41: begin
			if (counter_r == COUNT_WAIT_41) begin
				state_w = S_INIT_FUNC_1;
				next_state_w = S_WAIT_100;
			end
			else begin
				state_w = S_WAIT_41;
			end
		end
		S_WAIT_100: begin
			if (counter_r == COUNT_WAIT_100) begin
				state_w = S_INIT_FUNC_1;
				next_state_w = S_WAIT_1;
			end
			else begin
				state_w = S_WAIT_100;
			end
		end
		S_WAIT_1: begin
			if (counter_r == COUNT_WAIT_1) begin
				state_w = S_INIT_FUNC_2;
			end
			else begin
				state_w = S_WAIT_1;
			end
		end
		S_INIT_FUNC_1: begin
			case (substate_r)
				S_SUB_SET: begin
					state_w = S_INIT_FUNC_1;
					substate_w = S_SUB_EN;
				end
				S_SUB_EN: begin
					state_w = next_state_r;
					substate_w = S_SUB_SET;
				end
				default: begin
					state_w = S_INIT_FUNC_1;
					substate_w = S_SUB_SET;
				end
			endcase
		end
		S_INIT_FUNC_2: begin
			case (substate_r)
				S_SUB_SET: begin
					state_w = S_INIT_FUNC_2;
					substate_w = S_SUB_EN;
				end
				S_SUB_EN: begin
					state_w = S_CHECK_BF;
					substate_w = S_SUB_SET;
					next_state_w = S_INIT_DISPLAY_ON;
				end
				default: begin
					state_w = S_INIT_FUNC_2;
					substate_w = S_SUB_SET;
				end
			endcase
		end
		S_INIT_DISPLAY_ON: begin
			case (substate_r)
				S_SUB_SET: begin
					state_w = S_INIT_DISPLAY_ON;
					substate_w = S_SUB_EN;
				end
				S_SUB_EN: begin
					state_w = S_CHECK_BF;
					substate_w = S_SUB_SET;
					next_state_w = S_INIT_DISPLAY_CLEAR;
				end
				default: begin
					state_w = S_INIT_DISPLAY_ON;
					substate_w = S_SUB_SET;
				end
			endcase
		end
		S_INIT_DISPLAY_CLEAR: begin
			case (substate_r)
				S_SUB_SET: begin
					state_w = S_INIT_DISPLAY_CLEAR;
					substate_w = S_SUB_EN;
				end
				S_SUB_EN: begin
					state_w = S_CHECK_BF;
					substate_w = S_SUB_SET;
					next_state_w = S_INIT_ENTRY_MODE;
				end
				default: begin
					state_w = S_INIT_DISPLAY_CLEAR;
					substate_w = S_SUB_SET;
				end
			endcase
		end
		S_INIT_ENTRY_MODE: begin
			case (substate_r)
				S_SUB_SET: begin
					state_w = S_INIT_ENTRY_MODE;
					substate_w = S_SUB_EN;
				end
				S_SUB_EN: begin
					state_w = S_CHECK_BF;
					substate_w = S_SUB_SET;
					next_state_w = S_SET_ADDR;
				end
				default: begin
					state_w = S_INIT_ENTRY_MODE;
					substate_w = S_SUB_SET;
				end
			endcase
		end
		S_SET_ADDR: begin
			case (substate_r)
				S_SUB_SET: begin
					state_w = S_SET_ADDR;
					substate_w = S_SUB_EN;
				end
				S_SUB_EN: begin
					state_w = S_CHECK_BF;
					substate_w = S_SUB_SET;
					next_state_w = S_WRITE_DATA;
				end
				default: begin
					state_w = S_SET_ADDR;
					substate_w = S_SUB_SET;
				end
			endcase
		end
		S_WRITE_DATA: begin
			case (substate_r)
				S_SUB_SET: begin
					state_w = S_WRITE_DATA;
					substate_w = S_SUB_EN;
				end
				S_SUB_EN: begin
					state_w = S_CHECK_BF;
					substate_w = S_SUB_SET;
					// if (addr_counter_r != 7'h1f) begin
					// 	next_state_w = S_SET_ADDR;
					// end
					// else begin
					// 	next_state_w = S_IDLE;
					// end
					next_state_w = S_SET_ADDR;
				end
				default: begin
					state_w = S_WRITE_DATA;
					substate_w = S_SUB_SET;
				end
			endcase
		end
		S_CHECK_BF: begin
			case (substate_r)
				S_SUB_SET: begin
					state_w = S_CHECK_BF;
					substate_w = S_SUB_EN;
				end
				S_SUB_EN: begin
					// if (BF_r && ~BF_w) begin
					if (~BF_w) begin // FIXME
						state_w = next_state_r;
						substate_w = S_SUB_SET;
					end
					else begin
						state_w = S_CHECK_BF;
						substate_w = S_SUB_SET;
					end
				end
				default: begin
					state_w = S_CHECK_BF;
					substate_w = S_SUB_SET;
				end
			endcase
		end
	endcase

end

// main logic
// en = 1 only when substate == S_SUB_EN
always_comb begin
	RS_w = RS_r;
	RW_w = RW_r;
	data_w = data_r;
	EN_w = 0;
	addr_counter_w = addr_counter_r;
	send_data_w = send_data_r;
	case (state_r)
		S_IDLE: begin
			InsertBubble;
		end
		S_WAIT_15: begin
			if (counter_r == COUNT_WAIT_15) begin
				InitFunc1;
			end
		end
		S_WAIT_41: begin
			if (counter_r == COUNT_WAIT_41) begin
				InitFunc1;
			end
		end
		S_WAIT_100: begin
			if (counter_r == COUNT_WAIT_100) begin
				InitFunc1;
			end
		end
		S_WAIT_1: begin
			if (counter_r == COUNT_WAIT_1) begin
				InitFunc2;
			end
		end
		S_INIT_FUNC_1: begin
			if (substate_r == S_SUB_SET) begin
				EN_w = 1;
				InitFunc1;
			end
		end
		S_INIT_FUNC_2: begin
			if (substate_r == S_SUB_SET) begin
				InitFunc2;
				EN_w = 1;
			end
			else if (substate_r == S_SUB_EN) begin
				CheckBF;
			end
		end
		S_INIT_DISPLAY_ON: begin
			if (substate_r == S_SUB_SET) begin
				EN_w = 1;
				InitDisplayOn;
			end
			else if (substate_r == S_SUB_EN) begin
				EN_w = 0;
				CheckBF;
			end
		end
		S_INIT_DISPLAY_CLEAR: begin
			if (substate_r == S_SUB_SET) begin
				EN_w = 1;
				InitDisplayClear;
			end
			else if (substate_r == S_SUB_EN) begin
				EN_w = 0;
				CheckBF;
			end
		end
		S_INIT_ENTRY_MODE: begin
			if (substate_r == S_SUB_SET) begin
				EN_w = 1;
				InitEntryMode;
			end
			else if (substate_r == S_SUB_EN) begin
				EN_w = 0;
				CheckBF;
			end

		end
		S_SET_ADDR: begin
			if (substate_r == S_SUB_SET) begin
				EN_w = 1;
				SetAddr(addr_counter_r);
			end
			else if (substate_r == S_SUB_EN) begin
				EN_w = 0;
				CheckBF;
				send_data_w = display_data_r[(addr_counter_r<<3)+:8]; // prepare data for S_WRITE_DATA, reverse
			end
		end
		S_WRITE_DATA: begin
			if (substate_r == S_SUB_SET) begin
				EN_w = 1;
				WriteData(send_data_r);
				MoveAddr;
			end
			else if (substate_r == S_SUB_EN) begin
				EN_w = 0;
				CheckBF;
			end
		end
		S_CHECK_BF: begin // FIXME

			if (substate_r == S_SUB_SET) begin
				EN_w = 1;
				CheckBF;
			end
			else if (substate_r == S_SUB_EN) begin
				EN_w = 0;
				if (~BF_w) begin
					case (next_state_r)
						S_IDLE: InsertBubble;
						S_INIT_DISPLAY_ON: InitDisplayOn;
						S_INIT_DISPLAY_CLEAR: InitDisplayClear;
						S_INIT_ENTRY_MODE: InitEntryMode;
						S_SET_ADDR: SetAddr(addr_counter_r);
						S_WRITE_DATA: WriteData(send_data_r);
					endcase
				end
				else begin
					CheckBF;
				end
			end
		end
	endcase

end

// end init flag
// set entry mode is the last init step
// after checking BF, init finish
always_comb begin
	end_init_flag_w = end_init_flag_r;
	if (state_r == S_INIT_ENTRY_MODE) begin
		end_init_flag_w = I_LAST_STEP;
	end
	else if (state_r == S_CHECK_BF) begin
		if (end_init_flag_r == I_LAST_STEP) end_init_flag_w = I_FINISH;
	end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if(~i_rst_n) begin
		state_r <= S_WAIT_15;
		substate_r <= S_SUB_SET;
		next_state_r <= S_WAIT_15;
		counter_r <= 0;
		addr_counter_r <= 0;
		data_r <= 0;
		RS_r <= 0;
		RW_r <= 0;
		BF_r <= 1;
		EN_r <= 0;
		end_init_flag_r <= I_INITIATING;
		display_data_r <= 256'd0;
		send_data_r <= 0;
		i_message_r <= 0;
	end else begin
		state_r <= state_w;
		substate_r <= substate_w;
		next_state_r <= next_state_w;
		counter_r <= counter_w;
		addr_counter_r <= addr_counter_w;
		data_r <= data_w;
		RS_r <= RS_w;
		RW_r <= RW_w;
		BF_r <= BF_w;
		EN_r <= EN_w;
		end_init_flag_r <= end_init_flag_w;
		display_data_r <= display_data_w;
		send_data_r <= send_data_w;
		i_message_r <= i_message_w;
	end
end

endmodule