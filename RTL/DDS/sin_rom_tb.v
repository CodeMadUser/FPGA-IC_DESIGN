////////////////////////////////////////////////////////////////////////////////
// Company  : 
// Engineer : 
// -----------------------------------------------------------------------------
// https://blog.csdn.net/qq_33231534    PHF's CSDN blog
// -----------------------------------------------------------------------------
// Create Date    : 2020-09-04 19:25:25
// Revise Data    : 2020-09-04 19:38:59
// File Name      : sin_rom_tb.v
// Target Devices : XC7Z015-CLG485-2
// Tool Versions  : Vivado 2019.2
// Revision       : V1.1
// Editor         : sublime text3, tab size (4)
// Description    : 
//////////////////////////////////////////////////////////////////////////////// 


`timescale 1ns/1ns

module sin_rom_tb (); /* this is automatically generated */

	reg clk;

	// (*NOTE*) replace reset, clock, others

	parameter DATA_WIDTH = 12;
	parameter ADDR_WIDTH = 12;

	reg [(ADDR_WIDTH-1):0] addr;
	wire [(DATA_WIDTH-1):0] q;

	localparam clk_period = 20;

	integer i;

	sin_rom #(
			.DATA_WIDTH(DATA_WIDTH),
			.ADDR_WIDTH(ADDR_WIDTH)
		) inst_sin_rom (
			.addr (addr),
			.clk  (clk),
			.q    (q)
		);

	initial clk = 0;
	always #(clk_period/2) clk =~clk;

	initial begin
		#1;
		#(clk_period*20);
		for(i=0;i<=100;i=i+1)begin
			addr = i;
			#clk_period;
		end
		#(clk_period*20);
		$stop;
	end




endmodule
