
module pong
  (
   input wire 	     CLK_IN,
   input wire 	     nRST,
   output wire [4:0] LCD_R,
   output wire [5:0] LCD_G,
   output wire [4:0] LCD_B,

   output wire 	     LCD_CLK,
   output wire 	     LCD_HSYNC,
   output wire 	     LCD_VSYNC,
   output wire 	     LCD_DEN,

   output wire 	     TM1638_STB,
   output wire 	     TM1638_CLK,
   inout wire 	     TM1638_DIO,

   input KEY
   );

  parameter LCD_HEIGHT = 272;
  parameter LCD_WIDTH = 479;

  Gowin_PLL chip_pll(
                     .clkout(LCD_CLK), //output clkout      //12M
                     .clkin(CLK_IN) //input clkin
                     ); 

  
  wire [10:0] 	     x;
  wire [10:0] 	     y;
  wire 		     tm1638Ready;
  wire 		     tm1638ReadButton;
  wire 		     tm1638WriteSeg;
  wire [2:0] 	     tm1638SegIndex;
  wire [3:0] 	     tm1638SegDataHex;
  wire [7:0] 	     tm1638SegDataRaw;
  wire [7:0] 	     tm1638Buttons;
  wire [31:0] 	     tm1638SegHexAll;

  wire 		     tm1638ClkIn;
  parameter TM1638_CLK_SLOW = 6; // Work in reel: drive1=[2-15] openDrain=[6-15]
  reg [TM1638_CLK_SLOW:0] tm1638ClkSlowCpt;
  assign tm1638ClkIn = tm1638ClkSlowCpt[TM1638_CLK_SLOW];
  always @(posedge CLK_IN)
    begin
      tm1638ClkSlowCpt <= tm1638ClkSlowCpt + 1'b1;
    end

  lcdSync
    #(
      .LCD_HEIGHT(LCD_HEIGHT),
      .LCD_WIDTH(LCD_WIDTH)
      )
  myLcdSync
    (
     .CLK(LCD_CLK),
     .RST_IN(nRST),
     .LCD_PWM(LCD_PWM),
     .LCD_HSYNC(LCD_HSYNC),
     .LCD_VSYNC(LCD_VSYNC),
     .LCD_DEN(LCD_DEN),
     .X(x),
     .Y(y)
     );

  lcdPong
    #(
      .LCD_HEIGHT(LCD_HEIGHT),
      .LCD_WIDTH(LCD_WIDTH)
      )
  myLcdPong
    (
     .CLK(LCD_CLK),
     .RST_IN(nRST),
     .R(LCD_R),
     .G(LCD_G),
     .B(LCD_B),
     .DEN(LCD_DEN),
     .X(x),
     .Y(y),
     .SEG_HEX_ALL(tm1638SegHexAll),
     .BUTTONS(tm1638Buttons)
     );

  tm1638SegHex4 myTm1638SegHex4 (
				 .CLK_IN(CLK_IN),
				 .RST_IN(nRST),
				 .READY(tm1638Ready),
				 .READ_BUTTON(tm1638ReadButton),
				 .WRITE_SEG(tm1638WriteSeg),
				 .SEG_INDEX(tm1638SegIndex),
				 .SEG_DATA(tm1638SegDataHex),
				 .SEG_HEX_ALL(tm1638SegHexAll)
				 );

  hexTo7Seg myHexTo7Seg
    (
     .HEX(tm1638SegDataHex),
     .DOT(1'b0),
     .SEG(tm1638SegDataRaw)
     );

  tm1638 myTm1638
    (
     .RST_IN(nRST),
     .CLK_IN(tm1638ClkIn),
     .READY(tm1638Ready),
     .READ(tm1638ReadButton),
     .WRITE(tm1638WriteSeg),
     .ADDR_IN({tm1638SegIndex,1'b0}),
     .DATA_IN(tm1638SegDataRaw),
     .DATA_OUT(tm1638Buttons),
     .STB(TM1638_STB),
     .CLK_OUT(TM1638_CLK),
     .DIO(TM1638_DIO)
     );

endmodule
