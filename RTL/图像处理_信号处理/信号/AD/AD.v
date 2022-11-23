module AD(
	input clk,
	input rst_n,
	input [11:0]data_in,
	output clk_ad,
	output Rs232_Tx
);

	assign clk_ad = clk;
	
	wire [7:0]data_byte;
	reg [7:0]data_ad;
	
	reg [7:0]data_ad1;
	reg [7:0]data_ad2;
	reg [7:0]data_ad3;
	reg [7:0]data_aver;
	
	uart_byte_tx uart_byte_tx(
		.Clk			(clk			),
		.Rst_n		(rst_n		),
		.data_byte	(data_byte	),
		.send_en		(1'b1			),
		.baud_set	(3'd0			),//9600
		
		.Rs232_Tx	(Rs232_Tx	),
		.Tx_Done		(				),
		.uart_state	( 				)
	);
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			data_ad <= 'd0;
		else
			data_ad <= data_in[7:0];
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			data_ad1 <= 'd0;
			data_ad2 <= 'd0;
			data_ad3 <= 'd0;
		end
		else begin
			data_ad1 <= data_ad;
			data_ad2 <= data_ad1;
			data_ad3 <= data_ad2;
		end
	end
	
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)
			data_aver <= 'd0;
		else
			data_aver <= (data_ad1 + data_ad2 + data_ad3)/3;
	end
	
	assign data_byte = data_aver;
	
endmodule
