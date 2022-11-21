module uart_sdram_vga
(
	input	wire			sys_clk			,
	input	wire			sys_rst_n		,
	input	wire			rx				,
	//输出到vga设备
	output	wire	[15:0]	rgb_vga			,
	output	wire			hsync			,
	output	wire			vsync			,
	//输出到SDRAM设备
	output	wire			sdram_clk		,//sdram时钟信号
	output	wire			sdram_cke		,//SDRAM时钟有效信号
	output	wire			sdram_cs_n		,//cs、cas、ras、we组成SDRAM
	output	wire			sdram_cas_n		,//的控制指令信号
	output	wire			sdram_ras_n		,
	output	wire			sdram_we_n		,
	output	wire	[1:0]	sdram_ba		,//bank地址
	output	wire	[12:0]	sdram_addr		,//存储单元地址
	output	wire	[1:0]	sdram_dqm		,//
	output	wire	[15:0]	sdram_dq		 //数据线路：存储/读取的字节数据
);

parameter	H_PIXEL		= 24'd640,
			V_PIXEL		= 24'd480,
			UART_BPS	= 'd115200,
			CLK_FREQ	= 'd50_000_000;

wire			clk_25			;
wire			clk_50			;
wire			clk_100			;
wire			clk_100_shift	;
wire			locked			;
wire			rst_n			;

wire	[7:0]	uart_po_data	;
wire			uart_po_flag	;

wire	[15:0]	data_in;

wire			pix_data_req	;
clk_gen	clk_gen_inst 
(
	.areset (~sys_rst_n		),
	.inclk0 (sys_clk		),
	.c0 	(clk_25			),
	.c1 	(clk_50			),
	.c2 	(clk_100		),
	.c3 	(clk_100_shift	),
	.locked (locked			)
);
assign rst_n = sys_rst_n & locked ;

uart_rx
#(
/**/
	.UART_BPS(UART_BPS)	,
	.CLK_FREQ(CLK_FREQ) 	
)
uart_rx_inst
(
	.sys_clk	(clk_50			),
	.sys_rst_n	(rst_n			),
	.rx			(rx				),

	.po_data	(uart_po_data	),
	.po_flag    (uart_po_flag	)
);

sdram_top sdram_top_inst
(
    .sys_clk         (clk_100		),   //系统时钟
    .clk_out         (clk_100_shift	),   //相位偏移时钟
    .sys_rst_n       (rst_n			),   //复位信号,低有效
//写FIFO信号
    .wr_fifo_wr_clk  (clk_50		),   //写FIFO写时钟
    .wr_fifo_wr_req  (uart_po_flag	),   //写FIFO写请求
    .wr_fifo_wr_data ({8'b0,uart_po_data}	),   //写FIFO写数据
    .sdram_wr_b_addr (24'd0			),   //写SDRAM首地址
    .sdram_wr_e_addr (H_PIXEL*V_PIXEL),   //写SDRAM末地址
    .wr_burst_len    (10'd512		),   //写SDRAM数据突发长度
    .wr_rst          (rst_n),   //写复位信号
//读FIFO信号
    .rd_fifo_rd_clk  (clk_50		),   //读FIFO读时钟
    .rd_fifo_rd_req  (pix_data_req	),   //读FIFO读请求
    .sdram_rd_b_addr (24'd0			),   //读SDRAM首地址
    .sdram_rd_e_addr (H_PIXEL*V_PIXEL),   //读SDRAM末地址
    .rd_burst_len    (10'd512		),   //读SDRAM数据突发长度
    .rd_rst          (),   //读复位信号
    .rd_fifo_rd_data (data_in),   //读FIFO读数据
    .rd_fifo_num     (),   //读fifo中的数据量

    .read_valid      (1'b1),   //SDRAM读使能
    .init_end        (),   //SDRAM初始化完成标志
//SDRAM接口信号
    .sdram_clk       (sdram_clk   ),   //SDRAM芯片时钟
    .sdram_cke       (sdram_cke   ),   //SDRAM时钟有效信号
    .sdram_cs_n      (sdram_cs_n  ),   //SDRAM片选信号
    .sdram_ras_n     (sdram_ras_n ),   //SDRAM行地址选通脉冲
    .sdram_cas_n     (sdram_cas_n ),   //SDRAM列地址选通脉冲
    .sdram_we_n      (sdram_we_n  ),   //SDRAM写允许位
    .sdram_ba        (sdram_ba    ),   //SDRAM的L-Bank地址线
    .sdram_addr      (sdram_addr  ),   //SDRAM地址总线
    .sdram_dqm       (sdram_dqm   ),   //SDRAM数据掩码
    .sdram_dq        (sdram_dq    )    //SDRAM数据总线
);

vga_ctrl vga_ctrl_inst
(
	.vga_clk	(clk_25),
	.sys_rst_n	(rst_n),
	.pix_data	({data_in[7:5],2'b0,data_in[4:2],3'b0,data_in[1:0],3'b0}),
	
	.rgb			(rgb_vga),
	.hsync			(hsync	),
	.vsync			(vsync	),
	.pix_data_req   (pix_data_req)
);























endmodule