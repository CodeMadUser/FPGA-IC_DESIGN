module cdc_m
(
	input	wire	clka		,
	input	wire	signal_in	,
	input	wire	clkb		,
	input	wire	rst_n		,
	output	reg		signal_out
);
	reg		signal_in_reg	;
	reg		cnt;
	always@(posedge clka or negedge rst_n)
		if(rst_n==1'b0)
			signal_in_reg <= 1'b0;
		else
			signal_in_reg <= signal_in;
			
	always@(posedge clkb or negedge rst_n)
		if(rst_n==1'b0)
			
	always@(posedge clkb or negedge rst_n)
		if(rst_n==1'b0)
			signal_out <= 1'b0;
		else if(signal_in_reg==1'b1)






















endmodule


