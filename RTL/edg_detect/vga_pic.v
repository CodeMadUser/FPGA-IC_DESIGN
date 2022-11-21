module vga_pic
(
	input	wire			vga_clk		,
	input	wire			sys_clk		,
	input	wire			sys_rst_n	,
	input	wire	[9:0]	pix_x		,
	input	wire	[9:0]	pix_y		,
	input	wire	[7:0]	rx_data		,
	input	wire			rx_flag		,
	
	output	wire	[7:0]	pix_data
);
parameter	H_VALID = 10'd640	,
			V_VALID = 10'd480	;
			
parameter	H_PIC = 10'd98	,
			V_PIC = 10'd98	,
			PIC_SIZE = 14'd9604;
			
/* parameter	RED		 = 16'hf800,
			ORANGE   = 16'hfc00,
			YELLOW   = 16'hffe0,
			GREEN    = 16'h07e0,
			CYAN     = 16'h07ff,
			BLUE     = 16'h001f,
			PURPLE   = 16'hf81f,
			BLACK    = 16'h0000,
			WHITE    = 16'hffff,
			GRAY     = 16'hd69a; */
parameter	RED		=	8'b1110_0000,
			GREEN	=	8'b0001_1100,
			BLUE	=	8'b0000_0011,
			WHITE	=	8'b1111_1111,
			BLACK	=	8'b0000_0000;
			
wire				rd_en			;	
wire	[7:0]		pic_data		;	

reg		[13:0]		wr_addr			;
reg		[7:0]		data_pix		;
reg					pix_valid		;
reg		[13:0]		rd_addr		;

assign	pix_data = (pix_valid == 1'b1)? pic_data:data_pix;

assign rd_en =  (pix_x>=(((H_VALID-H_PIC)/2)-1'b1))
				&& (pix_x<(((H_VALID-H_PIC)/2)+H_PIC)-1'b1)  //rd_en在行同步信号下超前一个时钟周期
				&& (pix_y>=(((V_VALID-V_PIC)/2)))
				&& (pix_y<(((V_VALID-V_PIC)/2)+V_PIC)); //纵坐标不用超前

always@(posedge vga_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		pix_valid <= 1'b0;
	else
		pix_valid <= rd_en;
		
always@(posedge vga_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)		
		rd_addr <= 14'd0;
	else if(rd_addr == PIC_SIZE-1'b1)
		rd_addr <= 14'd0;
	else if(rd_en == 1'b1)
		rd_addr <= rd_addr + 1'b1;
	else
		rd_addr <= rd_addr ;
		
always@(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)		
		wr_addr <= 14'd0;
	else if(wr_addr == 14'd9999 && rx_flag == 1'b1)
		wr_addr <= 14'd0;
	else if(rx_flag == 1'b1)
		wr_addr <= wr_addr + 1'b1;
	else
		wr_addr <= wr_addr;


always@(posedge vga_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0)
		data_pix <= BLACK;
	else if(pix_x>=0 && pix_x<((H_VALID/10)*1))
		data_pix <= RED;
	else if(pix_x>=((H_VALID/10)*1) && pix_x<((H_VALID/10)*2))
		data_pix <= GREEN;
	else if(pix_x>=((H_VALID/10)*2) && pix_x<((H_VALID/10)*3))
		data_pix <= BLUE;
	else if(pix_x>=((H_VALID/10)*3) && pix_x<((H_VALID/10)*4))
		data_pix <= WHITE;
	else if(pix_x>=((H_VALID/10)*4) && pix_x<((H_VALID/10)*5))
		data_pix <= BLACK;
	else if(pix_x>=((H_VALID/10)*5) && pix_x<((H_VALID/10)*6))
		data_pix <= RED;
	else if(pix_x>=((H_VALID/10)*6) && pix_x<((H_VALID/10)*7))
		data_pix <= GREEN;
	else if(pix_x>=((H_VALID/10)*7) && pix_x<((H_VALID/10)*8))
		data_pix <= BLUE;
	else if(pix_x>=((H_VALID/10)*8) && pix_x<((H_VALID/10)*9))
		data_pix <= WHITE;
	else if(pix_x>=((H_VALID/10)*9) && pix_x< H_VALID)
		data_pix <= BLACK;
	else
		data_pix <= BLACK;

ram_pic	ram_pic_inst 
(
	.data 		( rx_data ),
	.inclock 	( sys_clk ),
	.outclock 	( vga_clk ),
	.rdaddress 	( rd_addr ),
	.wraddress 	( wr_addr ),
	.wren 		( rx_flag ),
	
	.q 			( pic_data )
);



endmodule