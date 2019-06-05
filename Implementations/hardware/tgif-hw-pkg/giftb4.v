module giftb4 (/*AUTOARG*/
   // Outputs
   so,
   // Inputs
   si, tk0, tk1, tk2, tk3, c0, c1, c2, c3
   ) ;
   output [63:0] so;
   input  [63:0] si;
   input  [31:0] tk0, tk1, tk2, tk3;
   input  [6:0] c0, c1, c2, c3;

   wire [63:0] 	 atk0, atk1, atk2, atk3;
   wire [63:0] 	 sb0, sb1, sb2, sb3;
   wire [63:0] 	 p0, p1, p2, p3;
   
   assign atk0 = si ^ {tk0, 16'b0, 8'h80, 1'b0, c0};
   sbox sbr0 (.so(sb0),.si(atk0));
   assign p0[63:48] = sb0[63:48];
   P1 perm01 (.po(p0[47:32]),.pi(sb0[47:32]));
   P2 perm02 (.po(p0[31:16]),.pi(sb0[31:16]));
   P3 perm03 (.po(p0[15:0]),.pi(sb0[15:0]));

   assign atk1 = p0 ^ {tk1, 16'b0, 8'h80, 1'b0, c1};
   sbox sbr1 (.so(sb1),.si(atk1));
   assign p1[63:48] = sb1[63:48];
   R1 perm11 (.po(p1[47:32]),.pi(sb1[47:32]));
   R2 perm12 (.po(p1[31:16]),.pi(sb1[31:16]));
   R3 perm13 (.po(p1[15:0]),.pi(sb1[15:0]));

   assign atk2 = p1 ^ {tk2, 16'b0, 8'h80, 1'b0, c2};
   sbox sbr2 (.so(sb2),.si(atk2));
   assign p2[63:48] = sb2[63:48];
   P3 perm21 (.po(p2[47:32]),.pi(sb2[47:32]));
   P2 perm22 (.po(p2[31:16]),.pi(sb2[31:16]));
   P1 perm23 (.po(p2[15:0]),.pi(sb2[15:0]));

   assign atk3 = p2 ^ {tk3, 16'b0, 8'h80, 1'b0, c3};
   sbox sbr3 (.so(sb3),.si(atk3));
   assign p3[63:48] = sb3[63:48];
   R3 perm31 (.po(p3[47:32]),.pi(sb3[47:32]));
   R2 perm32 (.po(p3[31:16]),.pi(sb3[31:16]));
   R1 perm33 (.po(p3[15:0]),.pi(sb3[15:0]));

   assign so = p3;

   
		  
endmodule // giftb4
