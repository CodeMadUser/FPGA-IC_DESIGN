module axi_ctrl
#(
	parameter	DDR_WR_LEN	=	1 ,//写突发长度为1个64bit数据
	parameter	DDR_RD_LEN	=	1  //读突发长度为1个64bit数据
)
(
	input	wire			ui_clk		,
	input	wire			ui_rst_n	,
	input	wire			pingpang	,
	input	wire	[31:0]	wr_b_addr	,
	input	wire	[31:0]	wr_e_addr	,
	input	wire			user_wr_clk	,
	input	wire			data_wren	,
	input	wire	[63:0]	data_wr		,
	input	wire			wr_rst		,
	input	wire	[31:0]	rd_b_addr	,
	input	wire	[31:0]	rd_e_addr	,
	input	wire			user_rd_clk	,
	input	wire			data_rden	,
	output	wire	[63:0]	data_rd		,
	input	wire			rd_rst		,
	input	wire			read_enable	,
	//写fifo
	output	wire			wr_brust_req,
	output	wire	[31:0]	wr_brust_addr,
	output	wire	[9:0]	wr_brust_len ,
	input	wire			wr_ready	,
	input	wire			wr_fifo_re	,
	output	wire	[31:0]	wr_fifo_data,
	input	wire			wr_brust_finish,
	//读fifo
	output	wire			rd_brust_req,
	output	wire	[31:0]	rd_brust_addr,
	output	wire	[9:0]	rd_brust_len,
	input	wire			rd_ready	,
	input	wire			rd_fifo_we	,
	output	wire	[31:0]	rd_fifo_data,
	input	wire			rd_brust_finish
);

	reg			wr_brust_req_reg	;
	reg	[31:0]	wr_brust_addr_reg	;
	reg	[9:0]	wr_brust_len_reg	;
	
	reg			rd_brust_req_reg	;
	reg	[31:0]	rd_brust_addr_reg	;
	reg	[9:0]	rd_brust_len_reg	;
	
//读写复位地址打拍
	reg	wr_rst_reg1;
	reg	wr_rst_reg2;
	reg	rd_rst_reg1;
	reg	rd_rst_reg2;
	
//乒乓操作指示寄存器
	reg	pingpang_reg;
	
//写fifo信号
	wire			wr_fifo_wr_clk	;
	wire	[63:0]	wr_fifo_din		;
	wire			wr_fifo_wr_en	;
	
	wire			wr_fifo_rd_clk	;
	wire	[63:0]	wr_fifo_dout	;
	wire			wr_fifo_rd_en	;
	
	wire			wr_fifo_full	;
	wire			wr_fifo_almost_full;
	wire			wr_fifo_empty	;
	wire			wr_fifo_almost_empty;
	
	wire	[9:0]	wr_fifo_wr_data_count;
	wire	[9:0]	wr_fifo_rd_data_count;
	
//读fifo信号
	wire			rd_fifo_wr_clk	;
	wire	[15:0]	rd_fifo_din		;
	wire			rd_fifo_wr_en	;
	
	wire			rd_fifo_rd_clk	;
	wire	[63:0]	rd_fifo_dout	;
	wire			rd_fifo_rd_en	;
	
	wire			rd_fifo_full	;
	wire			rd_fifo_almost_full;
	wire			rd_fifo_empty	;
	wire			rd_fifo_almost_empty;
	
	wire	[9:0]	rd_fifo_wr_data_count	;
	wire	[9:0]	rd_fifo_rd_data_count	;
	
/**************************MAIN CODE***************************/
	
	assign  wr_brust_req = wr_brust_req_reg	,    //写突发请求
			wr_brust_addr = wr_brust_addr_reg ,	//突发地址
			wr_brust_len  = DDR_WR_LEN		;	//突发长度
			
	assign	rd_brust_req = rd_brust_req_reg ,  //读突发请求
			rd_brust_addr = rd_brust_addr_reg , //突发地址
			rd_brust_len = DDR_RD_LEN ;        //突发长度
			
