module complex_fsm
(
	input	wire	sys_clk,
	input	wire	sys_rst_n,
	input	wire	pi_money_one,
	input	wire	pi_money_half,
	
	output	reg		po_cola,
	output	reg		po_money
);
parameter	IDLE 	 = 5'b00001;
parameter	HALF 	 = 5'b00010;
parameter	ONE  	 = 5'b00100;
parameter	ONE_HALF = 5'b01000; 
parameter	TWO  	 = 5'b10000;

reg 	[4:0] state;
wire	[1:0] pi_money;

assign pi_money = {pi_money_one,pi_money_half};	
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		state <= IDLE;
	else case(state)
		IDLE:
			if(pi_money == 2'b01)
				state <= HALF;
			else if(pi_money == 2'b10)
				state <= ONE;
			else 
				state <= IDLE;
		HALF:
			if(pi_money == 2'b01)
				state <= ONE;
			else if(pi_money == 2'b10)
				state <= ONE_HALF;
			else 
				state <= HALF;
		ONE:
			if(pi_money == 2'b01)
				state <= ONE_HALF;
			else if(pi_money == 2'b10)
				state <= TWO;
			else 
				state <= ONE;
		ONE_HALF:
			if(pi_money == 2'b01)
				state <= TWO;
			else if(pi_money == 2'b10)
				state <= IDLE;
			else 
				state <= ONE_HALF;
		TWO:
			if((pi_money == 2'b01)||(pi_money == 2'b10))
				state <= IDLE;
			else 
				state <= TWO;
		default:state <= IDLE;
	endcase

always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		po_cola  <= 1'b0;
	else if((state == ONE_HALF && pi_money == 2'b10)
		    ||(state == TWO && pi_money == 2'b01)
			||(state == TWO && pi_money == 2'b10))
		po_cola  <= 1'b1;
	else
		po_cola  <= 1'b0;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		po_money <= 1'b0;
	else if((state == TWO)&&(pi_money == 2'b10))
		po_money <= 1'b1;
	else
		po_money <= 1'b0;
	
endmodule