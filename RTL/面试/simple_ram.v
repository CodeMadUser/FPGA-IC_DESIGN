module simple_ram
(
	input	wire 			sys_clk		,
	input	wire			sys_rst_n	,
	input	wire			wr_en		,
	input	wire	[7:0]	wr_data		,
	input	wire	[3:0]	wr_addr		,
	input	wire			rd_en		,
	input	wire	[3:0]	rd_addr		,
	output	reg		[7:0]	rd_data
);
	integer	i;
	reg	[7:0]	data_reg	[3:0]	;
	always@(posedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			begin
				for(i=0;i<8;i=i+1)
					data_reg[i] <= 8'b0;
			end
		else
			begin
				if(wr_en)
					data_reg[wr_addr] <= wr_data;
				else
					data_reg[wr_addr] <= data_reg[wr_addr];
			end
	
	always@(posedge sys_clk or negedge sys_rst_n)
		if(sys_rst_n==1'b0)
			rd_data <= 8'd0;
		else if(rd_en)
			rd_data <= data_reg[rd_addr];
		else
			rd_data <= rd_data;


endmodule










