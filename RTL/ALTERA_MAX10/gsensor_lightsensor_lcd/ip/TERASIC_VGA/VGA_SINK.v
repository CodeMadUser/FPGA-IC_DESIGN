
`include ".\vga_time_generator.v"

module VGA_SINK(
        // global Signals
        clk,
        reset_n,
   
		
		// avalong s1 ST-SINK(streaming) interface
		ready_out,
		valid_in,
		data_in,  // pass RGB data
		sop_in,  // start of papacket
		eop_in,  // end of packet // Required by Avaon-ST spec.  Unused in this core.
		empty_in,  // Required by Avaon-ST spec.  Unused in this core.
		
		// VGA export interface
		vga_clk,
		vga_hs,
		vga_vs,
		vga_de,
		vga_r,
		vga_g,
		vga_b
);


/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
parameter SYMBOLS_PER_BEAT   = 1; 
parameter BITS_PER_SYMBOL    = 24;
parameter READY_LATENCY      = 0; 
parameter MAX_CHANNEL        = 0;

parameter H_DISP	         = 640;
parameter H_FPORCH	         = 16;
parameter H_SYNC	         = 96;
parameter H_BPORCH	         = 48;
parameter V_DISP	         = 480;
parameter V_FPORCH	         = 10;
parameter V_SYNC	         = 2;
parameter V_BPORCH	         = 33;



/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/


`define STATE_IDLE    		0
`define STATE_WAIT_SOP		1   // start of packet
`define STATE_WAIT_EOF		2   // end of frame
`define STATE_STREAMING 	3

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
        // global signal
input							clk;
input							reset_n;
	
		
		// avalong s1 ST-SINK(streaming) interface
output	reg						ready_out;
input							valid_in;
input	[23:0]					data_in;
input							sop_in;
input							eop_in;
input							empty_in;
//input	 [1:0]					empty_in;

		
		// VGA export interface
output				vga_clk;
output	reg			vga_hs;
output	reg			vga_vs;
output	reg			vga_de;
output	reg	[7:0]	vga_r;
output	reg	[7:0]	vga_g;
output	reg	[7:0]	vga_b;


/*****************************************************************************
 *                 Internal wires and registers Declarations                 *
 *****************************************************************************/
reg		[1:0]                   streaming_state;



/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential logic                              *
 *****************************************************************************/
 



/*****************************************************************************
 *                            Combinational logic                            *
 *****************************************************************************/


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
wire			pix_hs;
wire			pix_vs;
wire			pix_de;
wire	[11:0]	pix_x;
wire	[11:0]	pix_y;



vga_time_generator vga_time_generator_instance(
		.clk      (vga_clk),
		.reset_n  (reset_n),
	//	.timing_change(timing_chang),
		.h_disp   (H_DISP),
		.h_fporch (H_FPORCH),
		.h_sync   (H_SYNC), 
		.h_bporch (H_BPORCH),
		
		.v_disp   (V_DISP),
		.v_fporch (V_FPORCH),
		.v_sync   (V_SYNC),
		.v_bporch (V_BPORCH),
		.hs_polarity(1'b0),
		.vs_polarity(1'b0),
		.frame_interlaced(1'b0),
		
		.vga_hs   (pix_hs),
		.vga_vs   (pix_vs),
		.vga_de   (pix_de),
		.pixel_x  (pix_x),
		.pixel_y ( pix_y),
		.pixel_i_odd_frame() 
);


// state mechine
always @ (posedge clk or negedge reset_n)
begin
	if (!reset_n)
	begin
		streaming_state <= `STATE_IDLE;
	end
	else if (streaming_state == `STATE_IDLE)
	begin
		streaming_state <= `STATE_WAIT_SOP;
		// reset
	end
	else if (streaming_state == `STATE_WAIT_SOP)
	begin
		if (valid_in && sop_in)
			streaming_state <= `STATE_WAIT_EOF;
	end
	else if (streaming_state == `STATE_WAIT_EOF)
	begin
		if (pix_y >= V_DISP)
		begin
			streaming_state <= `STATE_STREAMING;
		end
	end
	else if (streaming_state == `STATE_STREAMING)
	begin
		if (valid_in && eop_in)
			streaming_state <= `STATE_WAIT_SOP;
	end
end


//============ stage 1 =======
assign vga_clk = clk;


reg 		vga_hs_1;
reg 		vga_vs_1;
reg 		vga_de_1;
reg [23:0]	vga_data_1;

wire		query_pixel;
assign query_pixel = pix_de & valid_in;

always @ (posedge clk)
begin
	if (streaming_state != `STATE_STREAMING)
	begin
		ready_out <= 1'b0;
		vga_data_1 <= (pix_de)?24'hFFFFFF: 24'h000000;
	end	
	else
	begin
		ready_out <= query_pixel;
		vga_data_1 <= (query_pixel)?data_in:24'h000000;
	end

	vga_hs_1 <= pix_hs;
	vga_vs_1 <= pix_vs;
	vga_de_1 <= pix_de;
end


//============ stage 2 =======
always @ (posedge clk)
begin
	{vga_b,vga_g,vga_r} <= vga_data_1;
	vga_hs <= vga_hs_1;
	vga_vs <= vga_vs_1;
	vga_de <= vga_de_1;
end



endmodule





