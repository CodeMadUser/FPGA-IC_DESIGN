module par_to_ser
(
	input	wire					clk_125M		,
	input	wire		[9:0]		data_in		,

	output	wire					ser_p				,
	output	wire					ser_n			
);
wire			data;
wire	[4:0]	data_rise		;
wire	[4:0]	data_fall		;
reg		[4:0]	data_rise_s	= 0	;
reg		[4:0]	data_fall_s	= 0	;
reg		[2:0]	cnt		= 0		;

assign data_rise = {data_in[8],data_in[6],data_in[4],data_in[2],data_in[0]},
	   data_fall = {data_in[9],data_in[7],data_in[5],data_in[3],data_in[1]};

always@(posedge clk_125M)
	begin
		cnt <= (cnt[2]==1'b1)?3'd0:cnt + 1'b1;
		data_rise_s <= (cnt[2]==1'b1)?data_rise:data_rise_s[4:1];
		data_fall_s <= (cnt[2]==1'b1)?data_fall:data_fall_s[4:1];
		//data_fall_s[4:0] <= data_fall_s[4:1] 此代码含义是将高4位赋给低4位，
		//因为在赋值时是从最低位开始赋值
	end

//下面调用两次IP核实现差分信号输出
/*
ddio_out	ddio_out_inst 
(
	.datain_h (data_rise_s[0]),
	.datain_l (data_fall_s[0]),
	.outclock (~clk_125M		 ),
	.dataout  (ser_p)
);

ddio_out	ddio_out_inst2 
(
	.datain_h (~data_rise_s[0]),
	.datain_l (~data_fall_s[0]),
	.outclock (~clk_125M		 ),
	.dataout  (ser_n)
);
*/
ODDR2 #(
      .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1" 
      .INIT(1'b0),    // Sets initial state of the Q output to 1'b0 or 1'b1
      .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
   ) ODDR2_inst (
      .Q(data),   // 1-bit DDR output data
      .C0(~clk_125M),   // 1-bit clock input
      .C1(clk_125M),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D0(data_rise_s[0]), // 1-bit data input (associated with C0)
      .D1(data_fall_s[0]), // 1-bit data input (associated with C1)
      .R(1'b0),   // 1-bit reset input
      .S(1'b0)    // 1-bit set input
   );

OBUFDS #(
      .IOSTANDARD("TMDS_33") // Specify the output I/O standard
   ) OBUFDS_inst (
      .O(ser_p),     // Diff_p output (connect directly to top-level port)
      .OB(ser_n),   // Diff_n output (connect directly to top-level port)
      .I(data)      // Buffer input 
   );






endmodule