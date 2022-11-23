`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/19 15:08:49
// Design Name: 
// Module Name: dilation
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



module dilation
(
	//global clock
	input					clk,  				//cmos video pixel clock
	input					rst_n,				//global reset
	
	//Image data prepred to be processd
	input					per_frame_vsync,	//Prepared Image data vsync valid signal
	input					per_frame_href,	//Prepared Image data href vaild  signal
	input					per_frame_clken,	//Prepared Image data output/capture enable clock
	input					per_img_Bit,		//Prepared Image brightness input
	
	//Image data has been processd
	output				post_frame_vsync,	//Processed Image data vsync valid signal
	output				post_frame_href,	//Processed Image data href vaild  signal
	output				post_frame_clken,	//Processed Image data output/capture enable clock
	output				post_img_Bit		//Processed Image Bit flag outout(1: Value, 0:inValid)
);
	
	
	//----------------------------------------------------
	//Generate 8Bit 3X3 Matrix for Video Image Processor.
	//Image data has been processd
	wire				matrix_frame_vsync;					//Prepared Image data vsync valid signal
	wire				matrix_frame_href;					//Prepared Image data href vaild  signal
	wire				matrix_frame_clken;					//Prepared Image data output/capture enable clock	
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
		.per_img_Y						({7'b0,per_img_Bit}),	//Prepared Image brightness input
	
		//Image data has been processd
		.matrix_frame_vsync				(matrix_frame_vsync),	//Prepared Image data vsync valid signal
		.matrix_frame_href				(matrix_frame_href),	//Prepared Image data href vaild  signal
		.matrix_frame_clken				(matrix_frame_clken),	//Prepared Image data output/capture enable clock	
		
		.matrix_p11(matrix_p11),	.matrix_p12(matrix_p12), 	.matrix_p13(matrix_p13),	//3X3 Matrix output
		.matrix_p21(matrix_p21), 	.matrix_p22(matrix_p22), 	.matrix_p23(matrix_p23),
		.matrix_p31(matrix_p31), 	.matrix_p32(matrix_p32), 	.matrix_p33(matrix_p33)
);

	
	//Eonsion with or operation
	//Step 1
	reg	post_img_Bit1,	post_img_Bit2,	post_img_Bit3;
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			begin
				post_img_Bit1 <= 1'b0;
				post_img_Bit2 <= 1'b0;
				post_img_Bit3 <= 1'b0;
			end
		else
			begin
				post_img_Bit1 <= matrix_p11[0] | matrix_p12[0] | matrix_p13[0];
				post_img_Bit2 <= matrix_p21[0] | matrix_p22[0] | matrix_p23[0];
				post_img_Bit3 <= matrix_p21[0] | matrix_p32[0] | matrix_p33[0];
			end
	end
	
	//Step 2
	reg post_img_Bit_r;
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			post_img_Bit_r <= 1'b0;
		else
			post_img_Bit_r <= post_img_Bit1 | post_img_Bit2 | post_img_Bit3;
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
				per_frame_vsync_r 	<= 	{per_frame_vsync_r[0], 	matrix_frame_vsync};
				per_frame_href_r 	<= 	{per_frame_href_r [0], 	matrix_frame_href};
				per_frame_clken_r 	<= 	{per_frame_clken_r[0], 	matrix_frame_clken};
			end
	end
	
	assign	post_frame_vsync 	= 	per_frame_vsync_r[1];
	assign	post_frame_href 	= 	per_frame_href_r [1];
	assign	post_frame_clken 	= 	per_frame_clken_r[1];
	assign	post_img_Bit		=	post_frame_href ? post_img_Bit_r : 1'b0;



endmodule
