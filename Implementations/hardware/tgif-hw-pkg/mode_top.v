`include "params.vh"
module mode_top (
		 output [BUSWIDTH-1:0] 	  pdo,
		 output [6:0] 		  constant,

		 input [BUSWIDTH-1:0] 	  pdi,
		 input [BUSWIDTH-1:0] 	  sdi,
		 input [7:0] 		  dold, dnew,
		 input [BUSWIDTHBYTE-1:0] decrypt,
		 input 			  clk,
		 input 			  srst, senc, sse,
		 input 			  xrst, xenc, xse,
		 input 			  erst,
		 input 			  sl,
`ifdef TWO
		 input 			  vse, venc, vf, vl, ll, kdf, fv,
 `ifdef MR
		 input vs2,
 `endif
`endif		 
		 input 			  correct_cnt
   ) ;
   parameter BUSWIDTH = 32;
   parameter BUSWIDTHBYTE = 4;
   parameter FFTYPE = 1;   
      
   wire [127:0]  tk1;
   wire [127:0]  tka;
   wire [127:0]  tkc;   
   wire [127:0]  skinnyS;
   wire [127:0]  skinnyX;
   wire [127:0]  S, TKX;
   wire [BUSWIDTH-1:0] li;
`ifdef TWO
   wire [BUSWIDTH-1:0] vo;
   wire [127:0]        K;  
`endif

   assign tkc = TKX;
`ifdef TWO
   assign li = ll ? vo : (sl ? pdo : sdi);   
`else
   assign li = sl ? pdo : sdi;   
`endif

`ifdef TWO
   assign K = tka ^ {128'h01};
`endif
   
   generate if (BUSWIDTH == 32) begin
      state_update_32b #(.FFTYPE(FFTYPE)) 
      STATE (.state(S), .pdo(pdo), .skinny_state(skinnyS), .pdi(pdi),
`ifdef TWO	     
	     .vl(vl), .vf(vf), .vse(vse), .venc(venc), .vo(vo), .kdf(kdf), .fv(fv),
 `ifdef MR
	     .vs2(vs2), .sdi(sdi),
 `endif
`endif	     
	     .clk(clk), .rst(srst), .enc(senc), .se(sse),
	     .decrypt(decrypt));
`ifdef TWO
      tkx_update_32b TKEYX (.tkx(TKX), .skinny_tkx(skinnyX), .skinny_tkx_revert(tk1), 
			    .sdi(li), .clk(clk), .rst(xrst), .enc(xenc), .se(xse), .L(K), .kdf(kdf));
`else
      tkx_update_32b TKEYX (.tkx(TKX), .skinny_tkx(skinnyX), .skinny_tkx_revert(tk1), 
			    .sdi(li), .clk(clk), .rst(xrst), .enc(xenc), .se(xse));
`endif
   end
   endgenerate

   doubling CNT (.so(tk1), .si(tkc), .dold(dold), .dnew(dnew));

   tgifstep (.LL({skinnyS[119:112],skinnyS[127:120],skinnyS[103:96],skinnyS[111:104],
		  skinnyS[87:80],  skinnyS[95:88],  skinnyS[71:64], skinnyS[79:72]}), 
	     .RR({skinnyS[55:48],  skinnyS[63:56],  skinnyS[39:32], skinnyS[47:40],
		  skinnyS[23:16],  skinnyS[31:24],  skinnyS[7:0],   skinnyS[15:8]}), 	     
	     .tkk0({skinnyX[119:112],skinnyX[127:120],skinnyX[103:96],skinnyX[111:104]}), 
	     .tkk1({skinnyX[87:80],  skinnyX[95:88],  skinnyX[71:64], skinnyX[79:72]}), 
	     .tkk2({skinnyX[55:48],  skinnyX[63:56],  skinnyX[39:32], skinnyX[47:40]}), 
	     .tkk3({skinnyX[23:16],  skinnyX[31:24],  skinnyX[7:0],   skinnyX[15:8]}), 
	     .c3(constant),
	     .L({S[119:112],S[127:120],S[103:96],S[111:104],
		 S[87:80],S[95:88],S[71:64],S[79:72]}), 
	     .R({S[55:48],S[63:56],S[39:32],S[47:40],
		 S[23:16],S[31:24],S[7:0],S[15:8]}), 
	     .tk0({TKX[119:112],TKX[127:120],TKX[103:96],TKX[111:104]}), 
	     .tk1({TKX[87:80],TKX[95:88],TKX[71:64],TKX[79:72]}), 
	     .tk2({TKX[55:48],TKX[63:56],TKX[39:32],TKX[47:40]}), 
	     .tk3({TKX[23:16],TKX[31:24],TKX[7:0],TKX[15:8]}), 
	     .clk(clk), .init(erst));
   
endmodule // mode_top
