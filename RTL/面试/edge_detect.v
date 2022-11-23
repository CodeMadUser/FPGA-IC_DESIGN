module edge_detect
(
	input	wire			clk		,
	input	wire			rst_n	,
	input	wire	[1:0]	sel		,
	input	wire			din		,
	output	wire			flag
);
	reg		din_reg1;
	reg		din_reg2;
	wire	din_rise;
	wire	din_fall;
	wire	din_dd	;
	reg		flag_t	;
	always@(posedge clk or negedge rst_n)
		if(rst_n==1'b0)
			begin
				din_reg1 <= 1'b0;
				din_reg2 <= 1'b0;
			end
		else
			begin
				din_reg1 <= din;
				din_reg2 <= din_reg1;
			end
			
	assign	din_rise = ((din_reg1==1'b1)&&(din_reg2==1'b0));
	assign	din_fall = ((din_reg1==1'b0)&&(din_reg2==1'b1));
	assign	din_dd	 = (din_reg1 ^ din_reg2 );
	always@(posedge clk or negedge rst_n)
		if(rst_n==1'b0)
			flag_t <= 1'b0;
		else
			begin
				case(sel)
					2'b00:
						if(din_rise==1'b1)
							flag_t <= 1'b1;
						else
							flag_t <= 1'b0;
					2'b01:
						if(din_fall==1'b1)
							flag_t <= 1'b1;
						else
							flag_t <= 1'b0;
					2'b10,2'b11:
						if(din_dd==1'b1)
							flag_t <= 1'b1;
						else
							flag_t <= 1'b0;
					default:
						flag_t <= 1'b0;
				end
			end

	assign flag = flag_t;

endmodule


