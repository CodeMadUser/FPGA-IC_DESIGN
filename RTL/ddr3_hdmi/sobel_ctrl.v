`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:13:53 09/23/2022 
// Design Name: 
// Module Name:    sobel_ctrl 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module sobel_ctrl
(
	input	wire			sys_clk			,
	input	wire			sys_rst_n		,
	input	wire	[15:0]	data_in			,
	
	output	wire	[15:0]	data_out		
);
	parameter	LENGTH_P	=	10'd480	,	//图像长度
				WIDTH_P		=	10'd640	;	//图像宽度
				
	parameter	THRESHOLD	=	8'b0000_1100;	//比较阈值
	
	parameter	BLACK	=	8'b0000_0000	,	//黑色
				WHITE	=	8'b1111_1111	;	//白色
				
				
	wire	[15:0]		data_out1;      //fifo1数据输出
	wire	[15:0]		data_out2;      //fifo2数据输出
	
	reg		[15:0]		data_in_dly	;	//pi_data数据寄存
	reg		[9:0]		cnt_h	;       //行计数
	reg		[9:0]		cnt_v	;       //场计数
	reg					wr_en1	;       //fifo1写使能
	reg					wr_en2	;       //fifo2写使能
	reg		[15:0]		data_in1;       //fifo1写数据
	reg		[15:0]		data_in2;       //fifo2写数据
	reg					rd_en	;       //fifo1,fifo2共用读使能
	reg		[15:0]		data_out1_dly	; //fifo1数据输出寄存
	reg		[15:0]		data_out2_dly	; //fifo2数据输出寄存
	reg					data_out1_flag	; //使能信号
	reg					rd_en_dly1		; //输出数据标志信号,延后rd_en一拍
	reg					rd_en_dly2		; //a,b,c赋值标志信号
	reg					gx_gy_flag		; //gx,gy计算标志信号
	reg					gxy_flag		; //gxy计算标志信号
	reg					compare_flag	; //阈值比较标志信号
	reg		[9:0]		cnt_rd			; //读出数据计数器
	reg     [15:0]   	a1          ;		//图像数据
	reg     [15:0]   	a2          ;
	reg     [15:0]   	a3          ;
	reg     [15:0]   	b1          ;
	reg     [15:0]   	b2          ;
	reg     [15:0]   	b3          ;
	reg     [15:0]   	c1          ;
	reg     [15:0]   	c2          ;
	reg     [15:0]   	c3          ;   //图像数据
	reg     [8:0]   gx          ;
	reg     [8:0]   gy          ;   //gx,gy
	reg     [7:0]   gxy         ;   //gxy
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

endmodule
