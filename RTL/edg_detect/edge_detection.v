module edge_detection
(
	input	wire				sys_clk			,
	input	wire				sys_rst_n		,
	input	wire				rx				,
	
	output	wire				tx				,
	output	wire		[7:0]	rgb				,
	output	wire				hsync			,
	output	wire				vsync
);
wire			clk_50M		;
wire			clk_25M		;
wire			locked		;
wire	[7:0]	rx_po_data	;
wire			rx_po_flag	;
wire	[7:0]	sobel_po_data;
wire			sobel_po_flag;
wire	[7:0]	vga_pi_data	;
wire			vga_pi_flag	;

clk_gen	clk_gen_inst 
(
	.areset (~sys_rst_n	),
	.inclk0 (sys_clk	),
	.c0 	(clk_50M	),
	.c1 	(clk_25M	),
	.locked (locked		)
);

assign	rst_n = locked & sys_rst_n;

uart_rx
#(
/**/
	.UART_BPS('d9600	  )	,
	.CLK_FREQ('d50_000_000) 
)
uart_rx_inst
(
	.sys_clk		(clk_50M	),
	.sys_rst_n		(rst_n		),
	.rx				(rx			),

	.po_data		(rx_po_data	),
	.po_flag        (rx_po_flag	)
);

sobel_ctrl sobel_ctrl_inst
(
	.sys_clk		(clk_50M	),
	.sys_rst_n		(rst_n		),
	.data_in		(rx_po_data	),
	.pi_flag		(rx_po_flag	),

	.po_data		(sobel_po_data),
	.po_flag	    (sobel_po_flag)
);

vga vga_inst
(
	.sys_clk			(clk_50M		),
	.vga_clk			(clk_25M		),
	.sys_rst_n			(rst_n			),
	.pi_data			(sobel_po_data	),
	.pi_flag			(sobel_po_flag	),

	.rgb				(rgb			),
	.hsync				(hsync			),
	.vsync	            (vsync			)
);

uart_tx
#(
/**/
	.UART_BPS('d9600		),
	.CLK_FREQ('d50_000_000	) 	
)
uart_tx_inst
(
	.sys_clk		(clk_50M		),
	.sys_rst_n		(rst_n			),
	.pi_data		(sobel_po_data	),
	.pi_flag		(sobel_po_flag	),

	.tx             (tx				)
);

endmodule