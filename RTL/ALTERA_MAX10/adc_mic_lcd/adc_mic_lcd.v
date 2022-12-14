
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module adc_mic_lcd(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,
	input 		          		MAX10_CLK3_50,

	//////////// KEY //////////
	input 		          		FPGA_RESET_n,
	input 		     [4:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// LEDR //////////
	output		     [9:0]		LEDR,

	//////////// HEX //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,

	//////////// Audio //////////
	inout 		          		AUDIO_BCLK,
	output		          		AUDIO_DIN_MFP1,
	input 		          		AUDIO_DOUT_MFP2,
	inout 		          		AUDIO_GPIO_MFP5,
	output		          		AUDIO_MCLK,
	input 		          		AUDIO_MISO_MFP4,
	inout 		          		AUDIO_RESET_n,
	output		          		AUDIO_SCL_SS_n,
	output		          		AUDIO_SCLK_MFP3,
	inout 		          		AUDIO_SDA_MOSI,
	output		          		AUDIO_SPI_SELECT,
	inout 		          		AUDIO_WCLK,

	//////////// DAC //////////
	inout 		          		DAC_DATA,
	output		          		DAC_SCLK,
	output		          		DAC_SYNC_n,

	//////////// MTL2 //////////
	output		     [7:0]		MTL2_B,
	output		          		MTL2_BL_ON_n,
	output		          		MTL2_DCLK,
	output		     [7:0]		MTL2_G,
	output		          		MTL2_HSD,
	output		          		MTL2_I2C_SCL,
	inout 		          		MTL2_I2C_SDA,
	input 		          		MTL2_INT,
	output		     [7:0]		MTL2_R,
	output		          		MTL2_VSD,

	//////////// PS2 //////////
	inout 		          		PS2_CLK,
	inout 		          		PS2_CLK2,
	inout 		          		PS2_DAT,
	inout 		          		PS2_DAT2,

	//////////// TMD 2x6 GPIO Header, TMD connect to TMD Default //////////
	inout 		     [7:0]		GPIO	
	
);


//----ON-BOARD-MIC TO DAC&LINE out-----

//=======================================================
//  REG/WIRE declarations
//=======================================================
wire  [11:0]  ADC_RD ;
wire          SAMPLE_TR ;  
wire          ADC_RESPONSE ;
wire [15:0]   TODAC ; 
wire          ROM_CK ; 
wire          MCLK_48M ; // 48MHZ
wire  [15:0 ] SUM_AUDIO ; 
 wire [8:0]   LED ; 
wire          MTL_CLK ;  // 33MHZ
reg           RESET_DELAY_n ; 
reg   [31:0]  DELAY_CNT;        

//=======================================================
//  Structural coding
//=======================================================

//--RESET DELAY ---

always @(negedge FPGA_RESET_n or posedge MAX10_CLK2_50 ) begin 
if (!FPGA_RESET_n )  begin 
     RESET_DELAY_n<=0;
     DELAY_CNT   <=0;
end 
else  begin 
  if ( DELAY_CNT < 32'hfffff  )  DELAY_CNT<=DELAY_CNT+1; 
  else RESET_DELAY_n<=1;
 end
end


//--- MIC  TO  MAX10-ADC  ----

MAX10_ADC   madc(  
	.SYS_CLK ( AUDIO_MCLK   ),
	.SYNC_TR ( SAMPLE_TR    ),
	.RESET_n ( RESET_DELAY_n),
	.ADC_CH  ( 7),
	.DATA    (ADC_RD ) ,
	.DATA_VALID(ADC_RESPONSE),
	.FITER_EN (1) 
 );

//--------------DAC out --------------------
assign      TODAC = {~SUM_AUDIO[15] ,  SUM_AUDIO[14:0] }  ; 

DAC16 dac1 (
	.LOAD    ( ROM_CK   ) ,
	.RESET_N ( FPGA_RESET_n ) , 
	.CLK_50  ( AUDIO_MCLK ) , 
	.DATA16  ( TODAC  )  ,
	.DIN     ( DAC_DATA ),
	.SCLK    ( DAC_SCLK ),
	.SYNC    ( DAC_SYNC_n )
	
	);

//-----MCLK GENERATER ----------
assign AUDIO_MCLK  = MCLK_48M ; 

AUDIO_PLL pll (
	.inclk0 (MAX10_CLK1_50),
	.c0     (MCLK_48M) 
	);
	

//---AUDIO CODEC SPI CONFIG ------------------------------------	
//--I2S mode ,  48ksample rate  ,MCLK = 24.567MhZ x 2 
assign AUDIO_GPIO_MFP5  =  1;   //GPIO
assign AUDIO_SPI_SELECT =  1;   //SPI mode
assign AUDIO_RESET_n    =  RESET_DELAY_n ;

AUDIO_SPI_CTL_RD	u1(	
	.iRESET_n ( RESET_DELAY_n) , 
	.iCLK_50( MAX10_CLK1_50),   //50Mhz clock
	.oCS_n ( AUDIO_SCL_SS_n ),   //SPI interface mode chip-select signal
	.oSCLK ( AUDIO_SCLK_MFP3),  //SPI serial clock
	.oDIN  ( AUDIO_SDA_MOSI ),   //SPI Serial data output 
	.iDOUT ( AUDIO_MISO_MFP4)   //SPI serial data input
	
	);


//--I2S PROCESSS  CODEC LINE OUT --

I2S_ASSESS  i2s( 
	.SAMPLE_TR ( SAMPLE_TR),
	.AUDIO_MCLK( AUDIO_MCLK) ,  
	.AUDIO_BCLK( AUDIO_BCLK),
	.AUDIO_WCLK( AUDIO_WCLK),

	.SDATA_OUT ( AUDIO_DIN_MFP1),
	.SDATA_IN  ( AUDIO_DOUT_MFP2),
	.RESET_n   ( RESET_DELAY_n), 
	.ADC_MIC      ( ADC_RD), 
	.SW_BYPASS    ( 0),          // 0:on-board mic  , 1 :line-in
	.SW_OBMIC_SIN ( 0),          // 1:sin  , 0 : mic
	.ROM_ADDR     ( ROM_ADDR), 
	.ROM_CK       ( ROM_CK  )  ,
	.SUM_AUDIO    ( SUM_AUDIO ) 
	
	) ; 

//-- SOUND-LEVEL Dispaly to LED

LED_METER   led(
   .RESET_n   ( RESET_DELAY_n), 
	.CLK   ( AUDIO_MCLK )  , 
	.SAMPLE_TR ( SAMPLE_TR) , 
	.VALUE ( { ~SUM_AUDIO[15], SUM_AUDIO[14:4]  }  ) ,
	.LED   (  LED ) 	
) ; 
 

//--METER TO LED --  
assign LEDR =  LED ; 

//---MTL2 --- 
PLL_VGA PP(
	.areset ( 0),
	.inclk0 ( MAX10_CLK3_50) ,
	.c0     ( MTL_CLK),
	.locked () 
);	

//--SOUND-WAVE display to MTL2 ----
assign  MTL2_BL_ON_n = ~RESET_DELAY_n  ; 

SOUND_TO_MTL2  sm(
	.WAVE      ( SUM_AUDIO[15:0]),
	.AUDIO_MCLK( AUDIO_MCLK),
	.SAMPLE_TR ( SAMPLE_TR),
	.RESET_n   ( RESET_DELAY_n), 
	
	.MTL_CLK  ( MTL_CLK  ), 
	.MTL2_R   ( MTL2_R   ), 
	.MTL2_G   ( MTL2_G   ),
	.MTL2_B   ( MTL2_B   ),
   .MTL2_HSD ( MTL2_HSD ),
   .MTL2_VSD ( MTL2_VSD ),
   .MTL2_DCLK( MTL2_DCLK) , 
   .SCAL      ( 7), //0:NONE SCA  1: SCALE+1  ... 
	.DRAW_DOT  ( 0),
	.START_STOP( 1) 
);	


endmodule




