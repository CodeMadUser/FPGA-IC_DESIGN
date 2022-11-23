module div_5
(
	input	wire	sys_clk		,
	input	wire	sys_rst_n	,
	output	wire	clk_5		
);
	reg	[2:0]	cnt_rise;
	reg	[2:0]	cnt_fall;
	reg			clk_rise;
	reg			clk_fall;
	always@(posedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			cnt_rise <= 3'd0;
		else if(cnt_rise==3'd4)
			cnt_rise <= 3'd0;
		else
			cnt_rise <= cnt_rise + 1'b1;
			
	always@(posedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			clk_rise <= 1'b1;
		else if(cnt_rise==3'd1 || cnt_rise==3'd4)
			clk_rise <= ~clk_rise;
		else
			clk_rise <= clk_rise;
			
	always@(negedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			cnt_fall <= 3'd0;
		else if(cnt_fall==3'd4)
			cnt_fall <= 3'd0;
		else
			cnt_fall <= cnt_fall + 1'b1;
			
	always@(negedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			clk_fall <= 1'b1;
		else if(cnt_fall==3'd1 || cnt_fall==3'd4)
			clk_fall <= ~clk_fall;
		else
			clk_fall <= clk_fall;

	assign clk_5 = clk_rise | clk_fall;


endmodule








