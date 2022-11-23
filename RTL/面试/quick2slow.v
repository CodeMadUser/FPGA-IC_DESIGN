module quick2slow
(
	input	wire			clka	,
	input	wire			clkb	,
	input	wire			rst_n	,
	input	wire			sig_a	,
	
	output	wire			sig_b
);


reg		trig;
always@(posedge clka or negedge rst_n)
	if(!rst_n)
		trig <= 1'b0;
	else if(sig_a==1'b1)
		trig <= ~trig;
	else
		trig <= trig;
		
reg		sig_b_reg1;
reg		sig_b_reg2;
reg		sig_b_reg3;
always@(posedge clka or negedge rst_n)
	if(!rst_n)
		begin
			sig_b_reg1 <= 1'b0;
			sig_b_reg2 <= 1'b0;
			sig_b_reg3 <= 1'b0;
		end
	else
		begin
			sig_b_reg1 <= trig;
			sig_b_reg2 <= sig_b_reg1;
			sig_b_reg3 <= sig_b_reg2;
		end
		
assign sig_b = sig_b_reg3^ sig_b_reg2 ;


endmodule