module encoder
(
	input	wire				clk_in			,
	input	wire				sys_rst_n		,
	input	wire		[7:0]	data_in			,
	input	wire				hsync			,
	input	wire				vsync			,
	input	wire				rgb_valid		,
	
	output	reg			[9:0]	data_out	
);
wire			ctrl_1			;
wire			ctrl_2			;
wire			ctrl_3			;
wire	[8:0]	q_m				;

reg		[3:0]	data_in_n1		;
reg		[7:0]	data_in_reg		;
reg		[3:0]	q_m_n1			;
reg		[3:0]	q_m_n0			;
reg		[4:0]	cnt				;
reg		[8:0]	q_m_reg			;
reg				rgb_valid_reg1	;
reg				rgb_valid_reg2	;
reg				hsync_reg1		;
reg				hsync_reg2		;
reg				vsync_reg1		;
reg				vsync_reg2		;




always@(posedge clk_in or negedge sys_rst_n)
	if(sys_rst_n==1'b0)
		data_in_n1 <= 4'd0;
	else 
		data_in_n1 <= data_in[0]+data_in[1]+data_in[2]
					  +data_in[3]+data_in[4]+data_in[5]
					  +data_in[6]+data_in[7];
		//此时data_in_n1这个只还不能直接用于后面计算，由于是时序逻辑，
		//data_in_n1会晚data_in一个时钟周期，此时比较的话，data_in中数值与所求其值中1的个数对应不上，
		//需要延迟一个时钟周期。

always@(posedge clk_in or negedge sys_rst_n)
	if(sys_rst_n==1'b0)
		data_in_reg <= 8'b0;
	else   //此时data_in_reg可以用于后续运算了
		data_in_reg <= data_in;

assign	ctrl_1 = ((data_in_n1 > 4'd4) || (data_in_n1==4'd4 && data_in_reg[0]==0))? 1'b1:1'b0;

//assign	data_out_m = (ctrl_1==1'b1)?{1'b1,data_out_m[6:0]^data_in_reg[7:1],data_in_reg[0]}:{1'b0,~(data_out_m[6:0]^data_in_reg[7:1]),data_in_reg[0]};
		
assign	q_m[0] = data_in_reg[0],
		q_m[1] = (ctrl_1==1'b1)?(q_m[0]^~data_in_reg[1]):(q_m[0]^data_in_reg[1]),
		q_m[2] = (ctrl_1==1'b1)?(q_m[1]^~data_in_reg[2]):(q_m[1]^data_in_reg[2]),
		q_m[3] = (ctrl_1==1'b1)?(q_m[2]^~data_in_reg[3]):(q_m[2]^data_in_reg[3]),
		q_m[4] = (ctrl_1==1'b1)?(q_m[3]^~data_in_reg[4]):(q_m[3]^data_in_reg[4]),
		q_m[5] = (ctrl_1==1'b1)?(q_m[4]^~data_in_reg[5]):(q_m[4]^data_in_reg[5]),
		q_m[6] = (ctrl_1==1'b1)?(q_m[5]^~data_in_reg[6]):(q_m[5]^data_in_reg[6]),
		q_m[7] = (ctrl_1==1'b1)?(q_m[6]^~data_in_reg[7]):(q_m[6]^data_in_reg[7]),
		q_m[8] = (ctrl_1==1'b1)?1'b0:1'b1;

always@(posedge clk_in or negedge sys_rst_n)
	if(sys_rst_n==1'b0)
		begin
			q_m_n1 <= 4'd0;
			q_m_n0 <= 4'd0;
		end
	else begin
		q_m_n1 <=	q_m[0]+q_m[1]+q_m[2]
					+q_m[3]+q_m[4]+q_m[5]
					+q_m[6]+q_m[7];
		q_m_n0 <= 4'd8 - (q_m[0]+q_m[1]+q_m[2]
					+q_m[3]+q_m[4]+q_m[5]
					+q_m[6]+q_m[7]);
		
	end
	
always@(posedge clk_in or negedge sys_rst_n)
	if(sys_rst_n==1'b0)
		begin
			q_m_reg 		<= 9'b0;
			rgb_valid_reg1	<= 1'b0;
			rgb_valid_reg2	<= 1'b0;
			hsync_reg1		<= 1'b0;
			hsync_reg2		<= 1'b0;
			vsync_reg1		<= 1'b0;
			vsync_reg2      <= 1'b0;
		end 
	else
		begin
			q_m_reg 		<= q_m;
			rgb_valid_reg1	<= rgb_valid;
			rgb_valid_reg2	<= rgb_valid_reg1;
			hsync_reg1		<= hsync;
			hsync_reg2		<= hsync_reg1;
			vsync_reg1		<= vsync;
			vsync_reg2      <= vsync_reg1;
		end

assign	ctrl_2 = ((cnt==5'd0)||(q_m_n1==q_m_n0))?1'b1:1'b0;

assign	ctrl_3 = ((cnt[4] == 1'b0 && q_m_n1>q_m_n0)||(cnt==1'b1 && q_m_n0>q_m_n1))?1'b1:1'b0;

always@(posedge clk_in or negedge sys_rst_n)
	if(sys_rst_n==1'b0)
		begin
			data_out 	<= 10'b0;
			cnt			<= 5'd0;
		end
	else
		begin
			if(rgb_valid_reg2==1'b1)
				begin
					if(ctrl_2==1'b1)
						begin
							data_out[9]   <= ~q_m_reg[8];
							data_out[8]	  <= q_m_reg[8];
							data_out[7:0] <= (q_m_reg[8])?q_m_reg[7:0]:~q_m_reg[7:0]; 
							cnt <= (q_m_reg[8]==1'b0)?(cnt+q_m_n0-q_m_n1):(cnt+q_m_n1-q_m_n0);
						end
					else
						begin
							if(ctrl_3==1'b1)
								begin
									data_out[9] <= 1'b1 ;
									data_out[8]	<= q_m_reg[8];
									data_out[7:0] <= ~q_m_reg[7:0];
									cnt <= cnt + {q_m_reg[8],1'b0}+q_m_n0-q_m_n1;
								end
							else
								begin
									data_out[9] <= 1'b0 ;
									data_out[8]	<= q_m_reg[8];
									data_out[7:0] <= q_m_reg[7:0];
									cnt <= cnt - {~q_m_reg[8],1'b0}+q_m_n0-q_m_n1;
								end
						end
				end
			else
				begin
					case({vsync_reg2,hsync_reg2})
						2'b00:data_out <= 10'b00101_01011;
						2'b01:data_out <= 10'b11010_10100;
						2'b10:data_out <= 10'b00101_01010;
						default:data_out <= 10'b11010_10101;
					endcase
					cnt <= 5'd0;
				end
		end


endmodule