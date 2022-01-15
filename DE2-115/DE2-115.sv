`resetall
`timescale 1ns / 1ps
`default_nettype none

`include "../src/VGA/VGA_Param.h"
`include "config.h"

module DE2_115 (
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,

	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [7:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO,
    
    // GPIO
    input		    [11:0]		D5M_D,
    input		          		D5M_FVAL,
    input		          		D5M_LVAL,
    input		          		D5M_PIXLCLK,
    output		          		D5M_RESET_N,
    output		          		D5M_SCLK,
    inout		          		D5M_SDATA,
    input		          		D5M_STROBE,
    output		          		D5M_TRIGGER,
    output		          		D5M_XCLKIN
);

//=======================================================
// LOGIC declarations
//=======================================================
logic	[15:0]	Read_DATA1;
logic	[15:0]	Read_DATA2;

logic	[11:0]	mCCD_DATA;
logic			mCCD_DVAL;
logic			mCCD_DVAL_d;
logic	[15:0]	X_Cont;
logic	[15:0]	Y_Cont;
logic	[9:0]	X_ADDR;
logic	[31:0]	Frame_Cont;
logic			DLY_RST_0;
logic			DLY_RST_1;
logic			DLY_RST_2;
logic			DLY_RST_3;
logic			DLY_RST_4;
logic			Read;
logic	[11:0]	rCCD_DATA;
logic			rCCD_LVAL;
logic				rCCD_FVAL;
logic	[11:0]	sCCD_R;
logic	[11:0]	sCCD_G;
logic	[11:0]	sCCD_B;
logic			sCCD_DVAL;

logic			sdram_ctrl_clk;
logic	[9:0]	oVGA_R;   				//	VGA Red[9:0]
logic	[9:0]	oVGA_G;	 				//	VGA Green[9:0]
logic	[9:0]	oVGA_B;   				//	VGA Blue[9:0]

// power on start
logic             auto_start;

// different clock signal
logic clk_800k, clk_25M, clk_40M, clk_75M, clk_120M, clk_100M;

// input of SDRAM
logic [9:0] SDRAM_W_G;
logic [9:0] SDRAM_W_B;
logic [9:0] SDRAM_W_R;
logic SDRAM_W_clk, SDRAM_W_en;

// LCD
logic [7:0] lcd_message;
logic lcd_finish_init;

// VGA DISPLAY
logic [9:0] i_VGA_R, i_VGA_G, i_VGA_B;
logic VGA_request;

// DCP
logic [9:0] R_out, G_out, B_out;
logic [17:0] debug;

// ethernet data bus
logic 		 ethernet_clk; 		// idk WTF is this
logic 		 ethernet_clk90; 	// idk WTF is this
logic 		 ethernet_rst; 		// idk WTF is this
logic [7:0]  ethernet_data;
logic        ethernet_valid;
logic        ethernet_last;
logic [31:0] ethernet_dest_ip;

logic 	eth_pll_rst;
assign 	eth_pll_rst = ~KEY[1];
logic 	eth_pll_locked;

// ethernet parser
logic [7:0] test_len;
logic [7:0] test_last_byte, test_first_byte;
logic [7:0] eth_channel_R, eth_channel_G, eth_channel_B;
logic 		eth_channel_valid;

// use LEDG to debug (ethernet)
// assign LEDG = SW[10] ? (SW[11] ? test_last_byte : test_first_byte) : test_len;
assign LEDR	= SW;

//=======================================================
//  Structural coding
//=======================================================
// D5M

logic VGA_CTRL_CLK;
assign	D5M_TRIGGER	=	1'b1;  // tRIGGER
assign	D5M_RESET_N	=	DLY_RST_1;
assign  VGA_CTRL_CLK = ~VGA_CLK;

// assign	LEDG		=	Y_Cont;
assign	UART_TXD = UART_RXD;

//fetch the high 8 bits

assign  VGA_R = oVGA_R[9:2];
assign  VGA_G = oVGA_G[9:2];
assign  VGA_B = oVGA_B[9:2];

//D5M read 
always@(posedge D5M_PIXLCLK)
begin
	rCCD_DATA	<=	D5M_D;
	rCCD_LVAL	<=	D5M_LVAL;
	rCCD_FVAL	<=	D5M_FVAL;
end



//Reset module
Reset_Delay	u2(
	.iCLK(CLOCK2_50),
	.iRST(KEY[0]),
	.oRST_0(DLY_RST_0),
	.oRST_1(DLY_RST_1),
	.oRST_2(DLY_RST_2),
	.oRST_3(DLY_RST_3),
	.oRST_4(DLY_RST_4)
);


`ifdef CAMERA

