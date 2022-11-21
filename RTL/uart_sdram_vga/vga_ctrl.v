module vga_ctrl
(
	input	wire			vga_clk		,
	input	wire			sys_rst_n	,
	input	wire	[15:0]	pix_data	,
	
	output	wire	[15:0]	rgb			,
	output	wire			hsync		,
	output	wire			vsync		,
	//output	wire	[9:0]	pix_x		,
	//output	wire	[9:0]	pix_y		,
	output	wire			pix_data_req
);

parameter H_SYNC    =   10'd96  ,   //行同步
          H_BACK    =   10'd40  ,   //行时序后沿
          H_LEFT    =   10'd8   ,   //行时序左边框
          H_VALID   =   10'd640 ,   //行有效数据
          H_RIGHT   =   10'd8   ,   //行时序右边框
          H_FRONT   =   10'd8   ,   //行时序前沿
          H_TOTAL   =   10'd800 ;   //行扫描周期
parameter V_SYNC    =   10'd2   ,   //场同步
          V_BACK    =   10'd25  ,   //场时序后沿
          V_TOP     =   10'd8   ,   //场时序上边框
          V_VALID   =   10'd480 ,   //场有效数据
          V_BOTTOM  =   10'd8   ,   //场时序下边框
          V_FRONT   =   10'd2   ,   //场时序前沿
          V_TOTAL   =   10'd525 ;   //场扫描周期

reg		[9:0]	cnt_h;
reg		[9:0]	cnt_v;
//wire			pix_data_req;
wire			rgb_valid;

always@(posedge vga_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_h <= 10'd0;
	else if(cnt_h == H_TOTAL-1)
		cnt_h <= 10'd0;
	else
		cnt_h <= cnt_h + 1'b1;
		

always@(posedge vga_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		cnt_v <= 10'd0;
	else if((cnt_v==V_TOTAL-1)&&(cnt_h==H_TOTAL-1))
		cnt_v <= 10'd0;
	else if(cnt_h == H_TOTAL-1)
		cnt_v <= cnt_v + 1'b1;
	else
		cnt_v <= cnt_v;

assign rgb_valid = ((cnt_h>=H_SYNC + H_BACK + H_LEFT)
					&&(cnt_h<=H_SYNC + H_BACK + H_LEFT + H_VALID)
					&&(cnt_v>=V_SYNC + V_BACK + V_TOP)
					&&(cnt_v<=V_SYNC + V_BACK + V_TOP + V_VALID))?1'b1:1'b0;

assign pix_data_req = ((cnt_h>=H_SYNC + H_BACK + H_LEFT - 1'b1)
						&&(cnt_h<=H_SYNC + H_BACK + H_LEFT + H_VALID - 1'b1)
						&&(cnt_v>=V_SYNC + V_BACK + V_TOP)
						&&(cnt_v<=V_SYNC + V_BACK + V_TOP + V_VALID-1'd1))?1'b1:1'b0;

//assign pix_x = (pix_data_req==1'b1)?(cnt_h-10'd143):10'h3ff;

//assign pix_y = (pix_data_req==1'b1)?(cnt_v-10'd35):10'h3ff;

assign hsync = (cnt_h<=H_SYNC-1'd1)?1'b1:1'b0;

assign vsync = (cnt_v<=V_SYNC-1'd1)?1'b1:1'b0;

assign rgb = (rgb_valid==1'b1)?pix_data:16'b0;



endmodule