module hdmi_ctrl
(
	input	wire			clk_in			,
	input	wire			clk_125M		,
	input	wire			sys_rst_n		,
	input	wire			hsync			,
	input	wire			vsync			,
	input	wire			rgb_valid		,
	input	wire	[7:0]	r				,
	input	wire	[7:0]	g				,
	input	wire	[7:0]	b				,
	
	output	wire			r_p				,
	output	wire			r_n				,
	output	wire			g_p				,
	output	wire			g_n				,
	output	wire			b_p				,
	output	wire			b_n				,
	output	wire			clk_p			,
	output	wire			clk_n			
);
wire	[9:0]	data_out1;
wire	[9:0]	data_out2;
wire	[9:0]	data_out3;


encoder encoder_inst_r
(
	.clk_in			(clk_in		),
	.sys_rst_n		(sys_rst_n	),
	.data_in		(r			),
	.hsync			(hsync		),
	.vsync			(vsync		),
	.rgb_valid		(rgb_valid	),

	.data_out	    (data_out1)
);
par_to_ser par_to_ser_inst_r
(
	.clk_125M		(clk_125M	),
	.data_in		(data_out1	),

	.ser_p			(r_p		),
	.ser_n			(r_n		) 
);

encoder encoder_inst_g
(
	.clk_in			(clk_in		),
	.sys_rst_n		(sys_rst_n	),
	.data_in		(g			),
	.hsync			(hsync		),
	.vsync			(vsync		),
	.rgb_valid		(rgb_valid	),

	.data_out	    (data_out2)
);
par_to_ser par_to_ser_inst_g
(
	.clk_125M		(clk_125M	),
	.data_in		(data_out2	),

	.ser_p			(g_p		),
	.ser_n			(g_n		)
);

encoder encoder_inst_b
(
	.clk_in			(clk_in		),
	.sys_rst_n		(sys_rst_n	),
	.data_in		(b			),
	.hsync			(hsync		),
	.vsync			(vsync		),
	.rgb_valid		(rgb_valid	),

	.data_out	    (data_out3)
);
par_to_ser par_to_ser_inst_b
(
	.clk_125M		(clk_125M	),
	.data_in		(data_out3	),

	.ser_p			(b_p		),
	.ser_n			(b_n		)
);

par_to_ser par_to_ser_inst_clk
(
	.clk_125M		(clk_125M),
	.data_in		(10'b11111_00000),

	.ser_p			(clk_p),
	.ser_n			(clk_n)
);


endmodule