module constgen (/*AUTOARG*/
   // Outputs
   c0, c1, c2, c3,
   // Inputs
   clk, init
   ) ;
   output [6:0] c0, c1, c2, c3;
   input 	clk, init;

   reg   [6:0] constant;
   wire [6:0]  c4;   

   always @ (posedge clk) begin
      if (init) constant <= 7'b0000001;
      else constant <= c4;      
   end

   assign c0 = constant;
   assign c1 = {c0[5:0], c0[6]} ^ {5'b0, c0[6], 1'b0};
   assign c2 = {c1[5:0], c1[6]} ^ {5'b0, c1[6], 1'b0};
   assign c3 = {c2[5:0], c2[6]} ^ {5'b0, c2[6], 1'b0};
   assign c4 = {c3[5:0], c3[6]} ^ {5'b0, c3[6], 1'b0};
   
endmodule // constgen
