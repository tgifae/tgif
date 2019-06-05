module keyexp (/*AUTOARG*/
   // Outputs
   ko,
   // Inputs
   ki
   ) ;
   output [127:0] ko;
   input  [127:0] ki;

   wire [31:0] 	  tk0;
   wire [31:0] 	  tk1;
   wire [31:0] 	  tk2;
   wire [31:0] 	  tk3;
   wire [31:0] 	  tkk0;
   wire [31:0] 	  tkk1;
   wire [31:0] 	  tkk2;
   wire [31:0] 	  tkk3;

   assign tk0 = ki[127:96];
   assign tk1 = ki[95:64];
   assign tk2 = ki[63:32];
   assign tk3 = ki[31:0];

   assign tkk0 = tk0 ^ tk1  ^ (({tk3[23:0], tk3[31:24]}  ^ {32'h00010000})) ^ {32'h01000000};
   assign tkk1 = tk1 ^ tk2  ^ (({tkk0[23:0],tkk0[31:24]} ^ {32'h00010000})) ^ {32'h01000000};
   assign tkk2 = tk2 ^ tk3  ^ (({tkk1[23:0],tkk1[31:24]} ^ {32'h00010000})) ^ {32'h01000000};
   assign tkk3 = tk3 ^ tkk0 ^ (({tkk2[23:0],tkk2[31:24]} ^ {32'h00010000})) ^ {32'h01000000};

   assign ko[127:96] = tkk0;
   assign ko[95:64]  = tkk1;
   assign ko[63:32]  = tkk2;
   assign ko[31:0]   = tkk3;   
	
endmodule // keyexp
