////////////////////////////////////////////////////////////////////////////////
// Company  : 
// Engineer : 
// -----------------------------------------------------------------------------
// https://blog.csdn.net/qq_33231534    PHF's CSDN blog
// -----------------------------------------------------------------------------
// Create Date    : 2020-09-04 19:07:11
// Revise Data    : 2020-09-04 22:50:36
// File Name      : DDS_top_tb.v
// Target Devices : XC7Z015-CLG485-2
// Tool Versions  : Vivado 2019.2
// Revision       : V1.1
// Editor         : sublime text3, tab size (4)
// Description    : 
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns
module DDS_top_tb();

	reg					clk			;
	reg					rst_n		;
	reg					key0_in		;
	reg					key1_in		;
	reg					key2_in		;

	wire	[11:0]		dac_data	;

	localparam	clk_period = 20;

	DDS_top inst_DDS_top
		(
			.clk      (clk),
			.rst_n    (rst_n),
			.key0_in  (key0_in),
			.key1_in  (key1_in),
			.key2_in  (key2_in),
			.dac_data (dac_data)
		);


		initial clk = 0;
		always #(clk_period/2) clk = ~clk;

		initial begin
			#1;
			rst_n = 0;
			key0_in = 1;
			key1_in = 1;
			key2_in = 1;
			#(clk_period*20);
			rst_n = 1;
			#(clk_period*10);

			// key0_in = 0;
			// #30000000;
			// key0_in = 1;
			// #30000000;
			// key0_in = 0;
			// #30000000;
			// key0_in = 1;
			// #30000000;
			// key0_in = 0;
			// #30000000;
			// key0_in = 1;

			//#2000000000;

			key1_in = 0;
			#30000000;
			key1_in = 1;
			#30000000;
			//#200000000;

			key1_in = 0;
			#30000000;
			key1_in = 1;
			#30000000;
			//#20000000;

			key1_in = 0;
			#30000000;
			key1_in = 1;
			#30000000;
			#4000000;

			key2_in = 0;
			#30000000;
			key2_in = 1;
			#30000000;
			#4000000;

			key2_in = 0;
			#30000000;
			key2_in = 1;
			#30000000;
			#4000000;
			
			key2_in = 0;
			#30000000;
			key2_in = 1;
			#30000000;
			#4000000;

			// key1_in = 0;
			// #30000000;
			// key1_in = 1;
			// #30000000;
			// #2000000;

			// key1_in = 0;
			// #30000000;
			// key1_in = 1;
			// #30000000;
			// #400000;

			// key1_in = 0;
			// #30000000;
			// key1_in = 1;
			// #30000000;
			// #200000;

			// key1_in = 0;
			// #30000000;
			// key1_in = 1;
			// #30000000;
			// #40000;

			// key1_in = 0;
			// #30000000;
			// key1_in = 1;
			// #30000000;
			// #20000;

			// key1_in = 0;
			// #30000000;
			// key1_in = 1;
			// #30000000;
			// #10000;

			// key1_in = 0;
			// #30000000;
			// key1_in = 1;
			// #30000000;
			// #4000;

			
			#(clk_period*20);
			$stop;


		end




endmodule
