////////////////////////////////////////////////////////////////////////////////
// Company  : 
// Engineer : 
// -----------------------------------------------------------------------------
// https://blog.csdn.net/qq_33231534    PHF's CSDN blog
// -----------------------------------------------------------------------------
// Create Date    : 2020-09-04 18:32:24
// Revise Data    : 2020-09-04 19:03:10
// File Name      : DDS_top.v
// Target Devices : XC7Z015-CLG485-2
// Tool Versions  : Vivado 2019.2
// Revision       : V1.1
// Editor         : sublime text3, tab size (4)
// Description    : 
//////////////////////////////////////////////////////////////////////////////// 
module DDS_top(
	input					clk			,
	input					rst_n		,
	input					key0_in		,
	input					key1_in		,
	input					key2_in		,

	output	wire	[11:0]	dac_data	
	);

	wire	[1:0]	wave_c		;
	wire	[25:0]	f_word		;
	wire	[4:0]	amplitude	;

	DDS inst_DDS
	(
		.clk      (clk),
		.rst_n    (rst_n),
		.f_word   (f_word),
		.wave_c   (wave_c),
		.p_word   (12'd0),
		.amplitude(amplitude),
		.dac_data (dac_data)
	);

	F_word_set inst_F_word_set 
	(
		.clk(clk), 
		.rst_n(rst_n), 
		.key1_in(key1_in), 
		.f_word(f_word)
	);

	wave_set inst_wave_set 
	(
		.clk(clk), 
		.rst_n(rst_n), 
		.key0_in(key0_in), 
		.wave_c(wave_c)
	);

	amplitude_set inst_amplitude_set(
		.clk	(clk)		,
		.rst_n	(rst_n)		,
		.key2_in(key2_in)	,

		.amplitude(amplitude)	
	);

endmodule