// D5M raw date convert to RGB data (uncomment it if you want to use cammera module)
`ifdef VGA_640x480p60
	RAW2RGB	u4(	
		.iCLK(D5M_PIXLCLK),
		.iRST(DLY_RST_1),
		.iDATA(mCCD_DATA),
		.iDVAL(mCCD_DVAL),
		.oRed(sCCD_R),
		.oGreen(sCCD_G),
		.oBlue(sCCD_B),
		.oDVAL(sCCD_DVAL),
		.iX_Cont(X_Cont),
		.iY_Cont(Y_Cont)
	);
`else
	RAW2RGB	u4(
		.iCLK(D5M_PIXLCLK),
		.iRST_n(DLY_RST_1),
		.iData(mCCD_DATA),
		.iDval(mCCD_DVAL),
		.oRed(sCCD_R),
		.oGreen(sCCD_G),
		.oBlue(sCCD_B),
		.oDval(sCCD_DVAL),
		.iZoom(SW[16]),
		.iX_Cont(X_Cont),
		.iY_Cont(Y_Cont)
	);
`endif

// auto start when power on
assign auto_start = ((KEY[0])&&(DLY_RST_3)&&(!DLY_RST_4))? 1'b1:1'b0;

// D5M image capture (uncomment it if you want to use cammera module)
CCD_Capture	u3(	
	.oDATA(mCCD_DATA),
	.oDVAL(mCCD_DVAL),
	.oX_Cont(X_Cont),
	.oY_Cont(Y_Cont),
	.oFrame_Cont(Frame_Cont),
	.iDATA(rCCD_DATA),
	.iFVAL(rCCD_FVAL),
	.iLVAL(rCCD_LVAL),
	.iSTART(!KEY[3]|auto_start),
	.iEND(!KEY[2]),
	.iCLK(~D5M_PIXLCLK),
	.iRST(DLY_RST_2)
);

`endif

sdram_pll u6(
	.inclk0(CLOCK2_50),
	.c0(sdram_ctrl_clk),
	.c1(DRAM_CLK),
	.c2(D5M_XCLKIN), //25M
	.c3(clk_25M),     //25M 
	.c4(clk_40M)     //40M 	
);

VGA_pll pll(
	.clk_clk(CLOCK_50),
	.clk_100m_clk(clk_100M),
	.clk_120m_clk(clk_120M),
	.clk_75m_clk(clk_75M),
	.clk_800k_clk(clk_800k),
	.reset_reset_n(KEY[0])
);

`ifdef VGA_640x480p60
	assign VGA_CLK = clk_25M;
`else
	assign VGA_CLK = clk_40M;
`endif

// Choose the image source (from camera or ethernet)
`ifdef CAMERA
// from camera
assign SDRAM_W_G = sCCD_G[11:2];
assign SDRAM_W_B = sCCD_B[11:2];
assign SDRAM_W_R = sCCD_R[11:2];
assign SDRAM_W_clk = D5M_PIXLCLK;
assign SDRAM_W_en  = sCCD_DVAL;
`else
// from ethernet
assign SDRAM_W_G = {eth_channel_G, 2'b00};
assign SDRAM_W_B = {eth_channel_B, 2'b00};
assign SDRAM_W_R = {eth_channel_R, 2'b00};
assign SDRAM_W_clk = ethernet_clk;
assign SDRAM_W_en  = eth_channel_valid;
`endif


