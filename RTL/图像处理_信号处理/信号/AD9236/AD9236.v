module AD9236(
	CLK, 
	AD_IN,
	AD_CLK, 
	AD_OUT
);

   input CLK; 
	input[11:0] AD_IN;
   output AD_CLK; 
   output[11:0] AD_OUT; 
   reg[11:0] AD_OUT;
	
	assign AD_CLK = CLK;
	
	always @(posedge CLK)
		AD_OUT <= AD_IN;  
	
endmodule
