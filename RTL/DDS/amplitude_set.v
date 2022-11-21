////////////////////////////////////////////////////////////////////////////////
// Company  : 
// Engineer : 
// -----------------------------------------------------------------------------
// https://blog.csdn.net/qq_33231534    PHF's CSDN blog
// -----------------------------------------------------------------------------
// Create Date    : 2020-09-05 09:35:58
// Revise Data    : 2020-09-05 09:35:58
// File Name      : amplitude_set.v
// Target Devices : XC7Z015-CLG485-2
// Tool Versions  : Vivado 2019.2
// Revision       : V1.1
// Editor         : sublime text3, tab size (4)
// Description    : 信号电压幅度设置 1/2/4/8/16分之一
////////////////////////////////////////////////////////////////////////////////
module amplitude_set(
	input				clk		,
	input				rst_n	,
	input				key2_in	,

	output	reg	[4:0]	amplitude	
	);

	reg	[2:0]	cnt			;
	wire		key_flag	;
	wire		key_state	;


	key_filter amplitude_key (
				.clk       (clk),
				.rst_n     (rst_n),
				.key_in    (key2_in),
				.key_flag  (key_flag),
				.key_state (key_state)
			);

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			cnt <= 3'd0;
		end
		else if (key_flag) begin
			if (cnt == 3'd4) begin
				cnt <= 3'd0;
			end
			else begin
				cnt <= cnt + 1'b1;
			end
		end
	end

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			amplitude <= 0;			
		end
		else begin
			case(cnt)
				3'd0: amplitude <= 5'd1;
				3'd1: amplitude <= 5'd2;
				3'd2: amplitude <= 5'd4;
				3'd3: amplitude <= 5'd8;
				3'd4: amplitude <= 5'd16;
				default:amplitude <= 5'd1;
			endcase
		end
	end
endmodule
