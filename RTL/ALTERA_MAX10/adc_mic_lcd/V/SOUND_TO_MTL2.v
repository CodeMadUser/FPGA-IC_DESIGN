
module SOUND_TO_MTL2 
(
input [15:0] WAVE,
input        AUDIO_MCLK,
input        SAMPLE_TR ,

input        RESET_n , 
input        DRAW_DOT,


input        MTL_CLK , 
output [7:0] MTL2_R, 
output [7:0] MTL2_G,
output [7:0] MTL2_B,
output       MTL2_HSD,
output       MTL2_VSD,
output       MTL2_DCLK,
input  [2:0] SCAL,
input        START_STOP    
   
);

//---VGA CONTROLLER --- 
VGA_Controller vc(	//	Host Side
	.iRed  (MTL_D_R),
	.iGreen(MTL_D_G),
	.iBlue (MTL_D_B),
	.oRequest(),
	//	VGA Side
	.oVGA_R(MTL2_R),
	.oVGA_G(MTL2_G),
	.oVGA_B(MTL2_B),
	.oVGA_H_SYNC(MTL2_HSD),
	.oVGA_V_SYNC(MTL2_VSD),
	.oVGA_CLOCK( MTL2_DCLK ),
	//	Control Signal
	.iCLK      (MTL_CLK ),
	.iRST_N    (RESET_n ) ,
	.H_Cont    (H_CNT),
   .V_Cont    (V_CNT)						
);

wire [11:0 ]H_CNT  ,V_CNT ; 
//--WAVE BUFFFER --- 
reg  [11:0] SW_ADDR ;    
wire [11:0] VR_ADDR ; 
reg  PW_CH;   
wire [15:0] VRDAT_1 ; 
wire [15:0] VRDAT_2 ; 




//----PIXEL TRIGGER  DRAWN LINE PROCESS ----
wire  [7:0] MTL_D_R,MTL_D_G ,MTL_D_B ;

assign { MTL_D_R , MTL_D_G , MTL_D_B }  =  (
   (
	( ( DRAW_DOT==0 ) &&  
	(  ( X1 > X2) && ( V_CNT[8:0] < X1   ) && ( V_CNT[8:0] >= X2  ) ) ||  
	(  ( X1 < X2) && ( V_CNT[8:0] >= X1  ) && ( V_CNT[8:0] < X2  ) )||
	(  ( X1 == X2) &&( V_CNT[8:0] == X2  )  ) 
	) ||
   ( ( DRAW_DOT==1 ) &&  ( V_CNT[8:0] == X1 )  ) 
	) 	? 24'hFFFF00  : 

	
	
	
   ( 255 == V_CNT[8:0]  ) ? ( (START_STOP)?  24'h6F6F6F  :  24'hFF0000)  :  0 
	); 

//----POLIAR TRANSFORM  ----
wire [8:0] X1;//currentPIXEL 
wire [8:0] X2;//nextPIXEL 

assign X1    = PW_CH?  { ~ VDT2_1[15] , VDT2_1[14:7]  } :{ ~VDT1_1[15] , VDT1_1[14:7]  } ; 
assign X2    = PW_CH?  { ~ VDT2_2[15] , VDT2_2[14:7]  } :{ ~VDT1_2[15] , VDT1_2[14:7]  } ; 

 
//-- BUFFER CONTROLLER ----- 
//re
reg [15:0] VDT1_1,VDT1_2 ; 
reg [15:0] VDT2_1,VDT2_2 ; 

reg rMTL2_VSD ; 
reg [7:0]CNT ; 

always @(posedge SAMPLE_TR )  begin 
rMTL2_VSD <= MTL2_VSD ; 
if (CNT >= SCAL) CNT<=0 ; else CNT<= CNT+1 ; 
if  ( ( !rMTL2_VSD &&  MTL2_VSD   ) && ( SW_ADDR > 1000))  begin 
     SW_ADDR <= (START_STOP)? 0     : SW_ADDR;
	  PW_CH   <= (START_STOP)? ~PW_CH: PW_CH ; 
end   
else  
 begin 
   if (  MTL2_VSD )  begin 
	if ( SW_ADDR > 1000 )  begin 
	   SW_ADDR <= SW_ADDR  ; 
	end
	else  if (CNT==0)   begin 
	      SW_ADDR   <=    SW_ADDR+1; 
		
		 end
	end 
  end
end

always @( posedge MTL2_DCLK ) begin 
	     { VDT1_1,VDT1_2	} <= {VDT1_2 ,VRDAT_1 };
		  { VDT2_1,VDT2_2 } <= {VDT2_2 ,VRDAT_2 };
end		  

//--3200word 16bit DPORT-RAM1--// 
PIPO P1(
	.rdaddress (H_CNT),
	.rdclock   (MTL_CLK),
	.q         (VRDAT_1),
	.data      (WAVE     ) ,	
	.wraddress (SW_ADDR  ),
	.wrclock   (SAMPLE_TR),
	.wren      (PW_CH)
	);
//--3200word 16bit DPORT-RAM2--// 	
PIPO P2(
	.rdaddress (H_CNT),
	.rdclock   (MTL_CLK),
	.q         (VRDAT_2),
	.data      (WAVE     ) ,	
	.wraddress (SW_ADDR  ),
	.wrclock   (SAMPLE_TR),
	.wren      (~PW_CH)
	);
	

endmodule 
