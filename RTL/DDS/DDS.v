////////////////////////////////////////////////////////////////////////////////
// Company  : 
// Engineer : 
// -----------------------------------------------------------------------------
// https://blog.csdn.net/qq_33231534    PHF's CSDN blog
// -----------------------------------------------------------------------------
// Create Date    : 2020-09-04 17:09:55
// Revise Data    : 2020-09-04 17:31:29
// File Name      : DDS.v
// Target Devices : XC7Z015-CLG485-2
// Tool Versions  : Vivado 2019.2
// Revision       : V1.1
// Editor         : sublime text3, tab size (4)
// Description    : DDS模块
//////////////////////////////////////////////////////////////////////////////// 
module DDS(
	input				clk			,
	input				rst_n		,
	input		[25:0]	f_word		,
	input		[1:0]	wave_c		,
	input		[11:0]	p_word		,
	input		[4:0]	amplitude	,

	output	reg	[11:0]	dac_data	
	);

	localparam	DATA_WIDTH = 4'd12;
	localparam	ADDR_WIDTH = 4'd12;

	reg		[11:0]	addr	 ;
	wire	[11:0]	dac_data0;
	wire	[11:0]	dac_data1;
	wire	[11:0]	dac_data2;
	wire	[11:0]	dac_data3;


	//波形选择
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			dac_data <= 12'd0;
		end
		else begin
			case(wave_c)
				2'b00:dac_data <= dac_data0/amplitude;	//正弦波
				2'b01:dac_data <= dac_data1/amplitude;	//三角波
				2'b10:dac_data <= dac_data2/amplitude;	//锯齿波
				2'b11:dac_data <= dac_data3/amplitude;	//方波
				default:;
			endcase
		end
	end

	//相位累加器
	reg	[31:0]	fre_acc;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			fre_acc <= 0;
		end
		else begin
			fre_acc <= fre_acc + f_word;
		end
	end

	//生成查找表地址
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			addr <= 0;
		end
		else begin
			addr <= fre_acc[31:20] + p_word;
		end
	end

	//正弦波
	sin_rom #(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(ADDR_WIDTH)
	) inst_sin_rom (
		.addr (addr),
		.clk  (clk),
		.q    (dac_data0)
	);

	//三角波
	sanjiao_rom #(
			.DATA_WIDTH(DATA_WIDTH),
			.ADDR_WIDTH(ADDR_WIDTH)
		) inst_sanjiao_rom (
			.addr (addr),
			.clk  (clk),
			.q    (dac_data1)
		);

	//锯齿波
	juchi_rom #(
			.DATA_WIDTH(DATA_WIDTH),
			.ADDR_WIDTH(ADDR_WIDTH)
		) inst_juchi_rom (
			.addr (addr),
			.clk  (clk),
			.q    (dac_data2)
		);

	//方波
	fangbo_rom #(
			.DATA_WIDTH(DATA_WIDTH),
			.ADDR_WIDTH(ADDR_WIDTH)
		) inst_fangbo_rom (
			.addr (addr),
			.clk  (clk),
			.q    (dac_data3)
		);

endmodule
