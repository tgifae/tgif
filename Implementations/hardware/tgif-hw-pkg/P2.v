module P2 (/*AUTOARG*/
   // Outputs
   po,
   // Inputs
   pi
   ) ;
   output [15:0] po;
   input  [15:0] pi;

   assign po[3:0] = {pi[1:0],pi[3:2]};
   assign po[7:4] = {pi[5:4],pi[7:6]};
   assign po[11:8] = {pi[9:8],pi[11:10]};
   assign po[15:12] = {pi[13:12],pi[15:14]};
   
endmodule // P2
