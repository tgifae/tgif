module P3 (/*AUTOARG*/
   // Outputs
   po,
   // Inputs
   pi
   ) ;
   output [15:0] po;
   input  [15:0] pi;

   assign po[3:0] = {pi[2:0],pi[3]};
   assign po[7:4] = {pi[6:4],pi[7]};
   assign po[11:8] = {pi[10:8],pi[11]};
   assign po[15:12] = {pi[14:12],pi[15]};
   
endmodule // P3
