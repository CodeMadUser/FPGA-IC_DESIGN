module div_m_n
(
	input  wire sys_clk,
	input  wire sys_rst_n,
	output wire clk_out
);
	parameter M_N = 8'd87; 
	parameter c89 = 8'd24; // 8/9时钟切换点
	parameter div_e = 5'd8; //偶数周期
	parameter div_o = 5'd9; //奇数周期

	//用于产生分频输出的计数，当div_flag==0,计数最大值是div_e-1；当div_flag==1,计数最大值是div_o-1；
	reg	[3:0]	clk_cnt ;  
	//用来计数系统时钟产生的个数，达到最大值M_N后清零。
	reg	[6:0]	cyc_cnt	;  
	//8/9分频标志，当div_flag==0时8分频；当div_flag==1时9分频.当cyc_cnt==M_N-1或者cyc_cnt==c89-1时，该标志位翻转。
	reg		div_flag	;  
	//根据clk_cnt和div_flag产生分频输出。
	reg		clk_out_r	;
	
	always@(posedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			clk_cnt <= 4'd0;
		else if(~div_flag)
			begin
				if(clk_cnt==div_e-1)
					clk_cnt <= 4'd0;
				else
					clk_cnt <= clk_cnt + 1'b1;
			end
		else
			begin
				if(clk_cnt==div_o-1)
					clk_cnt <= 4'd0;
				else
					clk_cnt <= clk_cnt + 1'b1;
			end
	
	always@(posedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			cyc_cnt <= 7'd0;
		else if(cyc_cnt==M_N-1)
			cyc_cnt <= 7'd0;
		else
			cyc_cnt <= cyc_cnt + 1'b1;
			
	always@(posedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			div_flag <= 1'b0;
		else if(cyc_cnt==M_N-1 || cyc_cnt==c89-1)
			div_flag <= ~div_flag;
		else
			div_flag <= div_flag;

	always@(posedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			clk_out_r <= 1'b0;
		else if(~div_flag)
			clk_out_r <= (clk_cnt<=((div_e>>2)+1));
		else
			clk_out_r <= (clk_cnt<=((div_o>>2)+1));
	
	assign clk_out = clk_out_r;

endmodule













