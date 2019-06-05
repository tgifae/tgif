module P1 (/*AUTOARG*/
   // Outputs
   po,
   // Inputs
   pi
   ) ;
   output [15:0] po;
   input  [15:0] pi;

   assign po[3:0] = {pi[0],pi[3:1]};
   assign po[7:4] = {pi[4],pi[7:5]};
   assign po[11:8] = {pi[8],pi[11:9]};
   assign po[15:12] = {pi[12],pi[15:13]};
   
endmodule // P1
