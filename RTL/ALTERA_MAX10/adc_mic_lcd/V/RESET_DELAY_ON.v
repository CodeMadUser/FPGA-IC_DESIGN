module RESET_DELAY_ON (
input   CLK ,
input   START_TR , 
output  reg	RESET_ON ,
output  reg	START_ON 

) ; 
reg   [31:0] RESET_CNT   ; 
//--delay cnt 
always @( posedge  	CLK   ) if ( RESET_CNT  > 400000 )  begin  RESET_ON <= 1;  end 
else begin RESET_ON <= 0; RESET_CNT <=RESET_CNT+1 ;   end

// MTL2 _BUFFER WRITE ON -OFF 
always @( negedge RESET_ON or  posedge START_TR )  
if ( !RESET_ON )  START_ON <=1 ; 
else 
        START_ON <=~ START_ON; 
		  
endmodule
		  