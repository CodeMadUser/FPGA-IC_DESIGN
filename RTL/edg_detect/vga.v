module vga
(
	input	wire			sys_clk				,
	input	wire			vga_clk				,
	input	wire			sys_rst_n			,
	input	wire	[7:0]	pi_data				,
	input	wire			pi_flag				,

	output	wire	[7:0]	rgb					,
	output	wire			hsync				,
	output	wire			vsync	
);
wire	[9:0]	pix_x;
wire	[9:0]	pix_y;
wire	[7:0]	pix_data;

vga_ctrl vga_ctrl_inst
(
	.vga_clk	(vga_clk	),
	.sys_rst_n	(sys_rst_n	),
	.pix_data	(pix_data	),

	.rgb		(rgb		),
	.hsync		(hsync		),
	.vsync		(vsync		),
	.pix_x		(pix_x		),
	.pix_y      (pix_y		)
);

vga_pic vga_pic_inst
(
	.vga_clk	(vga_clk	),
	.sys_clk	(sys_clk	),
	.sys_rst_n	(sys_rst_n	),
	.pix_x		(pix_x		),
	.pix_y		(pix_y		),
	.rx_data	(pi_data	),
	.rx_flag	(pi_flag	),

	.pix_data   (pix_data	)
);


endmodule