//写fifo信号
	assign  wr_fifo_wr_clk 	= user_wr_clk ; //写fifo写时钟 是 用户端时钟
	
	assign	wr_fifo_din 	= (wr_fifo_full)?64'd0:data_wr	;		//写fifo数据输入端 ，若是写fifo为wr_fifo_full==1'b1则不写入，若是写fifo为wr_fifo_full==1'b0则通过用户端数据输入端口写入
	
	assign	wr_fifo_wr_en 	= (wr_fifo_full)?1'b0:data_wren;		//写fifo写使能端，若是写fifo为wr_fifo_full==1'b1则拉低，wr_fifo_full==1'b0则拉高；

	assign	wr_fifo_rd_clk 	= ui_clk ;		//写fifo读时钟 是 axi总时钟

	assign	wr_fifo_data 	= (wr_fifo_empty)?64'd0:wr_fifo_dout; //写fifo数据输出端，若是写fifo的wr_fifo_empty==1'b1则输出0，wr_fifo_empty==1’b0则输出wr_fifo_dout；
	
	assign	wr_fifo_rd_en 	= (wr_fifo_empty)?1'b0:wr_fifo_re;  //写fifo读使能端，若是写fifo的wr_fifo_empty==1'b1则拉低，若是写fifo的wr_fifo_empty==1'b0则通过用户端使能输入端口
//读fifo信号	
	assign	rd_fifo_wr_clk	= ui_clk	;
	
	assign  rd_fifo_din		= (rd_fifo_full)?64'd0:rd_fifo_data;
	
	assign  rd_fifo_wr_en	= (rd_fifo_full)?1'b0:rd_fifo_we;

    assign  rd_fifo_rd_clk	= user_rd_clk;
	
    assign  data_rd			= (rd_fifo_empty)?64'd0:rd_fifo_dout;
	
    assign  rd_fifo_rd_en	= (rd_fifo_empty)?1'b0:data_rden;
	
	//assign	data_rd_flag	= (rd_fifo_empty)?:;
	
