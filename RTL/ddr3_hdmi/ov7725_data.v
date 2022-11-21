`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:41:05 09/20/2022 
// Design Name: 
// Module Name:    ov7725_data 
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
module ov7725_data
(
	input	wire			ov7725_pclk		, //摄像头传入工作时钟，频率 24MHz
	input	wire			sys_rst_n		, //复位信号，低有效
	input	wire			ov7725_href		, //传入图像行有效区域
	input	wire			ov7725_vsync	, //传入图像场同步信号
	input	wire	[7:0]	ov7725_data		, //传入图像行有效区域
	//                                       
	output	wire			ov7725_wr_en	, //图像信息写入 DDR3 SDRAM 使能信号
	output	wire	[15:0]	ov7725_data_out	  //写入 DDR3 SDRAM 图像信息
);
	parameter	PIC_WAIT = 4'd10;  //图像需要舍弃的帧数，因为前10帧数据不稳定
	
	wire			pic_flag		;
	
	reg				ov7725_vsync_dly;
	reg		[3:0]	cnt_pic			;
	reg				pic_valid		;
	reg		[7:0]	pic_data_reg	;
	reg		[15:0]	data_out_reg	;
	reg				data_flag		;
	reg				data_flag_dly1	;
	
	//场同步信号打拍
	always@(posedge ov7725_pclk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			ov7725_vsync_dly <= 1'b0;
		else
			ov7725_vsync_dly <= ov7725_vsync;
			
	//场同步信号上升沿
	assign pic_flag = (ov7725_vsync==1'b1 && ov7725_vsync_dly==1'b0)?1'b1:1'b0;
	
	//图像帧计数器
	always@(posedge ov7725_pclk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			cnt_pic <= 4'd0;
		else if(pic_flag==1'b1 && cnt_pic<PIC_WAIT)
			cnt_pic <= cnt_pic + 1'b1;
		else 
			cnt_pic <= cnt_pic ;
	
	//图像有效标志
	always@(posedge ov7725_pclk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			pic_valid <= 1'b0;
		else if(cnt_pic==PIC_WAIT && pic_flag==1'b1)
			pic_valid <= 1'b1;
		else
			pic_valid <= pic_valid;
	
	//data_out_reg：输出16bit数据缓冲、pic_data_reg：输入8bit数据暂存、data_flag：图像输出16bit数据拼接标志
	always@(posedge ov7725_pclk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			begin
				data_out_reg <= 16'd0;
				pic_data_reg <= 8'd0;
				data_flag <= 1'b0;
			end
		else if(ov7725_href==1'b1)
			begin
				data_flag 	 <= ~data_flag;			//拼接标志
				pic_data_reg <= ov7725_data;		//8bit数据暂存
				data_out_reg <= data_out_reg;
				if(data_flag==1'b1)
					begin
						data_out_reg <= {pic_data_reg,ov7725_data};  //经过两个时钟周期将两个8bit数据拼接为16bit数据。
					end
				else
					data_out_reg <= data_out_reg;
			end
		else
			begin
				data_out_reg <= data_out_reg;
				pic_data_reg <= 8'd0;
				data_flag 	 <= 1'b0;
			end
	
	//图像输出16bit数据拼接标志信号打拍；
	always@(posedge ov7725_pclk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			data_flag_dly1 <= 1'b0;
		else
			data_flag_dly1 <= data_flag;
	
	//输出数据
	assign ov7725_data_out = (pic_valid==1'b1)?data_out_reg:16'd0;
	
	//输出使能
	assign ov7725_wr_en = (pic_valid==1'b1)?data_flag_dly1:1'b0;

endmodule
