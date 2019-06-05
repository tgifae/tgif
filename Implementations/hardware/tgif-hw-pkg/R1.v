module R1 (/*AUTOARG*/
   // Outputs
   po,
   // Inputs
   pi
   ) ;
   output [15:0] po;
   input  [15:0] pi;

   assign po = {pi[3:0],pi[15:4]};
   
endmodule // R1
