
module  TP ( 
input MCLKx2 , 
input [7:0]   ST,
input [7:0]   COUNTER ,
input [15:0]  W_REG_DATA,
input [7:0]   WORD_CNT,
input [15:0]  READ_DATA, 

input  [32:0]RDATA ,  
input [32:0]RDATA1 ,  
input  [32:0]LDATA , 
input  [32:0]LDATA1 ,


input iRESET_n,
input  oCS_n   ,
input  oSCLK  ,
input  oDIN  , 
input  iDOUT, 
input  CLK_1M, 
input  [7:0] oDATA8 , 

input MCLK_24567, 
input AUDIO_MCLK,  	            
input AUDIO_BCLK,
input AUDIO_WCLK,

input AUDIO_DIN_MFP1 ,
input AUDIO_DOUT_MFP2,
input  [15:0]WCLK_CNT,
input RSD  , 
input LSD ,
input command_valid,
input response_valid ,
input [7:0 ] CNT_SREC ,
input [15:0 ] DATA16 ,
input [10:0 ] ROM_ADDR ,
input ROM_CK,

input DIN ,
input SCLK 

);
endmodule
