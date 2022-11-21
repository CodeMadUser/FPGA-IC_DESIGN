`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:50:22 09/12/2022 
// Design Name: 
// Module Name:    axi_master_read 
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
module axi_master_read
(
	input	wire			axi_clk		,
	input	wire			axi_rst_n	,
	
	//axi 读通道  写地址
	output	wire	[3:0]	m_axi_ar_id		,//读地址 ID，用来标志一组写信号
	output	wire	[31:0]	m_axi_ar_addr	,//读地址，给出一次写突发传输的读地址
	output	wire	[7:0]	m_axi_ar_len	,//突发长度，给出突发传输的次数
	output	wire	[2:0]	m_axi_ar_size	,//突发大小，给出每次突发传输的字节数
	output	wire	[1:0]	m_axi_ar_brust	,//突发类型
	output	wire	[1:0]	m_axi_ar_lock	,//总线锁信号，可提供操作的原子性
	output	wire	[3:0]	m_axi_ar_cache	,//内存类型，表明一次传输是怎样通过系统的
	output	wire	[2:0]	m_axi_ar_port	,//保护类型，表明一次传输的特权级及安全等级
	output	wire	[3:0]	m_axi_ar_qos	,//质量服务 QOS
	output	wire			m_axi_ar_valid	,//有效信号，表明此通道的地址控制信号有效
	input	wire			m_axi_ar_ready	,//表明“从”可以接收地址和对应的控制信号
	
	//axi 读通道  读数据
	input	wire	[3:0]	m_axi_r_id		,//读 ID tag
	input	wire	[63:0]	m_axi_r_data	,//读数据
	input	wire	[1:0]	m_axi_r_resp	,//读响应，表明读传输的状态
	input	wire			m_axi_r_last	,//表明读突发的最后一次传输
	input	wire			m_axi_r_valid	,//表明此通道信号有效
	output	wire			m_axi_r_ready	,//表明主机能够接收读数据和响应信息
	
	//用户端fifo接口
	input	wire			rd_start		,//读突发触发信号
	input	wire	[31:0]	rd_adrs			,//地址
	input	wire	[9:0]	rd_len			,//长度
	output	wire			rd_ready		,//读空闲
	output	wire			rd_fifo_we		,//连接到读 fifo 的写使能
	output	wire			rd_fifo_data	,//连接到读 fifo 的写数据
	output	wire			rd_fifo_done	 //完成一次突发
);
//状态机状态定义
	localparam	S_RD_IDLE	=	3'd0,//读空闲
				S_RA_WAIT	=	3'd1,//读地址等待
				S_RA_START	=	3'd2,//读地址
				S_RD_WAIT	=	3'd3,//读数据等待
				S_RD_PROC	=	3'd4,//读数据循环
				S_RD_DONE	=	3'd5;//写结束

//所需寄存器定义
	reg	[2:0]	rd_state	;//状态寄存器
	reg	[31:0]	rd_adrs_reg	;//地址寄存器
	reg	[31:0]	rd_len_reg	;//突发长度寄存器
	reg			arvalid_reg	;//地址有效寄存器

/***********************************MAIN CODE***************************/
	
	//axi  读通道  写地址
	assign	m_axi_ar_id = 	4'b1111;		//地址id
	
	assign	m_axi_ar_addr = rd_adrs_reg;	//地址

	assign	m_axi_ar_len = rd_len-32'd1;	//突发长度

	assign	m_axi_ar_size = 3'b011;			//表示 AXI 总线每个数据宽度是 8 字节， 64 位

	assign	m_axi_ar_brust = 2'b01;			//地址递增方式传输,01 代表地址递增， 10 代表递减

	assign	m_axi_ar_lock = 1'b0;			//总线锁定信号

	assign	m_axi_ar_cache = 4'b0011;		//内存类型

	assign	m_axi_ar_port = 3'b000;		    //保护类型

	assign	m_axi_ar_qos = 4'b0000;			//服务质量

	assign	m_axi_ar_valid = arvalid_reg ;	//有效信号
	
	
	//axi 读通道  读数据
	assign	m_axi_r_ready = m_axi_r_valid;				//
	
	//用户端fifo接口
	assign	rd_ready = (rd_state==S_RD_IDLE)?1'b1:1'b0;	//写空闲

	assign	rd_fifo_we = m_axi_r_valid;					//读 fifo 的写使能信号

	assign	rd_fifo_data = m_axi_r_data;				//读 fifo 的写数据信号
	
	assign	rd_fifo_done = (rd_state==S_RD_DONE);		//一次读取结束
	
	//axi  读状态机
	always@(posedge axi_clk or negedge axi_rst_n)
		if(axi_rst_n==1'b0)
			begin
				rd_state	<= S_RD_IDLE ;
				rd_adrs_reg <= 32'd0;
				rd_len_reg  <= 32'd0;
				arvalid_reg <= 1'b0;
			end
		else
			begin
				case(rd_state)
					S_RD_IDLE	:
						begin
							if(rd_start==1'b1)
								begin
									rd_state <= S_RA_WAIT;
									rd_adrs_reg <= rd_adrs ;
									rd_len_reg[31:0]  <= rd_len[9:0]-32'd1;
								end
							arvalid_reg <= 1'b0;
						end
					S_RA_WAIT	:
						begin
							rd_state <= S_RA_START;
						end
					S_RA_START	:
						begin
							rd_state <= S_RD_WAIT;
							arvalid_reg <= 1'b1;
						end
					S_RD_WAIT	:
						begin
							if(m_axi_ar_ready==1'b1)
								begin
									rd_state <= S_RD_PROC;
									arvalid_reg <= 1'b0;
								end
						end
					S_RD_PROC	:
						begin
							if(m_axi_r_valid)
								begin
									if(m_axi_r_last)
										rd_state <= S_RD_DONE;
								end	
						end
					S_RD_DONE	:
						begin
							rd_state  <= S_RD_IDLE;
						end
					default		:
						rd_state <= S_RD_IDLE;
				endcase
			end


endmodule
