`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:57:20 09/12/2022 
// Design Name: 
// Module Name:    axi_ddr_top 
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
module axi_ddr_top
#(
	parameter	DDR_WR_LEN = 1,
	parameter	DDR_RD_LEN = 1
)
(
	//50m 的时钟与复位信号
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	//
	input	wire			pingpang	,//乒乓操作， 1 使能， 0 不使能
	input	wire	[31:0]	wr_b_addr	,//写 DDR 首地址
	input	wire	[31:0]	wr_e_addr	,//写 DDR 末地址
	input	wire			user_wr_clk	,//写 FIFO 写时钟
	input	wire			data_wren	,//写 FIFO 写请求
	//写进 fifo 数据长度，可根据写 fifo 的写端口数据长度自行修改
	//写 FIFO 写数据 16 位，此时用 64 位是为了兼容 32,64 位
	input	wire	[64:0]	data_wr		,//写数据 低 16 有效
	input	wire			wr_rst		,//写地址复位
	//
	input	wire	[31:0]	rd_b_addr	,//读 DDR 首地址
	input	wire	[31:0]	rd_e_addr	,//读 DDR 末地址
	input	wire			user_rd_clk	,//读 FIFO 读时钟
	input	wire			data_rden	,//读 FIFO 读请求
	//读出 fifo 数据长度，可根据读 fifo 的读端口数据长度自行修改
	//读 FIFO 读数据,16 位，此时用 64 位是为了兼容 32,64 位
	output	wire	[63:0]	data_rd		,//读数据 低 16 有效
	input	wire			rd_rst		,//读地址复位
	//
	input	wire			read_enable	,//读使能
	
	//接口端信号
	inout	wire	[16-1:0]	mcb3_dram_dq	,//数据线
	output	wire	[13-1:0]	mcb3_dram_addr	,//地址线
	output	wire	[3-1:0]		mcb3_dram_ba	,//bank 线
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
	//
	output	wire				ui_clk			,//输出时钟 125m
	output	wire				ui_rst_n		,//输出复位，高有效
	output	wire				use_clk1		,//用户输出时钟 1
	output	wire				use_clk2		,//用户输出时钟 2
	output	wire				c3_calib_done	 //ddr 初始化完成
	
);
	wire	 		wr_brust_req	;
	wire	[31:0]	wr_brust_addr	;
	wire	[9:0]	wr_brust_len 	;
	wire			wr_ready		;
	wire			wr_fifo_re		;
	wire	[63:0]	wr_fifo_data	;
	wire			wr_brust_finish ;
	wire			rd_brust_req	;
	wire	[31:0]	rd_brust_addr	;
	wire	[9:0]	rd_brust_len	;
	wire			rd_ready		;
	wire			rd_fifo_we		;
	wire	[63:0]	rd_fifo_data	;
	wire			rd_brust_finish ;
	//
	wire	[3:0]	m_axi_aw_id	    ;
	wire	[31:0]	m_axi_aw_addr	;
	wire	[7:0]	m_axi_aw_len	;
	wire	[2:0]	m_axi_aw_size	;
	wire	[1:0]	m_axi_aw_brust	;
	wire			m_axi_aw_lock	;
	wire	[3:0]	m_axi_aw_cache	;
	wire	[2:0]	m_axi_aw_port	;
	wire	[3:0]	m_axi_aw_qos	;
	wire			m_axi_aw_valid	;
	wire			m_axi_aw_ready	;
	wire	[63:0]	m_axi_w_data	;
	wire	[7:0]	m_axi_w_strb	;
	wire			m_axi_w_last	;
	wire			m_axi_w_valid	;
	wire			m_axi_w_ready	;
	wire	[3:0]	m_axi_b_id		;
	wire	[1:0]	m_axi_b_resp	;
	wire			m_axi_b_valid	;
	wire			m_axi_b_ready	;
	//
	wire	[3:0]	m_axi_ar_id		;
	wire	[31:0]	m_axi_ar_addr	;
	wire	[7:0]	m_axi_ar_len	;
	wire	[2:0]	m_axi_ar_size	;
	wire	[1:0]	m_axi_ar_brust	;
	wire			m_axi_ar_lock	;
	wire	[3:0]	m_axi_ar_cache	;
	wire	[2:0]	m_axi_ar_port	;
	wire	[3:0]	m_axi_ar_qos	;
	wire			m_axi_ar_valid	;
	wire			m_axi_ar_ready	;
	wire	[3:0]	m_axi_r_id		;
	wire	[63:0]	m_axi_r_data	;
	wire	[1:0]	m_axi_r_resp	;
	wire			m_axi_r_last	;
	wire			m_axi_r_valid	;
	wire			m_axi_r_ready	;
	//
	
	//wire			c3_calib_done	;
	wire			c3_clk0			;
	wire			c3_rst0			;
	wire			c3_s0_axi_aclk   ;
	wire			c3_s0_axi_aresetn;
	
	
	
axi_ctrl
#(
	.DDR_WR_LEN(DDR_WR_LEN),//写突发长度为1个64bit数据
	.DDR_RD_LEN(DDR_RD_LEN) //读突发长度为1个64bit数据
)
axi_ctrl_inst
(
	.ui_clk		(c3_clk0),
	.ui_rst_n	(c3_rst0),
	.pingpang	(pingpang	),
	.wr_b_addr	(wr_b_addr	),
	.wr_e_addr	(wr_e_addr	),
	.user_wr_clk(user_wr_clk),
	.data_wren	(data_wren	),
	.data_wr	(data_wr	),
	.wr_rst		(wr_rst		),
	.rd_b_addr	(rd_b_addr	),
	.rd_e_addr	(rd_e_addr	),
	.user_rd_clk(user_rd_clk),
	.data_rden	(data_rden	),
	.data_rd	(data_rd	),
	.rd_rst		(rd_rst		),
	.read_enable(read_enable),
	//写fifo
	.wr_brust_req	(wr_brust_req	),
	.wr_brust_addr	(wr_brust_addr	),
	.wr_brust_len 	(wr_brust_len 	),
	.wr_ready		(wr_ready		),
	.wr_fifo_re		(wr_fifo_re		),
	.wr_fifo_data	(wr_fifo_data	),
	.wr_brust_finish(wr_brust_finish),
	//读fifo
	.rd_brust_req	(rd_brust_req	),
	.rd_brust_addr	(rd_brust_addr	),
	.rd_brust_len	(rd_brust_len	),
	.rd_ready		(rd_ready		),
	.rd_fifo_we		(rd_fifo_we		),
	.rd_fifo_data	(rd_fifo_data	),
	.rd_brust_finish(rd_brust_finish)
);

axi_master_write axi_master_write_inst
(
	.axi_clk		(c3_s0_axi_aclk),//axi 复位
	.axi_rst_n		(c3_s0_axi_aresetn),//axi 总时钟
	//AXI4写通道--地址通道
	.m_axi_aw_id	(m_axi_aw_id	),//写地址 ID，用来标志一组写信号
	.m_axi_aw_addr	(m_axi_aw_addr	),//写地址，给出一次写突发传输的写地址
	.m_axi_aw_len	(m_axi_aw_len	),//突发长度，给出突发传输的次数
	.m_axi_aw_size	(m_axi_aw_size	),//突发大小，给出每次突发传输的字节数
	.m_axi_aw_brust	(m_axi_aw_brust	),//突发类型
	.m_axi_aw_lock	(m_axi_aw_lock	),//总线锁信号，可提供操作的原子性
	.m_axi_aw_cache	(m_axi_aw_cache	),//内存类型，表明一次传输是怎样通过系统的
	.m_axi_aw_port	(m_axi_aw_port	),//保护类型，表明一次传输的特权级及安全等级
	.m_axi_aw_qos	(m_axi_aw_qos	),//质量服务 QoS
	.m_axi_aw_valid	(m_axi_aw_valid	),//有效信号，表明此通道的地址控制信号有效
	.m_axi_aw_ready	(m_axi_aw_ready	),//表明“从”可以接收地址和对应的控制信号
	//AXI4写通道--数据通道
	.m_axi_w_data	(m_axi_w_data	),//写数据
	.m_axi_w_strb	(m_axi_w_strb	),//写数据有效的字节线
	.m_axi_w_last	(m_axi_w_last	),//表明此次传输是最后一个突发传输
	.m_axi_w_valid	(m_axi_w_valid	),//写有效，表明此次写有效
	.m_axi_w_ready	(m_axi_w_ready	),//表明从机可以接收写数据
	//AXI4写通道--应答通道
	.m_axi_b_id		(m_axi_b_id		),//写响应 ID TAG
	.m_axi_b_resp	(m_axi_b_resp	),//写响应，表明写传输的状态
	.m_axi_b_valid	(m_axi_b_valid	),//写响应有效
	.m_axi_b_ready	(m_axi_b_ready	),//表明主机能够接收写响应
	//用户端信号
	.wr_start		(wr_brust_req	),//写突发触发信号
	.wr_adrs		(wr_brust_addr	),//地址
	.wr_len			(wr_brust_len 	),//长度
	.wr_ready		(wr_ready		),//写空闲
	.wr_fifo_re		(wr_fifo_re		),//连接到写 fifo 的读使能
	.wr_fifo_data	(wr_fifo_data	),//连接到 fifo 的读数据
	.wr_done		(wr_brust_finish)	 //完成一次突发
);

axi_master_read axi_master_read_inst
(
	.axi_clk	(c3_s0_axi_aclk),
	.axi_rst_n	(c3_s0_axi_aresetn),
	
	//axi 读通道  写地址
	.m_axi_ar_id	(m_axi_ar_id		),//读地址 ID，用来标志一组写信号
	.m_axi_ar_addr	(m_axi_ar_addr	),//读地址，给出一次写突发传输的读地址
	.m_axi_ar_len	(m_axi_ar_len	),//突发长度，给出突发传输的次数
	.m_axi_ar_size	(m_axi_ar_size	),//突发大小，给出每次突发传输的字节数
	.m_axi_ar_brust	(m_axi_ar_brust	),//突发类型
	.m_axi_ar_lock	(m_axi_ar_lock	),//总线锁信号，可提供操作的原子性
	.m_axi_ar_cache	(m_axi_ar_cache	),//内存类型，表明一次传输是怎样通过系统的
	.m_axi_ar_port	(m_axi_ar_port	),//保护类型，表明一次传输的特权级及安全等级
	.m_axi_ar_qos	(m_axi_ar_qos	),//质量服务 QOS
	.m_axi_ar_valid	(m_axi_ar_valid	),//有效信号，表明此通道的地址控制信号有效
	.m_axi_ar_ready	(m_axi_ar_ready	),//表明“从”可以接收地址和对应的控制信号
	
	//axi 读通道  读数据
	.m_axi_r_id		(m_axi_r_id		),//读 ID tag
	.m_axi_r_data	(m_axi_r_data	),//读数据
	.m_axi_r_resp	(m_axi_r_resp	),//读响应，表明读传输的状态
	.m_axi_r_last	(m_axi_r_last	),//表明读突发的最后一次传输
	.m_axi_r_valid	(m_axi_r_valid	),//表明此通道信号有效
	.m_axi_r_ready	(m_axi_r_ready	),//表明主机能够接收读数据和响应信息
	
	//用户端fifo接口
	.rd_start		(rd_brust_req	),//读突发触发信号
	.rd_adrs		(rd_brust_addr	),//地址
	.rd_len			(rd_brust_len	),//长度
	.rd_ready		(rd_ready		),//读空闲
	.rd_fifo_we		(rd_fifo_we		),//连接到读 fifo 的写使能
	.rd_fifo_data	(rd_fifo_data	),//连接到读 fifo 的写数据
	.rd_fifo_done	(rd_brust_finish) //完成一次突发
);

axi_ddr 
#(
   .C3_P0_MASK_SIZE           (8	) ,
   .C3_P0_DATA_PORT_SIZE      (64	) ,
   .C3_P1_MASK_SIZE           (8	) ,
   .C3_P1_DATA_PORT_SIZE      (64	) ,
   .DEBUG_EN                  (0	) ,       
                                       // # = 1, Enable debug signals/controls,
                                       //   = 0, Disable debug signals/controls.
   .C3_MEMCLK_PERIOD        (3200	),	       
                        // Memory data transfer clock period
   .C3_CALIB_SOFT_IP        ("TRUE"	),       
                        // # = TRUE, Enables the soft calibration logic,
                          // # = FALSE, Disables the soft calibration logic.
   .C3_SIMULATION           ("FALSE") ,       
                          // # = TRUE, Simulating the design. Useful to reduce the simulation time,
                          // # = FALSE, Implementing the design.
   .C3_RST_ACT_LOW          (0		) ,       
                          // # = 1 for active low reset,
                          // # = 0 for active high reset.
   .C3_INPUT_CLK_TYPE       ("SINGLE_ENDED") ,       
                         // input clock type DIFFERENTIAL or SINGLE_ENDED
   .C3_MEM_ADDR_ORDER       ("BANK_ROW_COLUMN") ,       
                         // The order in which user address is provided to the memory controller,
                         // ROW_BANK_COLUMN or BANK_ROW_COLUMN
   .C3_NUM_DQ_PINS          (16		),       
                         // External memory data width
   .C3_MEM_ADDR_WIDTH       (13		),       
                                       // External memory address width
   .C3_MEM_BANKADDR_WIDTH 	(3		),
					//  External  memory  bank  address  width
   .C3_S0_AXI_STRICT_COHERENCY   	(0	),
   .C3_S0_AXI_ENABLE_AP          	(0	),
   .C3_S0_AXI_DATA_WIDTH         	(64	),
   .C3_S0_AXI_SUPPORTS_NARROW_BURST (1	),
   .C3_S0_AXI_ADDR_WIDTH         	(32	),
   .C3_S0_AXI_ID_WIDTH           	(4	),
   .C3_S0_AXI_SUPPORTS_READ			(1	),
   .C3_S0_AXI_SUPPORTS_WRITE		(1	),
   .C3_S0_AXI_ENABLE				(1	)
)	
axi_ddr_inst
(

   .mcb3_dram_dq		(mcb3_dram_dq		),
   .mcb3_dram_a			(mcb3_dram_addr		),
   .mcb3_dram_ba		(mcb3_dram_ba		),
   .mcb3_dram_ras_n		(mcb3_dram_ras_n	),
   .mcb3_dram_cas_n		(mcb3_dram_cas_n	),
   .mcb3_dram_we_n		(mcb3_dram_we_n		),
   .mcb3_dram_odt		(mcb3_dram_odt		),
   .mcb3_dram_reset_n	(mcb3_dram_reset_n	),
   .mcb3_dram_cke		(mcb3_dram_cke		),
   .mcb3_dram_dm		(mcb3_dram_dm		),
   .mcb3_dram_udqs		(mcb3_dram_udqs		),
   .mcb3_dram_udqs_n	(mcb3_dram_udqs_n	),
   .mcb3_rzq			(mcb3_rzq			),
   .mcb3_zio			(mcb3_zio			),
   .mcb3_dram_udm		(mcb3_dram_udm		),
   .c3_sys_clk			(sys_clk			),
   .c3_sys_rst_i		(sys_rst_n			),
   .c3_calib_done		(),
   .c3_clk0				(c3_clk0			),
   .c3_rst0				(c3_rst0			),
   .mcb3_dram_dqs		(mcb3_dram_dqs	),
   .mcb3_dram_dqs_n		(mcb3_dram_dqs_n),
   .mcb3_dram_ck		(mcb3_dram_ck	),
   .mcb3_dram_ck_n		(mcb3_dram_ck_n	),
   //***********
   .c3_s0_axi_aclk   	(c3_s0_axi_aclk),
   .c3_s0_axi_aresetn	(c3_s0_axi_aresetn),
   .c3_s0_axi_awid   	(m_axi_aw_id	),
   .c3_s0_axi_awaddr 	(m_axi_aw_addr	),
   .c3_s0_axi_awlen  	(m_axi_aw_len	),
   .c3_s0_axi_awsize 	(m_axi_aw_size	),
   .c3_s0_axi_awburst	(m_axi_aw_brust	),
   .c3_s0_axi_awlock 	(m_axi_aw_lock	),
   .c3_s0_axi_awcache	(m_axi_aw_cache	),
   .c3_s0_axi_awprot 	(m_axi_aw_port	),
   .c3_s0_axi_awqos  	(m_axi_aw_qos	),
   .c3_s0_axi_awvalid	(m_axi_aw_valid	),
   .c3_s0_axi_awready	(m_axi_aw_ready	),
   .c3_s0_axi_wdata  	(m_axi_w_data	),
   .c3_s0_axi_wstrb  	(m_axi_w_strb	),
   .c3_s0_axi_wlast  	(m_axi_w_last	),
   .c3_s0_axi_wvalid 	(m_axi_w_valid	),
   .c3_s0_axi_wready 	(m_axi_w_ready	),
   .c3_s0_axi_bid    	(m_axi_b_id		),
   .c3_s0_axi_wid    	(),
   .c3_s0_axi_bresp  	(m_axi_b_resp	),
   .c3_s0_axi_bvalid 	(m_axi_b_valid	),
   .c3_s0_axi_bready 	(m_axi_b_ready	),
   .c3_s0_axi_arid   	(m_axi_ar_id	),
   .c3_s0_axi_araddr 	(m_axi_ar_addr	),
   .c3_s0_axi_arlen  	(m_axi_ar_len	),
   .c3_s0_axi_arsize 	(m_axi_ar_size	),
   .c3_s0_axi_arburst	(m_axi_ar_brust	),
   .c3_s0_axi_arlock 	(m_axi_ar_lock	),
   .c3_s0_axi_arcache	(m_axi_ar_cache	),
   .c3_s0_axi_arprot 	(m_axi_ar_port	),
   .c3_s0_axi_arqos  	(m_axi_ar_qos	),
   .c3_s0_axi_arvalid	(m_axi_ar_valid	),
   .c3_s0_axi_arready	(m_axi_ar_ready	),
   .c3_s0_axi_rid    	(m_axi_r_id		),
   .c3_s0_axi_rdata  	(m_axi_r_data	),
   .c3_s0_axi_rresp  	(m_axi_r_resp	),
   .c3_s0_axi_rlast  	(m_axi_r_last	),
   .c3_s0_axi_rvalid 	(m_axi_r_valid	),
   .c3_s0_axi_rready 	(m_axi_r_ready	)
);
endmodule