//读写复位地址打拍,打拍便于提出上升沿和下降沿
	always@(posedge ui_clk or negedge ui_rst_n)
		if(ui_rst_n==1'b0)
			begin
				wr_rst_reg1 <= 1'b0;
				wr_rst_reg2 <= 1'b0;
			end
		else
			begin
				wr_rst_reg1 <= wr_rst;
				wr_rst_reg2 <= wr_rst_reg1;
			end
	
	always@(posedge ui_clk or negedge ui_rst_n)
		if(ui_rst_n==1'b0)
			begin
				rd_rst_reg1 <= 1'b0;
				rd_rst_reg2 <= 1'b0;
			end
		else
			begin
				rd_rst_reg1 <= rd_rst;
				rd_rst_reg2 <= rd_rst_reg1;
			end

	//写突发请求
	always@(posedge ui_clk or negedge ui_rst_n)
		if(ui_rst_n==1'b0)
			wr_brust_len_reg <= 1'b0;
		else if(wr_fifo_rd_data_count>=DDR_WR_LEN && wr_ready==1'b1) //fifo 数据长度大于一次突发长度并且 axi 写空闲
			wr_brust_len_reg <= 1'b1;
		else
			wr_brust_len_reg <= 1'b0;
	
	//写突发地址		完成一次突发对地址进行相加,相加地址长度=突发长度 x8,64 位等于 8 字节,128*8=1024
	always@(posedge ui_clk or negedge ui_rst_n)
		if(ui_rst_n==1'b0)
			begin
				wr_brust_addr_reg <= wr_b_addr ;
				pingpang_reg <= 1'b0;
			end
		else if(wr_rst_reg1&(~wr_rst_reg2))  //写复位信号上升沿
			wr_brust_addr_reg <= wr_b_addr;
		else if(wr_brust_finish==1'b1)		
			begin
				wr_brust_addr_reg <= wr_brust_addr_reg + DDR_WR_LEN*8;
				if(pingpang==1'b1)   //判断是否是乒乓操作
					begin			//结束地址为 2 倍的接受地址，有两块区域
						if(wr_brust_addr_reg>=(wr_e_addr*2-wr_b_addr-DDR_WR_LEN*8))
							wr_brust_addr_reg <= wr_b_addr;
						//根据地址， pingpang_reg 为 0 或者 1,  用于指示读操作与写操作地址不冲突
						if(wr_brust_addr_reg<(wr_e_addr-wr_b_addr))
							pingpang_reg <= 1'b0;
						else
							pingpang_reg <= 1'b1;
					end
				else //非乒乓操作
					begin
						if(wr_brust_addr_reg>=(wr_e_addr-wr_b_addr-DDR_WR_LEN*8))
							wr_brust_addr_reg <= wr_b_addr;
					end
			end
		else
			wr_brust_addr_reg <= wr_brust_addr_reg;
			
	//读突发请求		
	always@(posedge ui_clk or negedge ui_rst_n)
		if(ui_rst_n==1'b0)
			rd_brust_req_reg <= 1'b0;
		else if(rd_fifo_wr_data_count<=(10'd1000-DDR_RD_LEN) && rd_ready==1'b1 && read_enable==1'b1) //fifo 可写长度大于一次突发长度并且 axi 读空闲， fifo 总长度 1024
			rd_brust_req_reg <= 1'b1;
		else
			rd_brust_req_reg <= 1'b0;
			
	//写突发地址		完成一次突发对地址进行相加,相加地址长度=突发长度 x8,64 位等于 8 字节,128*8=1024
	always@(posedge ui_clk or negedge ui_rst_n)
		if(ui_rst_n==1'b0)
			begin
				if(pingpang==1'b1)
					rd_brust_addr_reg <= rd_e_addr ;
				else
					rd_brust_addr_reg <= rd_b_addr;
			end
		else if(rd_rst_reg1&(~rd_rst_reg2))
			rd_brust_addr_reg <= rd_b_addr;
		else if(rd_brust_finish==1'b1)
			begin
				rd_brust_addr_reg <= rd_brust_addr_reg+DDR_RD_LEN*8;
				if(pingpang==1'b1)
					begin
						if((rd_brust_addr_reg==(rd_e_addr-rd_b_addr-DDR_RD_LEN*8))||(rd_brust_addr_reg==(rd_e_addr*2-rd_b_addr-DDR_RD_LEN*8)))
							begin
								if(pingpang==1'b1)
									rd_brust_addr_reg <= rd_b_addr;
								else
									rd_brust_addr_reg <= rd_e_addr;
							end
					end
				else
					begin
						if(rd_brust_addr_reg>=(rd_e_addr-rd_b_addr-DDR_RD_LEN*8))
							rd_brust_addr_reg <= rd_b_addr;
					end
			end
		else
			rd_brust_addr_reg <= rd_brust_addr_reg;


wr_fifo wr_fifo_inst
(
  .wr_clk		(wr_fifo_wr_clk),
  .wr_rst		(wr_rst||ui_rst_n),
  .wr_en		(wr_fifo_wr_en),
  .din			(wr_fifo_din),

  .rd_clk		(wr_fifo_rd_clk),
  .rd_rst		(wr_rst||ui_rst_n),
  .rd_en		(wr_fifo_rd_en),
  .dout			(wr_fifo_dout),

  .full			(wr_fifo_full),
  .almost_full	(wr_fifo_almost_full),
  .empty		(wr_fifo_empty),
  .almost_empty	(wr_fifo_almost_empty),

  .rd_data_count(wr_fifo_rd_data_count),
  .wr_data_count(wr_fifo_wr_data_count)
);
rd_fifo rd_fifo_inst
(
  .wr_clk		(rd_fifo_wr_clk),
  .wr_rst		(rd_rst||ui_rst_n),
  .wr_en		(rd_fifo_wr_en),
  .din			(rd_fifo_din),

  .rd_clk		(rd_fifo_rd_clk),
  .rd_rst		(rd_rst||ui_rst_n),
  .rd_en		(rd_fifo_rd_en),
  .dout			(rd_fifo_dout),

  .full			(rd_fifo_full),
  .almost_full	(rd_fifo_almost_full),
  .empty		(rd_fifo_empty),
  .almost_empty	(rd_fifo_almost_empty),

  .rd_data_count (rd_fifo_rd_data_count),
  .wr_data_count (rd_fifo_wr_data_count)
);


endmodule








