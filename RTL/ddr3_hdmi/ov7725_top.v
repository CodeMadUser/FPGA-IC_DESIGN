`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:46:00 09/20/2022 
// Design Name: 
// Module Name:    ov7725_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ov7725_top
(	
	input	wire			sys_clk			, //系统时钟，频率 50MHz
	input	wire			sys_rst_n		, //复位信号，低有效
	input	wire			ov7725_pclk		, //摄像头传入时钟，频率 24MHz
	input	wire			ov7725_href		, //图像行有效使能信号
	input	wire			ov7725_vsync	, //图像场同步信号
	input	wire	[7:0]	ov7725_data		, //摄像头采集图像数据
	input	wire			sys_init_done	, //系统初始化完成信号

	output	wire			ov7725_wr_en	, //DDR3 SDRAM 写使能信号
	output	wire	[15:0]	ov7725_data_out	, //写入 DDR3 SDRAM 的图像数据
	output	wire			cfg_done		, //摄像头寄存器配置完成
	output	wire			sccb_scl		, //寄存器配置串行时钟
	output	wire			sccb_sda		  //寄存器配置串行数据
);

	parameter	SLAVE_ADDR	=	7'h21;			// 器件地址(SLAVE_ADDR)
	parameter	BIT_CTRL	=	1'b0;			// 字地址位控制参数(16b/8b)
	parameter	CLK_FREQ	=	26'd50_000_000;	// i2c_dri 模块的驱动时钟频率(CLK_FREQ)
	parameter	I2C_FREQ	=	18'd250_000;	// I2C 的 SCL 时钟频率
	
	wire			cfg_end		;
	wire			cfg_start	;
	wire	[23:0]	cfg_data	;
	wire			cfg_clk		;
	
i2c_ctrl
#(
    .DEVICE_ADDR    (SLAVE_ADDR	),   //i2c设备地址
    .SYS_CLK_FREQ   (CLK_FREQ	),   //输入系统时钟频率
    .SCL_FREQ       (I2C_FREQ 	)     //i2c设备scl时钟频率
)
i2c_ctrl_inst
(
    .sys_clk     (sys_clk	),  	//输入系统时钟,50MHz
    .sys_rst_n   (sys_rst_n	),  	//输入复位信号,低电平有效
    .wr_en       (1'b1),   			//输入写使能信号
    .rd_en       (),   				//输入读使能信号
    .i2c_start   (cfg_start	),  	//输入i2c触发信号
    .addr_num    (BIT_CTRL	),  	//输入i2c字节地址字节数
    .byte_addr   (cfg_data[15:8]),  //输入i2c字节地址
    .wr_data     (cfg_data[7:0]),   //输入i2c设备数据
	//
    .i2c_clk     (cfg_clk),  	 	//i2c驱动时钟
    .i2c_end     (cfg_end),   		//i2c一次读/写操作完成
    .rd_data     (),   				//输出i2c设备读取数据
    .i2c_scl     (sccb_scl),   		//输出至i2c设备的串行时钟信号scl
    .i2c_sda     (sccb_sda)    		//输出至i2c设备的串行数据信号sda
);

ov7725_cfg ov7725_cfg_inst
(
	.sys_clk	(cfg_clk	),//模块工作时钟,由 iic 模块传入
	.sys_rst_n	(sys_rst_n	),//复位信号，低有效
	.cfg_end	(cfg_end	),//一个寄存器配置完成
	//
	.cfg_done	(cfg_done	),//寄存器配置完成信号
	.cfg_start	(cfg_start	),//单个寄存器配置触发信号
	.cfg_data	(cfg_data	) //寄存器地址+数据
);

ov7725_data ov7725_data_inst
(
	.ov7725_pclk	(ov7725_pclk), //摄像头传入工作时钟，频率 24MHz
	.sys_rst_n		(sys_rst_n&sys_init_done), //复位信号，低有效
	.ov7725_href	(ov7725_href	), //传入图像行有效区域
	.ov7725_vsync	(ov7725_vsync	), //传入图像场同步信号
	.ov7725_data	(ov7725_data	), //传入图像行有效区域
	//                                       
	.ov7725_wr_en	(ov7725_wr_en	), //图像信息写入 DDR3 SDRAM 使能信号
	.ov7725_data_out(ov7725_data_out)	  //写入 DDR3 SDRAM 图像信息
);
endmodule
