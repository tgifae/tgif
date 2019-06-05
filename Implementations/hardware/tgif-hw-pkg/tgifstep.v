module tgifstep (/*AUTOARG*/
   // Outputs
   LL, RR, tkk0, tkk1, tkk2, tkk3, c3,
   // Inputs
   L, R, tk0, tk1, tk2, tk3, clk, init
   ) ;
   output [63:0] LL, RR;
   output [31:0]  tkk0, tkk1, tkk2, tkk3;
   output [6:0]   c3;   
   input  [63:0] L, R;
   input [31:0]  tk0, tk1, tk2, tk3;   
   input 	 clk, init;

   wire [63:0] 	go, ls;
   wire [6:0] 	c0, c1, c2;   

   giftb4 bb (.so(go),.si(R),.tk0(tk0),.tk1(tk1),.tk2(tk2),.tk3(tk3),.c0(c0),.c1(c1),.c2(c2),.c3(c3));
   constgen constant (.c0(c0),.c1(c1),.c2(c2),.c3(c3),.clk(clk),.init(init));
   keyexp keysch (.ko({tkk0,tkk1,tkk2,tkk3}),.ki({tk0,tk1,tk2,tk3}));   
   
   assign RR = L;
   assign ls = {L[8:0],L[63:9]};
   assign LL = go ^ ls;

   
endmodule // tgifstep
