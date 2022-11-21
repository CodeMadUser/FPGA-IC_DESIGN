module vga_ctrl
(
	input	wire			vga_clk		,
	input	wire			sys_rst_n	,
	input	wire	[15:0]	pix_data	,
	
	output	wire	[15:0]	rgb			,
	output	wire			rgb_valid	,
	output	wire			hsync		,
	output	wire			vsync		,
	output	wire			pix_data_req					
);
reg		[9:0]	cnt_h;
reg		[9:0]	cnt_v;
//wire			pix_data_req;
//wire			rgb_valid;

always@(posedge vga_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_h <= 10'd0;
	else if(cnt_h == 10'd799)
		cnt_h <= 10'd0;
	else
		cnt_h <= cnt_h + 1'b1;
		

always@(posedge vga_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_v <= 10'd0;
	else if((cnt_v==10'd524)&&(cnt_h==10'd799))
		cnt_v <= 10'd0;
	else if(cnt_h == 10'd799)
		cnt_v <= cnt_v + 1'b1;
	else
		cnt_v <= cnt_v;

assign rgb_valid = ((cnt_h>=10'd144)&&(cnt_h<=10'd783)&&(cnt_v>=10'd35)&&(cnt_v<=10'd514))?1'b1:1'b0;

assign pix_data_req = ((cnt_h>=10'd143)&&(cnt_h<=10'd782)&&(cnt_v>=10'd35)&&(cnt_v<=10'd514))?1'b1:1'b0;

assign pix_x = (pix_data_req==1'b1)?(cnt_h-10'd143):10'h3ff;

assign pix_y = (pix_data_req==1'b1)?(cnt_v-10'd35):10'h3ff;

assign hsync = (cnt_h<=10'd95)?1'b1:1'b0;

assign vsync = (cnt_v<=10'd1)?1'b1:1'b0;

assign rgb = (rgb_valid==1'b1)?pix_data:16'h0000;



endmodule