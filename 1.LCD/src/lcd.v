module lcd
  (
   input wire 	     XTAL_IN,
   input wire 	     nRST,
   output wire [4:0] LCD_R,
   output wire [5:0] LCD_G,
   output wire [4:0] LCD_B,
   output wire 	     LCD_CLK,
   output wire 	     LCD_HSYNC,
   output wire 	     LCD_VSYNC,
   output wire 	     LCD_DEN,

   output 	     LED_R,
   output 	     LED_G,
   output 	     LED_B,
   input 	     KEY
   );

  parameter LCD_HEIGHT = 272;
  parameter LCD_WIDTH = 479;

  wire clk192M;

  Gowin_PLL chip_pll(
                     .clkout(clk192M), //output clkout      //192M
                     .clkoutd(LCD_CLK), //output clkoutd   //12M
                     .clkin(XTAL_IN) //input clkin
                     ); 

  wire [10:0]        x;
  wire [10:0]        y;

  lcd_sync
    #(
      .LCD_HEIGHT(LCD_HEIGHT),
      .LCD_WIDTH(LCD_WIDTH)
      )
  u_lcd_sync
    (
     .CLK (LCD_CLK),
     .RST_IN (nRST),
     .LCD_PWM (), /// LCD_PWM),
     .LCD_HSYNC (LCD_HSYNC),
     .LCD_VSYNC (LCD_VSYNC),
     .LCD_DEN (LCD_DEN),
     .X (x),
     .Y (y)
     );

  data_out
    #(
      .LCD_HEIGHT(LCD_HEIGHT),
      .LCD_WIDTH(LCD_WIDTH)
      )
  datout
    (
     .CLK (LCD_CLK),
     .R (LCD_R),
     .G (LCD_G),
     .B (LCD_B),
     .DEN (LCD_DEN),
     .X (x),
     .Y (y)
     );

  //RGB LED TEST
  reg [31:0]    Count;
  reg [1:0]     rgb_data;
  always @(  posedge clk192M or negedge nRST  )
    begin
      if(  !nRST  )
        begin
          Count         <= 32'd0;
          rgb_data    <= 2'b00;
        end
      else if ( Count == 100000000 )
        begin
          Count <= 4'b0;
          rgb_data <= rgb_data + 1'b1;
        end
      else
        Count <= Count + 1'b1;
    end
  assign  LED_R = ~(rgb_data == 2'b01);
  assign  LED_G = ~(rgb_data == 2'b10);
  assign  LED_B = ~(rgb_data == 2'b11);

endmodule
