module detect_seq
#(
	parameter	MAX_CNT	=	4
)
(
	input	wire			clk	,
	input	wire			rst_n	,
	input	wire			data_in	,
	output	reg		[4:0]	cnt_out
);
	parameter	IDLE=	3'd0,
				S0	=	3'd1,
				S1	=	3'd2,
				S2	=	3'd3,
				S3	=	3'd4,
				S4	=	3'd5,
				S5	=	3'd6;	
                 
    reg	[2:0]	cs,ns	;
	reg	[MAX_CNT:0]	cnt		;
	always@(posedge clk	or negedge rst_n)
		if(rst_n==1'b0)
			cs <= IDLE;
		else
			cs <= ns;
	always@(*)
		begin
			case(cs)
				IDLE:
					if(data_in==1'b1)
						ns <= S0;
					else
						ns <= IDLE;
				S0	:
					if(data_in==1'b1)
						ns <= S1;
					else
						ns <= S0;
				S1	:
					if(data_in==1'b0)
						ns <= S2;
					else
						ns <= S0;
				S2	:
					if(data_in==1'b0)
						ns <= S2;
					else
						ns <= S0;
				S3	:
					if(data_in==1'b1)
						ns <= S4;
					else
						ns	<= IDLE;
				S4	:
					if(data_in==1'b0)
						ns <= S5;
					else
						ns <= S1;
				S5	:
					if(data_in==1'b1)
						ns <= S0;
					else
						ns <= IDLE;
			endcase
		end
                 
    always@(posedge clk or negedge rst_n)
		if(rst_n==1'b0)
			cnt <= 5'd0;
		else if(cs==S5)
			cnt <= cnt + 1'b1;
		else
			cnt <= cnt;
	
endmodule

