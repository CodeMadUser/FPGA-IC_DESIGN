`timescale  1ns/1ns
///////////////////////////////////////////////////////////////////////////
// Author        : EmbedFire
// Create Date   : 2019/03/12
// Module Name   : tb_led
// Project Name  : led
// Target Devices: Altera EP4CE10F17C8N
// Tool Versions : Quartus 13.0
// Description   : 按键控制LED灯仿真文件
//
// Revision      : V1.0
// Additional Comments:
// 
// 实验平台: 野火_征途Pro_FPGA开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
//////////////////////////////////////////////////////////////////////////

module  tb_led();

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define
wire    led_out ;

//reg   define
reg     key_in  ;

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//
//初始化输入信号
initial key_in <= 1'b0;

//key_in:产生输入随机数，模拟按键的输入情况
always #10 key_in <= {$random} % 2; /*取模求余数，产生非负随机数0、1
                                      每隔10ns产生一次随机数*/

//********************************************************************//
//**************************** Instantiate ***************************//
//********************************************************************//
//------------- led_inst -------------
led led_inst
(
    .key_in (key_in ),  //input     key_in

    .led_out(led_out)   //output    led_out
);

endmodule
