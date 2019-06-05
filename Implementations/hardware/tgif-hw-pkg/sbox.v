module sbox (/*AUTOARG*/
   // Outputs
   so,
   // Inputs
   si
   ) ;
   output [63:0] so;
   input  [63:0] si;

   wire [15:0] 	 state [3:0];
   wire [15:0] 	 stage [6:0];   

   assign state[0] = si[63:48];
   assign state[1] = si[47:32];
   assign state[2] = si[31:16];
   assign state[3] = si[15:0];

   assign stage[0] = state[1] ^ (state[0] & state[2]);
   assign stage[1] = state[0] ^ (stage[0] & state[3]);
   assign stage[2] = state[2] ^ (stage[1] | stage[0]);
   assign stage[3] = state[3] ^ stage[2];
   assign stage[4] = stage[0] ^ stage[3];
   assign stage[5] = ~stage[3];
   assign stage[6] = stage[2] ^ (stage[1] & stage[4]);


   assign so = {stage[5],stage[4],stage[6],stage[1]};   
   
endmodule // sox
