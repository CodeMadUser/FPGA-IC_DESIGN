module code2code
(
	input		wire			clk_i			,
	input		wire			FrameValid_i	,
	input		wire			LineValid_i		,
	input		wire	[7:0]	Y_444_i			,
	input		wire	[7:0]	U_444_i			,
	input		wire	[7:0]	V_444_i			,
	
	output		wire	[7:0]	Y_422_o			,
	output		wire	[7:0]	UV_422_o
);

	reg		FrameValid	;
	reg		LineValid	;
	always@(posedge clk_i)
		begin
			FrameValid <= FrameValid_i;
		end
		
	always@(posedge clk_i)
		begin
			if(FrameValid==1'b1)
				LineValid <= LineValid_i;
			else
				LineValid <= 1'b0;
		end
	
	
	assign Y_422_o = (LineValid==1'b1)?{Y_444_i[7:4],U_444_i[7:6],V_444_i[7:6]}:8'b0;
	assign UV_422_o = (LineValid==1'b1)?{Y_444_i[3:0],U_444_i[5:4],V_444_i[5:4]}:8'b0;

endmodule


