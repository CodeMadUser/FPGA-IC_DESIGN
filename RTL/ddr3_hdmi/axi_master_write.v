`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:58:11 09/12/2022 
// Design Name: 
// Module Name:    axi_master_write 
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
module axi_master_write
(
	input	wire			axi_clk			,//axi 复位
	input	wire			axi_rst_n		,//axi 总时钟
	//AXI4写通道--地址通道
	output	wire	[3:0]	m_axi_aw_id		,//写地址 ID，用来标志一组写信号
	output	wire	[31:0]	m_axi_aw_addr	,//写地址，给出一次写突发传输的写地址
	output	wire	[7:0]	m_axi_aw_len	,//突发长度，给出突发传输的次数
	output	wire	[2:0]	m_axi_aw_size	,//突发大小，给出每次突发传输的字节数
	output	wire	[1:0]	m_axi_aw_brust	,//突发类型
	output	wire			m_axi_aw_lock	,//总线锁信号，可提供操作的原子性
	output	wire	[3:0]	m_axi_aw_cache	,//内存类型，表明一次传输是怎样通过系统的
	output	wire	[2:0]	m_axi_aw_port	,//保护类型，表明一次传输的特权级及安全等级
	output	wire	[3:0]	m_axi_aw_qos	,//质量服务 QoS
	output	wire			m_axi_aw_valid	,//有效信号，表明此通道的地址控制信号有效
	input	wire			m_axi_aw_ready	,//表明“从”可以接收地址和对应的控制信号
	//AXI4写通道--数据通道
	output	wire	[63:0]	m_axi_w_data	,//写数据
	output	wire	[7:0]	m_axi_w_strb	,//写数据有效的字节线
	output	wire			m_axi_w_last	,//表明此次传输是最后一个突发传输
	output	wire			m_axi_w_valid	,//写有效，表明此次写有效
	input	wire			m_axi_w_ready	,//表明从机可以接收写数据
	//AXI4写通道--应答通道
	input	wire	[3:0]	m_axi_b_id		,//写响应 ID TAG
	input	wire	[1:0]	m_axi_b_resp	,//写响应，表明写传输的状态
	input	wire			m_axi_b_valid	,//写响应有效
	output	wire			m_axi_b_ready	,//表明主机能够接收写响应
	//用户端信号
	input	wire			wr_start		,//写突发触发信号
	input	wire	[31:0]	wr_adrs			,//地址
	input	wire	[9:0]	wr_len			,//长度
	output	wire			wr_ready		,//写空闲
	output	wire			wr_fifo_re		,//连接到写 fifo 的读使能
	input	wire	[63:0]	wr_fifo_data	,//连接到 fifo 的读数据
	output	wire			wr_done			 //完成一次突发
);

//写状态机参数
	localparam	S_WR_IDLE	=	3'd0,//写空闲
				S_WA_WAIT	=	3'd1,//写地址等待
				S_WA_START	=	3'd2,//写地址
				S_WD_WAIT	=	3'd3,//写数据等待
				S_WD_PROC	=	3'd4,//写数据循环
				S_WR_WAIT	=	3'd5,//接受写应答
				S_WR_DONE	=	3'd6;//写结束
				
//所需寄存器
	reg	[2:0]	wr_state		;//状态寄存器
	reg	[31:0]	wr_adrs_reg		;//地址寄存器
	reg			awvalid_reg		;//地址有效握手信号
	reg			w_valid_reg		;//数据有效握手信号
	reg			w_last_reg		;//传输最后一个数据
	reg	[7:0]	w_len_reg		;//突发长度最大 256，实测 128 最佳
	reg	[7:0]	w_std_reg		;
	
/**************************MAIN CODE**********************************/
	
	//写完成信号的写状态完成
	assign	wr_done = (wr_state==S_WR_DONE);
	
	//写 fifo 的读使能为 axi 数据握手成功
	assign	wr_fifo_re = (w_valid_reg&m_axi_w_ready);
	
	//只有一个主机，可随意设置
	assign	m_axi_aw_id	=	4'b1111;
	
	//把地址赋予总线
	assign	m_axi_aw_addr	=	wr_adrs_reg ;
	
	//一次突发传输 1 长度
	assign	m_axi_aw_len	= wr_len - 'd1 ;
	
	//一次突发传输 1 长度
	assign	m_axi_aw_size = 2'b011;
	
	//01 代表地址递增， 10 代表递减
	assign	m_axi_aw_brust	= 2'b01	;
	assign	m_axi_aw_lock	= 1'b0	;
	assign	m_axi_aw_cache	= 4'b0010;
	assign	m_axi_aw_port	= 3'b000;
	assign	m_axi_aw_qos	= 4'b0000;
	
	//地址握手信号 AWVALID
	assign	m_axi_aw_valid	= awvalid_reg ;
	
	//fifo 数据赋予总线
	assign	m_axi_w_data	=	wr_fifo_data ;
	assign	m_axi_w_strb	=	8'hff ;
	
	//写到最后一个数据
	assign	m_axi_w_last	=	(w_len_reg==8'd0)?1'b1:1'b0;
	
	//数据握手信号 WVALID
	assign	m_axi_w_valid	=	w_valid_reg ;
	
	//这个信号是告诉 AXI 我收到你的应答
	assign	m_axi_b_ready	=	m_axi_b_valid;
	
	//axi 状态机空闲信号
	assign	wr_ready	=	(wr_state==S_WR_IDLE)?1'b1:1'b0;
	
	//axi 写过程状态机
	always@(posedge axi_clk or negedge axi_rst_n)
		if(axi_rst_n==1'b0)
			begin
				wr_state <= S_WR_IDLE ;
				wr_adrs_reg <= 32'd0;
				awvalid_reg <= 1'b0;
				w_valid_reg <= 1'b0;
				w_last_reg  <= 1'b0;
				w_len_reg   <= 8'd0;
			end
		else
			begin
				case(wr_state)
					S_WR_IDLE :
						begin
							if(wr_start==1'b1)
								begin
									wr_state <= S_WA_WAIT;
									wr_adrs_reg <= wr_adrs;
								end
							awvalid_reg <= 1'b0;
							w_valid_reg <= 1'b0;
							w_len_reg   <= 8'd0;
						end
					S_WA_WAIT :
						begin
							wr_state <= S_WA_START ;
						end
					S_WA_START:
						begin
							wr_state <= S_WD_WAIT;
							awvalid_reg <= 1'b1;
							w_valid_reg <= 1'b1;
						end
					S_WD_WAIT :
						begin
							if(m_axi_aw_ready==1'b1)
								begin
									wr_state <= S_WD_PROC;
									w_len_reg <= wr_len - 'd1;
									awvalid_reg <= 1'b0;
								end
						end
					S_WD_PROC :
						begin
							if(m_axi_w_ready==1'b1)
								begin
									if(w_len_reg==8'd0)
										begin
											wr_state <= S_WR_WAIT;
											w_valid_reg <= 1'b0;
											w_last_reg <= 1'b1;
										end
									else
										w_len_reg <= w_len_reg -  8'd1;
								end
						end
					S_WR_WAIT :
						begin
							w_last_reg <= 'b0;
							if(m_axi_b_valid)
								begin
									wr_state <= S_WR_DONE;
								end
						end
					S_WR_DONE :
						begin
							wr_state <= S_WR_IDLE;
						end
					default:
						begin
							wr_state <= S_WR_IDLE;
						end
				endcase
			end


endmodule
