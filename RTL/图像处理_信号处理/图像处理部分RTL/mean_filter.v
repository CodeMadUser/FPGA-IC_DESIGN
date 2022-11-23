`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/19 10:17:25
// Design Name: 
// Module Name: mean_filter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mean_filter
(
		//global clock
		input					clk,  				//cmos video pixel clock
		input					rst_n,				//global reset
	
		//Image data prepred to be processd
		input					per_frame_vsync,	//Prepared Image data vsync valid signal
		input					per_frame_href,		//Prepared Image data href vaild  signal
		input					per_frame_clken,	//Prepared Image data output/capture enable clock
		input		[7:0]		per_img_Y,			//Prepared Image brightness input
		
		//Image data has been processd
		output					post_frame_vsync,	//Processed Image data vsync valid signal
		output					post_frame_href,	//Processed Image data href vaild  signal
		output					post_frame_clken,	//Processed Image data output/capture enable clock
		output		[7:0]		post_img_Y			//Processed Image Bit flag outout(1: Value, 0:inValid)
		
);

	//----------------------------------------------------
	//Generate 8Bit 3X3 Matrix for Video Image Processor.
	//Image data has been processd
	wire				matrix_frame_vsync;	//Prepared Image data vsync valid signal
	wire				matrix_frame_href;	//Prepared Image data href vaild  signal
	wire				matrix_frame_clken;	//Prepared Image data output/capture enable clock	
	wire		[7:0]	matrix_p11, matrix_p12, matrix_p13;	//3X3 Matrix output
	wire		[7:0]	matrix_p21, matrix_p22, matrix_p23;
	wire		[7:0]	matrix_p31, matrix_p32, matrix_p33;
	
	Shift_RAM_3X3 Shift_RAM_3X3_inst
	(
		//global clock
		.clk							(clk),  				//cmos video pixel clock
		.rst_n							(rst_n),				//global reset
		.per_frame_vsync				(per_frame_vsync),		//Prepared Image data vsync valid signal
		.per_frame_href					(per_frame_href),		//Prepared Image data href vaild  signal
		.per_frame_clken				(per_frame_clken),		//Prepared Image data output/capture enable clock
		.per_img_Y						(per_img_Y),			//Prepared Image brightness input
	
		//Image data has been processd
		.matrix_frame_vsync				(matrix_frame_vsync),	//Prepared Image data vsync valid signal
		.matrix_frame_href				(matrix_frame_href),	//Prepared Image data href vaild  signal
		.matrix_frame_clken				(matrix_frame_clken),	//Prepared Image data output/capture enable clock	
		
		.matrix_p11(matrix_p11),	.matrix_p12(matrix_p12), 	.matrix_p13(matrix_p13),	//3X3 Matrix output
		.matrix_p21(matrix_p21), 	.matrix_p22(matrix_p22), 	.matrix_p23(matrix_p23),
		.matrix_p31(matrix_p31), 	.matrix_p32(matrix_p32), 	.matrix_p33(matrix_p33)
);

	
	//---------------------------------------------//
	//step1
	reg [9:0] mean_value1;
	reg [9:0] mean_value2;
	reg [9:0] mean_value3;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n) 
			begin
				mean_value1 <= 0;
				mean_value2 <= 0;
				mean_value3 <= 0;
			end
		else 
			begin
				mean_value1 <= matrix_p11 + matrix_p12 + matrix_p13;
				mean_value2 <= matrix_p21 +   8'd0	   + matrix_p23;
				mean_value3 <= matrix_p31 + matrix_p32 + matrix_p33;
			end
	end

	//step2
	reg [11:0] mean_value;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			mean_value <= 0;
		else
			mean_value <= mean_value1 + mean_value2 + mean_value3;
	end	
	
	
	
	//------------------------------------------
	//lag 2 clocks signal sync  
	reg	[1:0]	per_frame_vsync_r;
	reg	[1:0]	per_frame_href_r;
	reg	[1:0]	per_frame_clken_r;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			begin
				per_frame_vsync_r <= 0;
				per_frame_href_r  <= 0;
				per_frame_clken_r <= 0;
			end
		else
			begin
				per_frame_vsync_r 	<= 	{per_frame_vsync_r[0], matrix_frame_vsync};
				per_frame_href_r 	<= 	{per_frame_href_r [0], matrix_frame_href};
				per_frame_clken_r 	<= 	{per_frame_clken_r[0], matrix_frame_clken};
			end
	end
	
	assign	post_frame_vsync 	= 	per_frame_vsync_r[1];
	assign	post_frame_href 	= 	per_frame_href_r [1];
	assign	post_frame_clken 	= 	per_frame_clken_r[1];
	assign	post_img_Y			=	post_frame_href ? mean_value/16 : 8'd0;
	
	
endmodule

