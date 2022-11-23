// ============================================================================
// Copyright (c) 2015 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Tue Apr  7 10:19:47 2015
// ============================================================================

`define ENABLE_DDR3

module gsensor_lightsensor_lcd(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,
	input 		          		MAX10_CLK3_50,

	//////////// KEY //////////
	input 		          		FPGA_RESET_n,
	input 		     [4:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// LEDR //////////
	output		     [9:0]		LEDR,

	//////////// HEX //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,

	//////////// Audio //////////
	inout 		          		AUDIO_BCLK,
	output		          		AUDIO_DIN_MFP1,
	input 		          		AUDIO_DOUT_MFP2,
	inout 		          		AUDIO_GPIO_MFP5,
	output		          		AUDIO_MCLK,
	input 		          		AUDIO_MISO_MFP4,
	inout 		          		AUDIO_RESET_n,
	output		          		AUDIO_SCL_SS_n,
	output		          		AUDIO_SCLK_MFP3,
	inout 		          		AUDIO_SDA_MOSI,
	output		          		AUDIO_SPI_SELECT,
	inout 		          		AUDIO_WCLK,

	//////////// DAC //////////
	inout 		          		DAC_DATA,
	output		          		DAC_SCLK,
	output		          		DAC_SYNC_n,

`ifdef ENABLE_DDR3
	//////////// DDR3 SDRAM //////////
	output		    [14:0]		DDR3_A,
	output		     [2:0]		DDR3_BA,
	output		          		DDR3_CAS_n,
	inout 		          		DDR3_CK_n,
	inout 		          		DDR3_CK_p,
	output		          		DDR3_CKE,
	output		          		DDR3_CS_n,
	output		     [2:0]		DDR3_DM,
	inout 		    [23:0]		DDR3_DQ,
	inout 		     [2:0]		DDR3_DQS_n,
	inout 		     [2:0]		DDR3_DQS_p,
	output		          		DDR3_ODT,
	output		          		DDR3_RAS_n,
	output		          		DDR3_RESET_n,
	output		          		DDR3_WE_n,
