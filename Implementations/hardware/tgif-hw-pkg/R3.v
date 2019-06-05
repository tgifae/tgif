module R3 (/*AUTOARG*/
   // Outputs
   po,
   // Inputs
   pi
   ) ;
   output [15:0] po;
   input  [15:0] pi;

   assign po = {pi[11:0],pi[15:12]};
   
endmodule // R3
