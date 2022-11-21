`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:26:38 09/20/2022 
// Design Name: 
// Module Name:    ov7725_ddr3_hdmi 
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
module ov7725_ddr3_hdmi
(
	input	wire			sys_clk			,
	input	wire			sys_rst_n		,
	//摄像机接口
	input	wire			ov7725_pclk		, //摄像头传入时钟，频率 24MHz
	input	wire			ov7725_href		, //图像行有效使能信号
	input	wire			ov7725_vsync	, //图像场同步信号
	input	wire	[7:0]	ov7725_data		, //摄像头采集图像数据	
	output	wire			ov7725_rst_n	, //DDR3 SDRAM 写使能信号
	output	wire			ov7725_pwdn		, //写入 DDR3 SDRAM 的图像数据
	output	wire			sccb_scl		, //寄存器配置串行时钟
	inout	wire			sccb_sda		, //寄存器配置串行数据
	//DDR3接口
	inout	wire	[15:0]		mcb3_dram_dq	,//数据线
	output	wire	[12:0]		mcb3_dram_addr	,//地址线
	output	wire	[2:0]		mcb3_dram_ba	,//bank 线
	output	wire				mcb3_dram_ras_n	,//行使能信号，低电平有效
	output	wire				mcb3_dram_cas_n	,//列使能信号，低电平有效
	output	wire				mcb3_dram_we_n	,//写使能信号，低电平有效
	output	wire				mcb3_dram_cke	,//ddr3 时钟使能信号
	output	wire				mcb3_dram_reset_n,//ddr3 复位
	output	wire				mcb3_dram_odt	,//odt 阻抗
	output	wire				mcb3_dram_dm	,//ddr3 低 8 位掩码
	inout	wire				mcb3_dram_udqs	,//高字节数据选取脉冲差分信号
	inout	wire				mcb3_dram_udqs_n,//高字节数据选取脉冲差分信号
	inout	wire				mcb3_rzq		,//配置阻抗
	inout	wire				mcb3_zio		,//配置阻抗
	output	wire				mcb3_dram_udm	,//ddr3 高 8 位掩码
	inout	wire				mcb3_dram_dqs	,//低字节数据选取脉冲差分信号
	inout	wire				mcb3_dram_dqs_n	,//低字节数据选取脉冲差分信号
	output	wire				mcb3_dram_ck	,//ddr3 差分时钟
	output	wire				mcb3_dram_ck_n	,//ddr3 差分时钟
	//HDMI接口
	output	wire			r_p				,
	output	wire			r_n				,
	output	wire			g_p				,
	output	wire			g_n				,
	output	wire			b_p				,
	output	wire			b_n				,
	output	wire			clk_p			,
	output	wire			clk_n			
	
);

	parameter	H_PIXEL	=	24'd640	;
	parameter	V_PIXEL	=	24'd480	;
	
	wire		clk_25M	;
	wire		clk_125M;
	wire		locked	;
	wire		rst_n	;
	wire		cfg_done;
	wire		wr_en	;
	wire[15:0]	wr_data			;
	wire		rd_en           ;
	wire[15:0]	rd_data         ;
	wire		sys_init_done   ;
	wire		ddr3_init_done  ;
	wire		c3_clk0         ;
	wire		c3_rst0         ;
	wire		vga_hs			;
	wire		vga_vs          ;
	wire		rgb_valid       ;
	wire[15:0]	vga_rgb         ;
	
	
	assign rst_n = sys_rst_n & ddr3_init_done;
	assign sys_init_done = ddr3_init_done & cfg_done;
	assign ov7725_rst_n = 1'b1;
	assign ov7725_pwdn = 1'b0;
	

ov7725_top ov7725_top_inst
(	
	.sys_clk		(clk_25M), //系统时钟，频率 50MHz
	.sys_rst_n		(rst_n	), //复位信号，低有效
	.sys_init_done	(sys_init_done), //系统初始化完成信号
	
	.ov7725_pclk	(ov7725_pclk	), //摄像头传入时钟，频率 24MHz
	.ov7725_href	(ov7725_href	), //图像行有效使能信号
	.ov7725_vsync	(ov7725_vsync	), //图像场同步信号
	.ov7725_data	(ov7725_data	), //摄像头采集图像数据
	
	.ov7725_wr_en	(wr_en		), //DDR3 SDRAM 写使能信号
	.ov7725_data_out(wr_data	), //写入 DDR3 SDRAM 的图像数据
	.cfg_done		(cfg_done	), //摄像头寄存器配置完成
	.sccb_scl		(sccb_scl	), //寄存器配置串行时钟
	.sccb_sda		(sccb_sda	)  //寄存器配置串行数据
);

vga_ctrl vga_ctrl_inst
(
	.vga_clk	 (clk_25M	),
	.sys_rst_n	 (rst_n		),
	.pix_data	 (rd_data	),

	.rgb		 (vga_rgb	),
	.rgb_valid	 (rgb_valid	),
	.hsync		 (vga_hs),
	.vsync		 (vga_vs),
	.pix_data_req(rd_en	)					
);

hdmi_ctrl hdmi_ctrl_inst
(
	.clk_in			(clk_25M	),
	.clk_125M		(clk_125M	),
	.sys_rst_n		(rst_n		),
	.hsync			(vga_hs		),
	.vsync			(vga_vs		),
	.rgb_valid		(rgb_valid	),
	.r				({vga_rgb[4:0],3'b0}	),
	.g				({vga_rgb[10:5],2'b0}	),
	.b				({vga_rgb[15:11],3'b0}	),

	.r_p			(r_p	),
	.r_n			(r_n	),
	.g_p			(g_p	),
	.g_n			(g_n	),
	.b_p			(b_p	),
	.b_n			(b_n	),
	.clk_p			(clk_p	),
	.clk_n			(clk_n	)
);

axi_ddr_top
#(
	.DDR_WR_LEN (1) ,
	.DDR_RD_LEN (1) 
)
axi_ddr_top_inst
(
	//50m 的时钟与复位信号
	.sys_clk	(sys_clk	),
	.sys_rst_n	(sys_rst_n	),
	//
	.pingpang	(1'b1				),//乒乓操作， 1 使能， 0 不使能
	.wr_b_addr	(30'd0				),//写 DDR 首地址
	.wr_e_addr	(H_PIXEL*V_PIXEL*2	),//写 DDR 末地址
	.user_wr_clk(ov7725_pclk		),//写 FIFO 写时钟
	.data_wren	(wr_en				),//写 FIFO 写请求
	//写进 fifo 数据长度，可根据写 fifo 的写端口数据长度自行修改
	//写 FIFO 写数据 16 位，此时用 64 位是为了兼容 32,64 位
	.data_wr	(wr_data			),//写数据 低 16 有效
	.wr_rst		(c_start			),//写地址复位
	//
	.rd_b_addr	(30'd0				),//读 DDR 首地址
	.rd_e_addr	(H_PIXEL*V_PIXEL*2	),//读 DDR 末地址
	.user_rd_clk(clk_25M			),//读 FIFO 读时钟
	.data_rden	(rd_en				),//读 FIFO 读请求
	//读出 fifo 数据长度，可根据读 fifo 的读端口数据长度自行修改
	//读 FIFO 读数据,16 位，此时用 64 位是为了兼容 32,64 位
	.data_rd	(rd_data			),//读数据 低 16 有效
	.rd_rst		(1'b0				),//读地址复位
	//
	.read_enable(1'b1				),//读使能
	
	//接口端信号
	.mcb3_dram_dq		(mcb3_dram_dq		),//数据线
	.mcb3_dram_addr		(mcb3_dram_addr		),//地址线
	.mcb3_dram_ba		(mcb3_dram_ba		),//bank 线
	.mcb3_dram_ras_n	(mcb3_dram_ras_n	),//行使能信号，低电平有效
	.mcb3_dram_cas_n	(mcb3_dram_cas_n	),//列使能信号，低电平有效
	.mcb3_dram_we_n		(mcb3_dram_we_n		),//写使能信号，低电平有效
	.mcb3_dram_cke		(mcb3_dram_cke		),//ddr3 时钟使能信号
	.mcb3_dram_reset_n	(mcb3_dram_reset_n	),//ddr3 复位
	.mcb3_dram_odt		(mcb3_dram_odt		),//odt 阻抗
	.mcb3_dram_dm		(mcb3_dram_dm		),//ddr3 低 8 位掩码
	.mcb3_dram_udqs		(mcb3_dram_udqs		),//高字节数据选取脉冲差分信号
	.mcb3_dram_udqs_n	(mcb3_dram_udqs_n	),//高字节数据选取脉冲差分信号
	.mcb3_rzq			(mcb3_rzq			),//配置阻抗
	.mcb3_zio			(mcb3_zio			),//配置阻抗
	.mcb3_dram_udm		(mcb3_dram_udm		),//ddr3 高 8 位掩码
	.mcb3_dram_dqs		(mcb3_dram_dqs		),//低字节数据选取脉冲差分信号
	.mcb3_dram_dqs_n	(mcb3_dram_dqs_n	),//低字节数据选取脉冲差分信号
	.mcb3_dram_ck		(mcb3_dram_ck		),//ddr3 差分时钟
	.mcb3_dram_ck_n		(mcb3_dram_ck_n		),//ddr3 差分时钟
	//
	.ui_clk			(c3_clk0		),//输出时钟 125m
	.ui_rst_n		(c3_rst0		),//输出复位，高有效
	.use_clk1		(clk_25M		),//用户输出时钟 1
	.use_clk2		(clk_125M		),//用户输出时钟 2
	.c3_calib_done	(ddr3_init_done	) //ddr 初始化完成
	
);

endmodule
