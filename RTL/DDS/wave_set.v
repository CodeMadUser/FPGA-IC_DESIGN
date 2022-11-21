////////////////////////////////////////////////////////////////////////////////
// Company  : 
// Engineer : 
// -----------------------------------------------------------------------------
// https://blog.csdn.net/qq_33231534    PHF's CSDN blog
// -----------------------------------------------------------------------------
// Create Date    : 2020-09-04 15:10:48
// Revise Data    : 2020-09-04 15:23:44
// File Name      : wave_set.v
// Target Devices : XC7Z015-CLG485-2
// Tool Versions  : Vivado 2019.2
// Revision       : V1.1
// Editor         : sublime text3, tab size (4)
// Description    : dds信号发生器的波形选择，按键按下切换波形
//////////////////////////////////////////////////////////////////////////////// 

module wave_set(
	input				clk		,
	input				rst_n	,
	input				key0_in	,

	output	reg	[1:0]	wave_c		//wave_c oo~正弦波  01~三角波  10~锯齿波  11~方波
	);

	wire	key_flag	;
	wire	key_state	;

	key_filter wave_key (
			.clk       (clk),
			.rst_n     (rst_n),
			.key_in    (key0_in),
			.key_flag  (key_flag),
			.key_state (key_state)
		);

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			wave_c <= 0; //默认正弦波
		end
		else if (key_flag) begin
			wave_c <= wave_c + 1'b1;
		end
	end
endmodule