//SDRam Read and Write as Frame Buffer
Sdram_Control u7(	//	HOST Side						
	.RESET_N(KEY[0]),
	.CLK(clk_100M),

	//FIFO Write Side 1
	.WR1_DATA({1'b0, SDRAM_W_G[9:5], SDRAM_W_B}), // 
	.WR1(SDRAM_W_en),
	.WR1_ADDR(23'h000000),
	`ifdef VGA_640x480p60
		.WR1_MAX_ADDR(23'h000000+640*480/2),
		.WR1_LENGTH(8'h50),
	`else
		.WR1_MAX_ADDR(23'h000000+800*600/2),
		.WR1_LENGTH(8'h80),
	`endif							
	.WR1_LOAD(!DLY_RST_0),
	.WR1_CLK(SDRAM_W_clk),

							
	//	FIFO Write Side 2
	.WR2_DATA({1'b0, SDRAM_W_G[4:0], SDRAM_W_R}), // 
	.WR2(SDRAM_W_en),
	.WR2_ADDR(23'h200000),
	`ifdef VGA_640x480p60
		.WR2_MAX_ADDR(23'h200000+640*480/2),
		.WR2_LENGTH(8'h50),			
	`else							
		.WR2_MAX_ADDR(23'h200000+800*600/2),
		.WR2_LENGTH(8'h80),
	`endif	
	.WR2_LOAD(!DLY_RST_0),
	.WR2_CLK(SDRAM_W_clk),

	//	FIFO Read Side 1
	.RD1_DATA(Read_DATA1),
	.RD1(Read),
	.RD1_ADDR(23'h000000),
	`ifdef VGA_640x480p60
		.RD1_MAX_ADDR(23'h000000+640*480/2),
		.RD1_LENGTH(8'h50),
	`else
		.RD1_MAX_ADDR(23'h000000+800*600/2),
		.RD1_LENGTH(8'h80),
	`endif
	.RD1_LOAD(!DLY_RST_0),
	.RD1_CLK(~VGA_CTRL_CLK),
							
	//	FIFO Read Side 2
	.RD2_DATA(Read_DATA2),
	.RD2(Read),
	.RD2_ADDR(23'h200000),
	`ifdef VGA_640x480p60
		.RD2_MAX_ADDR(23'h200000+640*480/2),
		.RD2_LENGTH(8'h50),
	`else
		.RD2_MAX_ADDR(23'h200000+800*600/2),
		.RD2_LENGTH(8'h80),
	`endif
	.RD2_LOAD(!DLY_RST_0),
	.RD2_CLK(~VGA_CTRL_CLK),
							
	//	SDRAM Side
	.SA(DRAM_ADDR),
	.BA(DRAM_BA),
	.CS_N(DRAM_CS_N),
	.CKE(DRAM_CKE),
	.RAS_N(DRAM_RAS_N),
	.CAS_N(DRAM_CAS_N),
	.WE_N(DRAM_WE_N),
	.DQ(DRAM_DQ),
	.DQM(DRAM_DQM)
);

// D5M I2C control
I2C_CCD_Config u8(	
	//Host Side
	.iCLK(CLOCK2_50),
	.iRST_N(DLY_RST_2),
	.iEXPOSURE_ADJ(KEY[1]),
	.iEXPOSURE_DEC_p(SW[0]),
	.iZOOM_MODE_SW(SW[16]),
	//I2C Side
	.I2C_SCLK(D5M_SCLK),
	.I2C_SDAT(D5M_SDATA)
);

logic [7:0] display_option;
assign display_option = {6'b0, SW[2], SW[1]};

// uncomment it if you want to use LCD
LCD lcd(
	.i_clk      (clk_800k),
	.i_rst_n    (KEY[1]),
	.i_message  (display_option),
	.o_LCD_DATA (LCD_DATA),
	.o_LCD_EN   (LCD_EN),
	.o_LCD_RS   (LCD_RS),
	.o_LCD_RW   (LCD_RW),
	.o_LCD_ON   (LCD_ON),
	.o_LCD_BLON (LCD_BLON),
	.o_finish_init(lcd_finish_init)
);


assign i_VGA_R = R_out;
assign i_VGA_G = G_out;
assign i_VGA_B = B_out;

VGA_Controller u1(	
	//	Host Side
	.oRequest(VGA_request),
	// .iRed(Read_DATA2[9:0]),
	// .iGreen({Read_DATA1[14:10],Read_DATA2[14:10]}),
	// .iBlue(Read_DATA1[9:0]),
	.iRed(i_VGA_R),
	.iGreen(i_VGA_G),
	.iBlue(i_VGA_B),
	//	VGA Side
	.oVGA_R(oVGA_R),
	.oVGA_G(oVGA_G),
	.oVGA_B(oVGA_B),
	.oVGA_H_SYNC(VGA_HS),
	.oVGA_V_SYNC(VGA_VS),
	.oVGA_SYNC(VGA_SYNC_N),
	.oVGA_BLANK(VGA_BLANK_N),
	//	Control Signal
	.iCLK(VGA_CTRL_CLK),
	.iRST_N(DLY_RST_2),
	.iZOOM_MODE_SW(SW[16])
);

// assign LEDR = debug;
DCP DCP_CORE(
	.i_clk(clk_100M), // change from sdram_ctrl_clk to clk_100M, functionality is the same
	.i_rst_n(KEY[0]), 
	.i_in_valid(sCCD_DVAL), 
	.i_RED_data(Read_DATA2[9:0]), 
	.i_GREEN_data({Read_DATA1[14:10],Read_DATA2[14:10]}), 
	.i_BLUE_data(Read_DATA1[9:0]),
	.i_VGA_request(VGA_request),
	.i_display_option(display_option),
	.o_SDRAM_read(Read),
	.R_data_out(R_out),
	.G_data_out(G_out),
	.B_data_out(B_out),
	// .debug_LED({LEDR, LEDG}) // for debug use
);

altpll #(
    .bandwidth_type("AUTO"),
    .clk0_divide_by(2),
    .clk0_duty_cycle(50),
    .clk0_multiply_by(5),
    .clk0_phase_shift("0"),
    .clk1_divide_by(2),
    .clk1_duty_cycle(50),
    .clk1_multiply_by(5),
    .clk1_phase_shift("2000"),
    .compensate_clock("CLK0"),
    .inclk0_input_frequency(20000),
    .intended_device_family("Cyclone IV E"),
    .operation_mode("NORMAL"),
    .pll_type("AUTO"),
    .port_activeclock("PORT_UNUSED"),
    .port_areset("PORT_USED"),
    .port_clkbad0("PORT_UNUSED"),
    .port_clkbad1("PORT_UNUSED"),
    .port_clkloss("PORT_UNUSED"),
    .port_clkswitch("PORT_UNUSED"),
    .port_configupdate("PORT_UNUSED"),
    .port_fbin("PORT_UNUSED"),
    .port_inclk0("PORT_USED"),
    .port_inclk1("PORT_UNUSED"),
    .port_locked("PORT_USED"),
    .port_pfdena("PORT_UNUSED"),
    .port_phasecounterselect("PORT_UNUSED"),
    .port_phasedone("PORT_UNUSED"),
    .port_phasestep("PORT_UNUSED"),
    .port_phaseupdown("PORT_UNUSED"),
    .port_pllena("PORT_UNUSED"),
    .port_scanaclr("PORT_UNUSED"),
    .port_scanclk("PORT_UNUSED"),
    .port_scanclkena("PORT_UNUSED"),
    .port_scandata("PORT_UNUSED"),
    .port_scandataout("PORT_UNUSED"),
    .port_scandone("PORT_UNUSED"),
    .port_scanread("PORT_UNUSED"),
    .port_scanwrite("PORT_UNUSED"),
    .port_clk0("PORT_USED"),
    .port_clk1("PORT_USED"),
    .port_clk2("PORT_UNUSED"),
    .port_clk3("PORT_UNUSED"),
    .port_clk4("PORT_UNUSED"),
    .port_clk5("PORT_UNUSED"),
    .port_clkena0("PORT_UNUSED"),
    .port_clkena1("PORT_UNUSED"),
    .port_clkena2("PORT_UNUSED"),
    .port_clkena3("PORT_UNUSED"),
    .port_clkena4("PORT_UNUSED"),
    .port_clkena5("PORT_UNUSED"),
    .port_extclk0("PORT_UNUSED"),
    .port_extclk1("PORT_UNUSED"),
    .port_extclk2("PORT_UNUSED"),
    .port_extclk3("PORT_UNUSED"),
    .self_reset_on_loss_lock("ON"),
    .width_clock(5)
)
altpll_component (
    .areset(eth_pll_rst),
    .inclk({1'b0, CLOCK_50}),
    .clk({ethernet_clk90, ethernet_clk}),
    .locked(eth_pll_locked),
    .activeclock(),
    .clkbad(),
    .clkena({6{1'b1}}),
    .clkloss(),
    .clkswitch(1'b0),
    .configupdate(1'b0),
    .enable0(),
    .enable1(),
    .extclk(),
    .extclkena({4{1'b1}}),
    .fbin(1'b1),
    .fbmimicbidir(),
    .fbout(),
    .fref(),
    .icdrclk(),
    .pfdena(1'b1),
    .phasecounterselect({4{1'b1}}),
    .phasedone(),
    .phasestep(1'b1),
    .phaseupdown(1'b1),
    .pllena(1'b1),
    .scanaclr(1'b0),
    .scanclk(1'b0),
    .scanclkena(1'b1),
    .scandata(1'b0),
    .scandataout(),
    .scandone(),
    .scanread(1'b0),
    .scanwrite(1'b0),
    .sclkout0(),
    .sclkout1(),
    .vcooverrange(),
    .vcounderrange()
);

sync_reset #(.N(4)) sync_reset_inst (
    .clk(ethernet_clk),
    .rst(~eth_pll_locked),
    .out(ethernet_rst)
);

`ifdef CAMERA
// Frame count display 
SEG7_LUT_8 	u5(
	.oSEG0(HEX0),
	.oSEG1(HEX1),
	.oSEG2(HEX2),
	.oSEG3(HEX3),
	.oSEG4(HEX4),
	.oSEG5(HEX5),
	.oSEG6(HEX6),
	.oSEG7(HEX7),
	.iDIG(Frame_Cont[31:0])
);
`else
// display the sender's-IP on seven hex decoder
hex_display inst0(
    .in(ethernet_dest_ip[3:0]),
    .enable(1),
    .out(HEX0)
);
hex_display inst1(
    .in(ethernet_dest_ip[7:4]),
    .enable(1),
    .out(HEX1)
);
hex_display inst2(
    .in(ethernet_dest_ip[11:8]),
    .enable(1),
    .out(HEX2)
);
hex_display inst3(
    .in(ethernet_dest_ip[15:12]),
    .enable(1),
    .out(HEX3)
);
hex_display inst4(
    .in(ethernet_dest_ip[19:16]),
    .enable(1),
    .out(HEX4)
);
hex_display inst5(
    .in(ethernet_dest_ip[23:20]),
    .enable(1),
    .out(HEX5)
);
hex_display inst6(
    .in(ethernet_dest_ip[27:24]),
    .enable(1),
    .out(HEX6)
);
hex_display inst7(
    .in(ethernet_dest_ip[31:28]),
    .enable(1),
    .out(HEX7)
);
`endif
Ethernet_connection #(.TARGET("ALTERA")) core_inst (
    // Clock: 125MHz
    // Synchronous reset
    .i_clk(ethernet_clk),
	.i_clk90(ethernet_clk90),
    .rst(ethernet_rst),

    // output
    .o_udp_rx_valid(ethernet_valid),
    .o_udp_rx_data(ethernet_data),
    .o_udp_rx_last(ethernet_last),
    .o_ethernet_dest_ip(ethernet_dest_ip),

    // Ethernet: 1000BASE-T RGMII
    .phy0_rx_clk(ENET0_RX_CLK),
    .phy0_rxd(ENET0_RX_DATA),
    .phy0_rx_ctl(ENET0_RX_DV),
    .phy0_tx_clk(ENET0_GTX_CLK),
    .phy0_txd(ENET0_TX_DATA),
    .phy0_tx_ctl(ENET0_TX_EN),
    .phy0_reset_n(ENET0_RST_N),
    .phy0_int_n(ENET0_INT_N)
);


// Choose one parser to use !!
`ifdef RGB16
UDP_parser_RGB16 udp_inst(
    .i_clk          (ethernet_clk),
	// .i_clk_90		(),
    .i_rst_n        (!ethernet_rst),

    .i_udp_rx_valid (ethernet_valid),
    .i_udp_rx_last  (ethernet_last),
    .i_udp_rx_data  (ethernet_data),

    .o_channel_B    (eth_channel_B),
    .o_channel_G    (eth_channel_G),
    .o_channel_R    (eth_channel_R),
    .o_valid        (eth_channel_valid),

    .o_test_len         (test_len),
    .o_test_last_byte   (test_last_byte),
    .o_test_first_byte  (test_first_byte)
);
`else
UDP_parser_RGB24 udp_inst(
    .i_clk          (ethernet_clk),
	// .i_clk_90		(),
    .i_rst_n        (!ethernet_rst),

    .i_udp_rx_valid (ethernet_valid),
    .i_udp_rx_last  (ethernet_last),
    .i_udp_rx_data  (ethernet_data),

    .o_channel_B    (eth_channel_B),
    .o_channel_G    (eth_channel_G),
    .o_channel_R    (eth_channel_R),
    .o_valid        (eth_channel_valid),

    .o_test_len         (test_len),
    .o_test_last_byte   (test_last_byte),
    .o_test_first_byte  (test_first_byte)
);
`endif

endmodule

`resetall
