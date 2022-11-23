module add_char
(
	input	wire	clk	,
	input	wire	rst_n	,
	input	wire	[20:0]	A,
	input	wire	[17:0]	B,
	output	wire	[21:0]	C
);
	//寄存
	reg	[20:0]	reg_A;
	reg	[17:0]	reg_B;
	always@(posedge clk or negedge rst_n)
		if()


























endmodule


