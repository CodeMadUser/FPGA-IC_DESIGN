module seq_detect
(
	input	wire	clk		,
	input	wire	rst_b	,
	input	wire	signal_in	,
	output	reg		seq_flag
);
	parameter	IDLE=	3'd0,
				S1	=	3'd1,
				S2	=	3'd2,
				S3	=	3'd3,
				S4	=	3'd4;
	
	reg	[2:0]	cs , ns;
	always@(posedge clk or negedge rst_b)
		if(rst_b==1'b0)
			cs <= IDLE;
		else
			cs <= ns;
	always@(*)
		begin
			case(cs)
				IDLE:
					if(signal_in==1'b0)
						ns <= S1;
					else
						ns <= IDLE;
				S1	:
					if(signal_in==1'b1)
						ns <= S2;
					else
						ns <= S1;
				S2	:
					if(signal_in==1'b0)
						ns <= S3;
					else
						ns <= IDLE;
				S3	:
					if(signal_in==1'b0)
						ns <= S4;
					else
						ns <= S2;
				S4	:
					if(signal_in==1'b0)
						ns <=S1;
					else
						ns <= IDLE;
			endcase
		end
	always@(posedge clk or negedge rst_b)
		if(rst_b==1'b0)
			seq_flag <= 1'b0;
		else if(cs==S4)
			seq_flag<=~seq_flag;
		else
			seq_flag<=seq_flag;
endmodule





/*
慢到快：
	单bit：1、两级寄存器同步 
	多bit：1、异步FIFO；      2、异步双口RAM  
	
快到慢：
	单bit：1、脉冲展宽； 2、握手机制
	多bit: 1、异步FIFO;  2、异步双口RAM；3、格雷码；

*/

















