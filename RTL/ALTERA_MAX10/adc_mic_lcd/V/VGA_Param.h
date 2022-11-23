//	Horizontal Parameter	( Pixel )
parameter	H_SYNC_CYC	=	1;//96;
parameter	H_SYNC_BACK	=	46;//48;
parameter	H_SYNC_ACT	=	800;//640;	
parameter	H_SYNC_FRONT=	210;//16;
parameter	H_SYNC_TOTAL=	1056;//800;

//	Virtical Parameter		( Line )
parameter	V_SYNC_CYC	=	1;
parameter	V_SYNC_BACK	=	23;//33;
parameter	V_SYNC_ACT	=	480;	
parameter	V_SYNC_FRONT=	22;// 10;
parameter	V_SYNC_TOTAL=	525;
//	Start Offset
parameter	X_START		=	H_SYNC_CYC+H_SYNC_BACK;
parameter	Y_START		=	V_SYNC_CYC+V_SYNC_BACK;
