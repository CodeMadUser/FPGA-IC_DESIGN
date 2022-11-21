////////////////////////////////////////////////////////////////////////////////
// Company  : 
// Engineer : 
// -----------------------------------------------------------------------------
// https://blog.csdn.net/qq_33231534    PHF's CSDN blog
// -----------------------------------------------------------------------------
// Create Date    : 2020-09-04 15:25:53
// Revise Data    : 2020-09-04 17:06:45
// File Name      : F_word_set.v
// Target Devices : XC7Z015-CLG485-2
// Tool Versions  : Vivado 2019.2
// Revision       : V1.1
// Editor         : sublime text3, tab size (4)
// Description    : 频率控制字的生成
//////////////////////////////////////////////////////////////////////////////// 

module F_word_set(
	input				clk		,
	input				rst_n	,
	input				key1_in	,

	output	reg	[25:0]	f_word	
	);
	
	wire		key_flag	;
	wire		key_state	;
	reg	[3:0]	cnt			;

	key_filter fword_key (
			.clk       (clk),
			.rst_n     (rst_n),
			.key_in    (key1_in),
			.key_flag  (key_flag),
			.key_state (key_state)
		);

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			cnt <= 4'd0;
		end
		else if (key_flag) begin
			if (cnt==4'd10) begin
				cnt <= 4'd0;
			end
			else begin
				cnt <= cnt + 1'b1;
			end
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			f_word <= 0;
		end
		else begin
			case(cnt)
				4'd0:f_word = 26'd86;		//1Hz
				4'd1:f_word = 26'd859;		//10Hz
				4'd2:f_word = 26'd8590;		//100Hz
				4'd3:f_word = 26'd42950;	//500Hz
				4'd4:f_word = 26'd85899;	//1kHz
				4'd5:f_word = 26'd429497;	//5kHz
				4'd6:f_word = 26'd858993;	//10kHz
				4'd7:f_word = 26'd4294967;	//50kHz
				4'd8:f_word = 26'd8589935;	//100kHz
				4'd9:f_word = 26'd17179869;	//200kHz
				4'd10:f_word = 26'd42949673;//500kHz
				default:;
			endcase
		end
	end
endmodule