`endif /*ENABLE_DDR3*/

	//////////// QSPI Flash //////////
	inout 		     [3:0]		FLASH_DATA,
	output		          		FLASH_DCLK,
	output		          		FLASH_NCSO,
	output		          		FLASH_RESET_n,

	//////////// G-Sensor //////////
	output		          		GSENSOR_CS_n,
	input 		     [2:1]		GSENSOR_INT,
	inout 		          		GSENSOR_SCLK,
	inout 		          		GSENSOR_SDI,
	inout 		          		GSENSOR_SDO,

	//////////// HDMI-RX //////////
	input 		          		HDMI_AP,
	inout 		          		HDMI_I2C_SCL,
	inout 		          		HDMI_I2C_SDA,
	inout 		          		HDMI_LRCLK,
	inout 		          		HDMI_MCLK,
	input 		          		HDMI_RX_CLK,
	input 		    [23:0]		HDMI_RX_D,
	input 		          		HDMI_RX_DE,
	inout 		          		HDMI_RX_HS,
	input 		          		HDMI_RX_INT1,
	inout 		          		HDMI_RX_RESET_n,
	input 		          		HDMI_RX_VS,
	inout 		          		HDMI_SCLK,

	//////////// Light Sensor //////////
	inout 		          		LSENSOR_INT,
	output		          		LSENSOR_SCL,
	inout 		          		LSENSOR_SDA,

	//////////// MIPI CS2 Camera //////////
	output		          		CAMERA_I2C_SCL,
	inout 		          		CAMERA_I2C_SDA,
	inout 		          		CAMERA_PWDN_n,
	output		          		MIPI_CS_n,
	output		          		MIPI_I2C_SCL,
	inout 		          		MIPI_I2C_SDA,
	input 		          		MIPI_PIXEL_CLK,
	input 		    [23:0]		MIPI_PIXEL_D,
	input 		          		MIPI_PIXEL_HS,
	input 		          		MIPI_PIXEL_VS,
	output		          		MIPI_REFCLK,
	output		          		MIPI_RESET_n,

	//////////// MTL2 //////////
	output		     [7:0]		MTL2_B,
	inout		          		MTL2_BL_ON_n,
	output		          		MTL2_DCLK,
	output		     [7:0]		MTL2_G,
	output		          		MTL2_HSD,
	output		          		MTL2_I2C_SCL,
	inout 		          		MTL2_I2C_SDA,
	input 		          		MTL2_INT,
	output		     [7:0]		MTL2_R,
	output		          		MTL2_VSD,

	//////////// Ethernet //////////
	output		          		NET_GTX_CLK,
	input 		          		NET_INT_n,
	input 		          		NET_LINK100,
	output		          		NET_MDC,
	inout 		          		NET_MDIO,
	output		          		NET_RST_N,
	input 		          		NET_RX_CLK,
	input 		          		NET_RX_COL,
	input 		          		NET_RX_CRS,
	input 		     [3:0]		NET_RX_D,
	input 		          		NET_RX_DV,
	input 		          		NET_RX_ER,
	input 		          		NET_TX_CLK,
	output		     [3:0]		NET_TX_D,
	output		          		NET_TX_EN,
	output		          		NET_TX_ER,

	//////////// Power Monitor //////////
	output		          		PM_I2C_SCL,
	inout 		          		PM_I2C_SDA,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// Humidity and Temperature Sensor //////////
	input 		          		RH_TEMP_DRDY_n,
	output		          		RH_TEMP_I2C_SCL,
	inout 		          		RH_TEMP_I2C_SDA,

	//////////// MicroSD Card //////////
	output		          		SD_CLK,
	inout 		          		SD_CMD,
	inout 		     [3:0]		SD_DATA,

	//////////// Uart to USB //////////
	output		          		UART_RESET_n,
	input 		          		UART_RX,
	output		          		UART_TX,

	//////////// TMD 2x6 GPIO Header, TMD connect to TMD Default //////////
	inout 		     [7:0]		GPIO
);

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire [7:0] lcd_r;
wire [7:0] lcd_g;
wire [7:0] lcd_b;
wire       lcd_clk;
wire       lcd_hs;
wire       lcd_vs;

assign  GSENSOR_CS_n = 1'b1;	// I2C mode
assign  GSENSOR_SDO  = 1'b0;	// I2C addr 0-----0xA6/0xA7            1-----0x3A/0x3B
assign  MTL2_BL_ON_n = 1'b0;  // light MTL2

vga_pll vga_pll_inst(
	.areset(1'b0),
	.inclk0(MAX10_CLK1_50),
	.c0(lcd_clk),
	.locked(reset_n));


 max10_qsys u0 (
        .clk_clk                                       (MAX10_CLK2_50),                           // clk.clk
        .clk_33_clk                                    (lcd_clk),                                 // clk_33.clk
        .reset_reset_n                                 (reset_n),                                 // reset.reset_n	
		    
		  .pll_areset_conduit_export                     (1'b0),                                    // pll_areset_conduit.export
        .pll_locked_conduit_export                     (),                                        // pll_locked_conduit.export
        .pll_phasedone_conduit_export                  (),                                        // pll_phasedone_conduit.export

		  .key_external_connection_export                (KEY),                                     // key_external_connection.export		 
        .g_sensor_i2c_scl_external_connection_export   (GSENSOR_SCLK),                            // g_sensor_i2c_scl_external_connection.export
        .g_sensor_i2c_sda_external_connection_export   (GSENSOR_SDI),                             // g_sensor_i2c_sda_external_connection.export
        .g_sensor_int_external_connection_export       (~GSENSOR_INT),                            // g_sensor_int_external_connection.export
        .light_i2c_scl_external_connection_export      (LSENSOR_SCL),                             // light_i2c_scl_external_connection.export
        .light_i2c_sda_external_connection_export      (LSENSOR_SDA),                             // light_i2c_sda_external_connection.export
        .light_int_external_connection_export          (LSENSOR_INT),                             // light_int_external_connection.export

	  
        .memory_mem_a                                  (DDR3_A),                                  // memory.mem_a
        .memory_mem_ba                                 (DDR3_BA),                                 //.mem_ba
        .memory_mem_ck                                 (DDR3_CK_p),                               //.mem_ck
        .memory_mem_ck_n                               (DDR3_CK_n),                               //.mem_ck_n
        .memory_mem_cke                                (DDR3_CKE),                                //.mem_cke
        .memory_mem_cs_n                               (DDR3_CS_n),                               //.mem_cs_n
        .memory_mem_dm                                 (DDR3_DM),                                 //.mem_dm
        .memory_mem_ras_n                              (DDR3_RAS_n),                              //.mem_ras_n
        .memory_mem_cas_n                              (DDR3_CAS_n),                              //.mem_cas_n
        .memory_mem_we_n                               (DDR3_WE_n),                               //.mem_we_n
        .memory_mem_reset_n                            (DDR3_RESET_n),                            //.mem_reset_n
        .memory_mem_dq                                 (DDR3_DQ),                                 //.mem_dq
        .memory_mem_dqs                                (DDR3_DQS_p),                              //.mem_dqs
        .memory_mem_dqs_n                              (DDR3_DQS_n),                              //.mem_dqs_n
        .memory_mem_odt                                (DDR3_ODT),                                //.mem_odt
		  .mem_if_ddr3_emif_0_pll_ref_clk_clk            (MAX10_CLK3_50),                           // mem_if_ddr3_emif_0_pll_ref_clk.clk
        .mem_if_ddr3_emif_status_local_init_done       (ddr3_local_init_done),                    // mem_if_ddr3_emif_status.local_init_done
        .mem_if_ddr3_emif_status_local_cal_success     (ddr3_local_cal_success),                  //.local_cal_success
        .mem_if_ddr3_emif_status_local_cal_fail        (ddr3_local_cal_fail),                     //.local_cal_fail
        .ddr3_status_external_connection_export        ({ddr3_local_cal_success, ddr3_local_cal_fail, ddr3_local_init_done}),// ddr3_status_external_connection.export

        .vga_conduit_end_clk                           (),                                        // vga_conduit_end.clk
        .vga_conduit_end_de                            (),                                        //.de
        .vga_conduit_end_r                             (lcd_r),                                   //.r
        .vga_conduit_end_g                             (lcd_g),                                   //.g
        .vga_conduit_end_b                             (lcd_b),                                   //.b
        .vga_conduit_end_hs                            (lcd_hs),                                  //.hs
        .vga_conduit_end_vs                            (lcd_vs)                                   //.vs
    );

////////////////////////////////////////////////////	 
assign LEDR[0] = ddr3_local_init_done;
assign LEDR[1] = ddr3_local_cal_success;
assign LEDR[2] = ddr3_local_cal_fail;
assign LEDR[9:3] = 7'h00;	 
///////////////////////////////////////////
// MTL2 - display
assign {MTL2_B,MTL2_G,MTL2_R} = {lcd_b, lcd_g, lcd_r};

assign MTL2_DCLK = lcd_clk;
assign MTL2_HSD  = lcd_hs;
assign MTL2_VSD  = lcd_vs;
	
		
endmodule
