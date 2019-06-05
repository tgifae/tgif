module R2 (/*AUTOARG*/
   // Outputs
   po,
   // Inputs
   pi
   ) ;
   output [15:0] po;
   input  [15:0] pi;

   assign po = {pi[7:0],pi[15:8]};
   
endmodule // R2
