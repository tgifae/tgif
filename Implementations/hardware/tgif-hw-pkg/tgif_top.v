`include "params.vh"
module tgif_top (output [BUSWIDTH-1:0] pdo_data,
		  output 	       pdi_ready, sdi_ready, pdo_valid,
		  
`ifdef CLW32
		  output 	       fail,
`endif
		  
		  input [BUSWIDTH-1:0] pdi_data, sdi_data,
		  input 	       pdi_valid, sdi_valid, pdo_ready, ad_valid,
		  
		  input 	       clk, rst
) ;
   parameter CUSTOMLW32 = 1;
   parameter APILW32 = 2;
   parameter APINODECLW32 = 3;   
   parameter BUSWIDTH = 32;   
   parameter BUSWIDTHBYTE = 4;   
   parameter FFTYPE = 1;   

`ifdef CLW32
   parameter ARCH = CUSTOMLW32;
`else
   parameter ARCH = APILW32;
`endif
   
   wire [BUSWIDTH-1:0] 	 pdo, pdi;

   wire [7:0] 		 dold, dnew;
   wire [BUSWIDTHBYTE-1:0] decrypt;
   
   wire 		   srst, senc, sse;
   wire 		   xrst, xenc, xse;
   wire 		   erst;
   wire 		   tk1s;
   wire 		   sl;
`ifdef TWO
   wire 		   vse, venc, vf, vl, ll, kdf, fv;
 `ifdef MR
   wire 		   vs2;
 `endif
`endif
   
   wire [5:0] 		   constant;
   wire 		   correct_cnt;   
   
   mode_top #(.BUSWIDTH(BUSWIDTH), .BUSWIDTHBYTE(BUSWIDTHBYTE), .FFTYPE(FFTYPE)) 
   datapath (
	     // Outputs
	     pdo, constant,
	     // Inputs
	     pdi, sdi_data, dold, dnew, decrypt, clk, srst, senc, sse, xrst, xenc, xse,
	     erst, sl, 
`ifdef TWO
	     vse, venc, vf, vl, ll, kdf, fv,
 `ifdef MR
	     vs2,
 `endif
`endif
	     correct_cnt
	     ) ;
   generate if (ARCH == APILW32) begin      
      api control (
		   // Outputs
		   pdo_data, pdi, pdi_ready, sdi_ready, pdo_valid, dold, dnew,
		   srst, senc, sse, xrst, xenc, xse,
		   erst, decrypt, correct_cnt, sl,
		   // Inputs
		   counter, pdi_data, pdo, pdi_valid, sdi_valid, pdo_ready,
		   clk, rst, constant
		   ) ;
   end // if (ARCH == APILW32)
   else if (ARCH == CUSTOMLW32) begin
      cu32 control (
		    // Outputs
		    pdo_data, pdi, pdo_valid, sdi_ready, pdi_ready, dold, dnew, srst,
		    senc, sse, xrst, xenc, xse, erst, decrypt, correct_cnt, sl, fail,
`ifdef TWO
		    vse, venc, vl, vf, kdf, ll, fv,
 `ifdef MR
		    vs2,
 `endif
`endif
		     // Inputs
		     pdi_data, pdo, pdi_valid, ad_valid, clk, rst, constant
		     );      
   end
   else if (ARCH == APINODECLW32) begin      
      assign decrypt = 4'h0;      
      apinodec control (
			// Outputs
			pdo_data, pdi, pdi_ready, sdi_ready, pdo_valid, dold, dnew, srst,
			senc, sse, xrst, xenc, xse, erst, correct_cnt, sl,
			// Inputs
			counter, pdi_data, pdo, pdi_valid, sdi_valid, pdo_ready, clk, rst,
			constant
			) ;
   end
   endgenerate
   

endmodule // tgif_top

