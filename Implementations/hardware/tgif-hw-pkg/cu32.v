`include "params.vh"
module cu32 (
	     output reg [31:0] pdo_data, pdi,
	     output reg        pdo_valid, sdi_ready, pdi_ready,
	     output reg [7:0]  dold, dnew,
	     output reg        srst, senc, sse,
	     output reg        xrst, xenc, xse,
	     output reg        erst,
	     output reg [3:0]  decrypt,
	     output reg        correct_cnt,
	     output reg        sl, 
	     output reg        fail, 
`ifdef TWO
	     output reg        vse, venc, vl, vf, kdf, ll, fv,
 `ifdef MR
	     output reg        vs2,
 `endif
`endif
   
	     input [31:0]      pdi_data, pdo,
	     input 	       pdi_valid, last,

	     input 	       clk, rst,
   
	     input [6:0]       constant
   ) ;
   // SKINNY FINAL CONSTANT
   parameter FINCONST = 7'b0110110;

   // INSTRUCTIONS
   parameter LDKEY = 4;
   parameter ACTKEY = 7;
   parameter ENC = 2;
   parameter DEC = 3;
   parameter SUCCESS = 14;
   parameter FAILURE = 15;

   // DOMAINS
`ifdef MR
 `ifdef TWO
   parameter adnormal = 100;
   parameter adfinal = 108;
   parameter adpadded = 109;
   parameter msgnormal = 102;
   parameter msgfinal = 110;
   parameter msgpadded = 111;
   parameter msgenc = 98;
`else
   parameter adnormal = 36;
   parameter adfinal = 44;
   parameter adpadded = 45;
   parameter msgnormal = 38;
   parameter msgfinal = 46;
   parameter msgpadded = 47;
   parameter msgenc = 34;         
`endif // !`ifdef TWO   
`else
`ifdef TWO
   parameter adnormal = 68;
   parameter adfinal = 76;
   parameter adpadded = 77;
   parameter msgnormal = 66;
   parameter msgfinal = 74;
   parameter msgpadded = 75;   
`else
   parameter adnormal = 4;
   parameter adfinal = 12;
   parameter adpadded = 13;
   parameter msgnormal = 2;
   parameter msgfinal = 10;
   parameter msgpadded = 11;
`endif // !`ifdef TWO
`endif // !`ifdef MR        

   //STATES
   parameter idle         = 0;
   parameter storekey0    = 1;
   parameter storekey1    = 2;   
   parameter storekey2    = 3;   
   parameter storekey3    = 4;      
   parameter storenonce0  = 5;
   parameter storenonce1  = 6;
   parameter storenonce2  = 7;
   parameter storenonce3  = 8;
   parameter encryptnonce = 9;
   parameter storeL0      = 10;
   parameter storeL1      = 11;
   parameter storeL2      = 12;
   parameter storeL3      = 13;
`ifdef TWO   
   parameter encryptnonc2 = 14;
   parameter storeV0      = 15;
   parameter storeV1      = 16;
   parameter storeV2      = 17;
   parameter storeV3      = 18;
`endif
   parameter storead0     = 19;
   parameter storead1     = 20;
   parameter storead2     = 21;
   parameter storead3	  = 22;
   parameter encryptad	  = 23;
   parameter storem0	  = 24;
   parameter storem1	  = 25;
   parameter storem2	  = 26;
   parameter storem3	  = 27;	 
   parameter encryptm	  = 28;
   parameter outputtag0	  = 29;
   parameter outputtag1	  = 30;
   parameter outputtag2	  = 31;
   parameter outputtag3	  = 32;
   parameter verifytag0	  = 33;
   parameter verifytag1	  = 34;
   parameter verifytag2	  = 35;
   parameter verifytag3	  = 36;
`ifdef MR
   parameter storeT0      = 37;
   parameter storeT1      = 38;
   parameter storeT2      = 39;
   parameter storeT3      = 40;
   parameter storeLT0	  = 41;
   parameter storeLT1	  = 42;
   parameter storeLT2	  = 43;
   parameter storeLT3	  = 44;
   parameter encryptm2    = 45;
`ifdef TWO   
   parameter storeVT0	  = 46;
   parameter storeVT1	  = 47;
   parameter storeVT2	  = 48;
   parameter storeVT3	  = 49;
`endif
   parameter storem20     = 50;
   parameter storem21     = 51;
   parameter storem22     = 52;
   parameter storem23     = 53;
`endif

   reg [5:0] 	      fsm, fsmn;
   reg 		      dec, decn;
   reg [3:0] 	      mlen, adlen, mlenn, adlenn;   
   
   reg [7:0] 	      nonce_domain, nonce_domainn;
   reg 		      correct_cntn;
   reg 		      fvn;   

   always @ (posedge clk) begin
      if (rst) begin
	 fsm <= idle;
	 dec <= 0;
	 correct_cnt <= 1;
	 dold <= 0;
	 mlen <= 0;
	 adlen <= 0;
`ifdef TWO
	 fv <= 1;
`endif
      end
      else begin
	 fsm <= fsmn;
	 dec <= decn;
	 correct_cnt <= correct_cntn;
	 dold <= dnew;
	 mlen <= mlenn;
	 adlen <= adlenn;
`ifdef TWO
	 fv <= fvn;
`endif
      end
   end // always @ (posedge clk)

   always @ (adlen or constant or correct_cnt or dec
	     or dold or fsm 
`ifdef TWO
		  or fv 
`endif
		  or last or mlen or pdi_data
	     or pdi_valid or pdo) begin     
      pdo_data <= pdo;      
      pdi <= pdi_data;      
      srst   <= 0;
      senc   <= 0;
      sse    <= 0;
      xrst   <= 0;
      xenc   <= 0;
      xse    <= 0;
      erst   <= 0;
`ifdef TWO
      fvn <= fv;      
      kdf <= 0;	   
      ll <= 0;     
`endif 
      decrypt <= 0;
      sl <= 0;      
      sdi_ready <= 0;
      pdi_ready <= 0;
      pdo_valid <= 0;
      dnew <= dold;      
      fsmn <= fsm;
      decn <= dec;
      correct_cntn <= correct_cnt;
      fail <= 0;
      mlenn <= mlen;
      adlenn <= adlen;
`ifdef TWO     
      vse <= 0;
      venc <= 0; 
      vl <= 0;
      vf <= 0;
 `ifdef MR
      vs2 <= 0;      
 `endif
`endif
      case (fsm) 
	idle: begin
	   dnew <= 0;
	   correct_cntn <= 1;
	   pdi_ready <= 1;
	   senc <= 1;
	   sse <= 1;
	   srst <= 1;
	   fvn <= 1;	   
	   if (pdi_valid) begin
	      if (pdi_data[31:28] == LDKEY) begin
		 fsmn <= storekey0;		 
	      end
	      else if (pdi_data[31:28] == ENC) begin
		 mlenn <= pdi_data[3:0];
		 adlenn <= pdi_data[7:4];
		 fsmn <= storenonce0;		 
		 decn <= 0;		 
	      end
	      else if (pdi_data[31:28] == DEC) begin
		 mlenn <= pdi_data[3:0];
		 adlenn <= pdi_data[7:4];		 
		 fsmn <= storenonce0;		 
		 decn <= 1;		 
	      end
	   end
	end // case: idle
	storekey0: begin
	   xrst <= 1;
	   xenc <= 1;
	   xse <= 1;
	   fsmn <= storekey1;	 
	end
	storekey1: begin
	   xrst <= 1;
	   xenc <= 1;
	   xse <= 1;
	   fsmn <= storekey2;	 
	end
	storekey2: begin
	   xrst <= 1;
	   xenc <= 1;
	   xse <= 1;
	   fsmn <= storekey3;	 
	end
	storekey3: begin
	   xrst <= 1;
	   xenc <= 1;
	   xse <= 1;
	   fsmn <= idle;	 
	end
	storenonce0: begin
`ifdef TWO	   
	   kdf <= 1;
`endif
	   pdi_ready <= 1;
	   senc <= 1;
	   sse <= 1;
	   erst <= 1;	   	   
	   fsmn <= storenonce1;
	end	
	storenonce1: begin
`ifdef TWO	   	   
	   kdf <= 1;
`endif
	   pdi_ready <= 1;
	   senc <= 1;
	   sse <= 1;
	   erst <= 1;	   
	   fsmn <= storenonce2;
	end	
	storenonce2: begin
`ifdef TWO	   	   
	   kdf <= 1;
`endif	   
	   pdi_ready <= 1;
	   senc <= 1;
	   sse <= 1;
	   erst <= 1;	   	   
	   fsmn <= storenonce3;
	end
	storenonce3: begin
`ifdef TWO	   
	   kdf <= 1;
`endif
	   pdi_ready <= 1;
	   senc <= 1;
	   sse <= 1;
	   erst <= 1;	   	   
	   fsmn <= encryptnonce;
	end
	encryptnonce: begin
`ifdef TWO	   
	   kdf <= 1;
`endif
	   correct_cntn <= 0;
	   senc <= 1;
	   xenc <= 1;
	   if (constant == FINCONST) begin
	      correct_cntn <= 1;	      
	      fsmn <= storeL0;
	      pdi_ready <= 1;	      
	   end	   
	end
	storeL0: begin
`ifdef MR
	   pdo_valid <= 1;	   
`endif
`ifdef TWO	   	   
	   kdf <= 1;
	   vf <= 1;	   
	   vse <= 1;
	   venc <= 1;	   
`else
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
`endif
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;	   
	   sl <= 1;	   
	   fsmn <= storeL1;	   	   
	end
	storeL1: begin
`ifdef MR
	   pdo_valid <= 1;	   
`endif
`ifdef TWO	   
	   kdf <= 1;	   
	   vse <= 1;
	   venc <= 1;	   	   
`else
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
`endif
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;	   
	   sl <= 1;	   
	   fsmn <= storeL2;	   	   
	end
	storeL2: begin
`ifdef MR
	   pdo_valid <= 1;	   
`endif
`ifdef TWO	   
	   kdf <= 1;
	   vse <= 1;
	   venc <= 1;
`else
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
`endif
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;	   
	   sl <= 1;
	   fsmn <= storeL3;	   	   
	end
	storeL3: begin
`ifdef MR
	   pdo_valid <= 1;	   
`endif
`ifdef TWO	   
	   kdf <= 1;
	   xenc <= 1;
	   xse <= 1;	   
	   fsmn <= encryptnonc2;
	   vf <= 1;
	   vse <= 1;
	   venc <= 1;
	   erst <= 1;	   
`else
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;	   
	   sse <= 1;
	   senc <= 1;	  
	   srst <= 1;
 `ifdef MR
	   if (dec) begin
	      fsmn <= storeT0;
	   end
	   else begin
	      fsmn <= storead0;
	   end
 `else
	   fsmn <= storead0;
 `endif
`endif
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;	  	   	   
	   sl <= 1;	   
	end // case: storeL3
`ifdef TWO
	encryptnonc2: begin
	   kdf <= 1;	   
	   correct_cntn <= 0;
	   senc <= 1;
	   xenc <= 1;	   
	   if (constant == FINCONST) begin
	      correct_cntn <= 1;	      
	      fsmn <= storeV0;
	      //pdi_ready <= 1;	      
	   end	   
	end
	storeV0: begin
`ifdef MR
	   pdo_valid <= 1;	   
`endif
	   ll <= 1;
	   kdf <= 1;
	   vse <= 1;
	   venc <= 1;	   	   
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;
	   vf <= 1;	   
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
	   sl <= 1;
	   fsmn <= storeV1;	   	   
	end
	storeV1: begin
`ifdef MR
	   pdo_valid <= 1;	   
`endif
	   ll <= 1;
	   kdf <= 1;
	   vse <= 1;
	   venc <= 1;	   	   
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;	   
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
	   sl <= 1;
	   fsmn <= storeV2;	   	   
	end
	storeV2: begin
`ifdef MR
	   pdo_valid <= 1;	   
`endif
	   ll <= 1;
	   kdf <= 1;
	   vse <= 1;
	   venc <= 1;	   	   
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;	   
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
	   sl <= 1;
	   fsmn <= storeV3;	   	   
	end
	storeV3: begin
`ifdef MR
	   pdo_valid <= 1;	   
`endif
	   ll <= 1;
	   kdf <= 1;
	   vse <= 1;
	   venc <= 1;	   	   
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;	  
	   srst <= 1;
	   vf <= 1;	   
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
	   sl <= 1;
 `ifdef MR
	   if (dec) begin
	      fsmn <= storeT0;
	   end
	   else begin
	      fsmn <= storead0;
	   end
 `else
	   fsmn <= storead0;
 `endif
	end // case: storeV3
`endif
	storead0: begin
	   if (pdi_valid) begin
	      pdi <= pdi_data;
	      pdi_ready <= 1;
	   end
	   else begin
	      pdi <= 0;	     
	      pdi_ready <= 0; 
	   end	   
`ifdef TWO
	   venc <= 1;
	   vf <= 1;	   
`endif
	   senc <= 1;
	   sse <= 1;
	   fsmn <= storead1;	   
	end
	storead1: begin
	   if (pdi_valid) begin
	      pdi <= pdi_data;
	      pdi_ready <= 1;
	   end
	   else begin
	      pdi <= 0;	     
	      pdi_ready <= 0; 
	   end	   
`ifdef TWO
	   venc <= 1;
`endif	   	   
	   senc <= 1;
	   sse <= 1;
	   fsmn <= storead2;	   
	end
	storead2: begin
	   if (pdi_valid) begin
	      pdi <= pdi_data;
	      pdi_ready <= 1;
	   end
	   else begin
	      pdi <= 0;	    
	      pdi_ready <= 0;  
	   end	   
`ifdef TWO
	   venc <= 1;
`endif	   	   
	   senc <= 1;
	   sse <= 1;
	   fsmn <= storead3;	   
	end
	storead3: begin
`ifdef TWO
	   venc <= 1;
	   fvn <= 0;	   	   
`endif	   	   
	   senc <= 1;
	   sse <= 1;
	   fsmn <= encryptad;
	   correct_cntn <= 1;
	   xenc <= 1;
	   xse <= 1;
	   erst <= 1;
	   if (pdi_valid && last) begin
	      pdi_ready <= 1;		 
	      if (adlen == 0) begin
		 dnew <= adfinal;
		 pdi <= pdi_data;		 
	      end
	      else begin
		 dnew <= adpadded;
		 pdi <= {pdi_data[31:4], adlen};		 
	      end	      
	   end // if (pdi_valid && last)
	   else if (pdi_valid) begin
	      dnew <= adnormal;
	      pdi <= pdi_data;
	      pdi_ready <= 1;		 
	   end
	   else begin
	      dnew <= adpadded;
	      pdi <= {0,adlen};
	      pdi_ready <= 0;		 
	   end
	end // case: storead3	
	encryptad: begin
	   correct_cntn <= 0;
	   senc <= 1;
	   xenc <= 1;
	   if (constant == FINCONST) begin	      
	      if (pdi_valid) begin
		 fsmn <= storead0;
	      end
	      else begin
		 pdi_ready <= 1;	      
		 fsmn <= storem0;		 
	      end
	   end	   
	end // case: encryptad
	storem0: begin
`ifdef TWO
	   venc <= 1;
	   vf <= 1;	   
`endif	   
	   if (dec) begin
	      decrypt <= 4'hF;	      
	   end
	   if (pdi_valid) begin
	      pdi <= pdi_data;
	      pdi_ready <= 1;
`ifdef MR
	      pdo_valid <= 0;
`else
	      pdo_valid <= 1;
`endif
	   end
	   else begin
	      pdi <= 0;	    
	      pdi_ready <= 0;
	      pdo_valid <= 0;	   
	   end	   	   	   
	   senc <= 1;
	   sse <= 1;
	   fsmn <= storem1;	   
	end
	storem1: begin
`ifdef TWO
	   venc <= 1;
`endif	   
	   if (dec) begin
	      decrypt <= 4'hF;	      
	   end
	   if (pdi_valid) begin
	      pdi <= pdi_data;
	      pdi_ready <= 1;
`ifdef MR
	      pdo_valid <= 0;
`else
	      pdo_valid <= 1;
`endif
	   end
	   else begin
	      pdi <= 0;	    
	      pdi_ready <= 0;
	      pdo_valid <= 0;	   
	   end	   	   	   
	   senc <= 1;
	   sse <= 1;
	   fsmn <= storem2;	   
	end
	storem2: begin
`ifdef TWO
	   venc <= 1;
`endif	   
	   if (dec) begin
	      decrypt <= 4'hF;	      
	   end
	   if (pdi_valid) begin
	      pdi <= pdi_data;
	      pdi_ready <= 1;
`ifdef MR
	      pdo_valid <= 0;
`else
	      pdo_valid <= 1;
`endif
	   end
	   else begin
	      pdi <= 0;	    
	      pdi_ready <= 0;
	      pdo_valid <= 0;	   
	   end	   	   	   
	   senc <= 1;
	   sse <= 1;
	   fsmn <= storem3;	   
	end
	storem3: begin
`ifdef TWO
	   venc <= 1;
`endif	   
	   if (dec) begin
	      decrypt <= 4'hF;	      
	   end
	   senc <= 1;
	   sse <= 1;
	   correct_cntn <= 1;	      
	   xenc <= 1;
	   xse <= 1;	      
	   erst <= 1;	      	   
	   fsmn <= encryptm;
	   if (pdi_valid && last) begin
`ifdef MR
	      pdo_valid <= 0;
`else
	      pdo_valid <= 1;
`endif	      
	      pdi_ready <= 1;		 
	      if (mlen == 0) begin
		 dnew <= msgfinal;
		 pdi <= pdi_data;		 
	      end
	      else begin
		 dnew <= msgpadded;
		 pdi <= {pdi_data[31:4], mlen};		 
	      end	      
	   end // if (pdi_valid && last)
	   else if (pdi_valid) begin	      
`ifdef MR
	      pdo_valid <= 0;
`else
	      pdo_valid <= 1;
`endif	      
	      dnew <= msgnormal;
	      pdi <= pdi_data;
	      pdi_ready <= 1;		 
	   end
	   else begin
	      dnew <= msgpadded;
	      pdi <= {0,mlen};
	      pdi_ready <= 0;		 
	   end	   
	end // case: storem
	encryptm: begin
	   correct_cntn <= 0;
	   senc <= 1;
	   xenc <= 1;
	   if (constant == FINCONST) begin
	      if (pdi_valid) begin
		 fsmn <= storem0;
	      end
	      else if (dec) begin
		 fsmn <= verifytag0;
	      end
	      else begin
		 fsmn <= outputtag0;
	      end	   
	   end // if (constant == FINCONST)
	end // case: encryptm
	outputtag0: begin
`ifdef TWO
	   vl <= 1;
	   venc <= 1;	   
`endif
	   pdi <= 0;
	   pdo_valid <= 1;
	   senc <= 1;
	   sse <= 1;	   
	   fsmn <= outputtag1;	   
	end
	outputtag1: begin
`ifdef TWO
	   vl <= 1;
	   venc <= 1;	   
`endif	   
	   pdi <= 0;
	   pdo_valid <= 1;
	   senc <= 1;
	   sse <= 1;	   	   
	   fsmn <= outputtag2;	   
	end
	outputtag2: begin
`ifdef TWO
	   vl <= 1;
	   venc <= 1;	   
`endif	   
	   pdi <= 0;
	   pdo_valid <= 1;
	   senc <= 1;
	   sse <= 1;	   	   
	   fsmn <= outputtag3;	   
	end
	outputtag3: begin
`ifdef TWO
	   vl <= 1;
	   venc <= 1;	   
`endif	   
	   pdi <= 0;
	   pdo_valid <= 1;
	   senc <= 1;
	   sse <= 1;	   
`ifdef MR
	   srst <= 1;	   
	   fsmn <= storeLT0;
`else
	   fsmn <= idle;
`endif
	end
	verifytag0: begin
`ifdef TWO
	   vl <= 1;
	   venc <= 1;	   
`endif	   
	   fsmn <= verifytag1;	   
	   if (pdo == 32'h0) begin
	      decn <= 1;	      
	   end
	   else begin
	      decn <= 0;	      
	   end
	end
	verifytag1: begin
`ifdef TWO
	   vl <= 1;
	   venc <= 1;	   
`endif	   
	   fsmn <= verifytag2;	   
	   if (pdo == 32'h0) begin
	      decn <= 1;	      
	   end
	   else begin
	      decn <= 0;	      
	   end
	end
	verifytag2: begin
`ifdef TWO
	   vl <= 1;
	   venc <= 1;	   
`endif
	   fsmn <= verifytag3;	   
	   if (pdo == 32'h0) begin
	      decn <= 1;	      
	   end
	   else begin
	      decn <= 0;	      
	   end
	end
	verifytag3: begin
`ifdef TWO
	   vl <= 1;
	   venc <= 1;	   
`endif	   
	   fsmn <= idle;
	   pdo_valid <= 1;	   
	   if ((pdo == 32'h0)&&dec) begin
	      fail <= 0;	      
	   end
	   else begin
	      fail <= 1;	      
	   end
	end // case: verifytag3
`ifdef MR
	storeLT0: begin
	   if (pdi_valid && last) begin
	      fsmn <= idle;
	   end
	   else if (pdi_valid) begin
`ifdef TWO
	      vs2 <= 1;
	      kdf <= 1;
	      venc <= 1;
`else
	      xenc <= 1;
	      xse <= 1;
	      xrst <= 1;
`endif
	      sl <= 1;
	      fsmn <= storeLT1;
	      dnew <= 0;
	      fvn <= 1;	      
	   end
	end // case: storeLT0
	storeLT1: begin
	   if (pdi_valid) begin
`ifdef TWO
	      vs2 <= 1;
	      kdf <= 1;
	      venc <= 1;
`else
	      xenc <= 1;
	      xse <= 1;
	      xrst <= 1;
`endif
	      sl <= 1;
	      fsmn <= storeLT2;	      
	   end	   
	end
	storeLT2: begin
if (pdi_valid) begin
`ifdef TWO
	      vs2 <= 1;
	      kdf <= 1;
	      venc <= 1;
`else
	      xenc <= 1;
	      xse <= 1;
	      xrst <= 1;
`endif
	      sl <= 1;
	      fsmn <= storeLT3;	      
	   end	   
	end // case: storeLT2
	storeLT3: begin
	   if (pdi_valid) begin
`ifdef TWO
	      vs2 <= 1;
	      kdf <= 1;
	      venc <= 1;
	      fsmn <= storeVT0;	      
`else
	      xenc <= 1;
	      xse <= 1;
	      xrst <= 1;
	      if (dec) begin
		 fsmn <= storead0;
	      end
	      else begin
		 fsmn <= storeT0;
	      end
`endif
	      sl <= 1;	      
	   end	   
	end // case: storeLT3
`ifdef TWO
	storeVT0: begin
	   vs2 <= 1;
	   ll <= 1;
	   kdf <= 1;
	   venc <= 1;	   	   
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;
	   vf <= 1;	   
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
	   sl <= 1;
	   fsmn <= storeVT1;	   	   	  
	end // case: storeVT0
	storeVT1: begin
	   vs2 <= 1;
	   ll <= 1;
	   kdf <= 1;
	   venc <= 1;	   	   
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;
	   vf <= 1;	   
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
	   sl <= 1;
	   fsmn <= storeVT2;	   	   	  
	end // case: storeVT0
	storeVT2: begin
	   vs2 <= 1;
	   ll <= 1;
	   kdf <= 1;
	   venc <= 1;	   	   
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;
	   vf <= 1;	   
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
	   sl <= 1;
	   fsmn <= storeVT3;	   	   	  
	end // case: storeVT0
	storeVT3: begin
	   vs2 <= 1;
	   ll <= 1;
	   kdf <= 1;
	   venc <= 1;	   	   
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;
	   vf <= 1;	   
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
	   sl <= 1;
	   if (dec) begin
	      fsmn <= storead0;
	   end
	   else begin
	      fsmn <= storeT0;
	   end
	end // case: storeVT0	
`endif
	storeT0 : begin
	   if (pdi_valid) begin
	      if (dec&&last) begin
		 fsmn <= storeLT0;		 
	      end
	      pdi_ready <= 1;
	      senc <= 1;
	      sse <= 1;
	      erst <= 1;	   	   
	      fsmn <= storeT1;	   
	   end
	end
	storeT1 : begin
	   pdi_ready <= 1;
	   senc <= 1;
	   sse <= 1;
	   erst <= 1;	   	   
	   fsmn <= storeT2;	   
	end
	storeT2 : begin
	   pdi_ready <= 1;
	   senc <= 1;
	   sse <= 1;
	   erst <= 1;	   	   
	   fsmn <= storeT3;	   
	end
	storeT3 : begin
	   pdi_ready <= 1;
	   senc <= 1;
	   sse <= 1;
	   erst <= 1;	   	   
	   fsmn <= encryptm2;
	   xenc <= 1;
	   xse <= 1;	      
	   dnew <= msgenc;
	   fvn <= 0;	   
	end
	encryptm2: begin
	   correct_cntn <= 0;
	   senc <= 1;
	   xenc <= 1;
	   if (constant == FINCONST) begin
	      if (pdi_valid) begin
		 fsmn <= storem20;
	      end
	   end // if (constant == FINCONST)
	end // case: encryptm2
	storem20: begin
`ifdef TWO
	   venc <= 1;
	   vf <= 1;	   
`endif	   
	   if (dec) begin
	      decrypt <= 4'hF;	      
	   end
	   if (pdi_valid) begin
	      pdi <= pdi_data;
	      pdi_ready <= 1;
`ifdef MR
	      pdo_valid <= 0;
`else
	      pdo_valid <= 1;
`endif
	   end
	   else begin	      
	      pdi <= 0;	    
	      pdi_ready <= 0;
	      pdo_valid <= 0;	   
	   end	   	   	   
	   senc <= 1;
	   sse <= 1;
	   if (last) begin
`ifdef MR
	      if (dec) begin
		 fsmn <= storeLT0;
	      end
	      else begin
		 fsmn <= idle;
	      end
`else
	      fsmn <= idle;
`endif	      
	   end
	   else begin
	      fsmn <= storem21;
	   end
	end
	storem21: begin
`ifdef TWO
	   venc <= 1;
`endif	   
	   if (dec) begin
	      decrypt <= 4'hF;	      
	   end
	   if (pdi_valid) begin
	      pdi <= pdi_data;
	      pdi_ready <= 1;
`ifdef MR
	      pdo_valid <= 0;
`else
	      pdo_valid <= 1;
`endif
	   end
	   else begin
	      pdi <= 0;	    
	      pdi_ready <= 0;
	      pdo_valid <= 0;	   
	   end	   	   	   
	   senc <= 1;
	   sse <= 1;
	   if (last) begin
`ifdef MR
	      if (dec) begin
		 fsmn <= storeLT0;
	      end
	      else begin
		 fsmn <= idle;
	      end
`else
	      fsmn <= idle;
`endif	      
	   end
	   else begin
	      fsmn <= storem22;
	   end	   
	end
	storem22: begin
`ifdef TWO
	   venc <= 1;
`endif	   
	   if (dec) begin
	      decrypt <= 4'hF;	      
	   end
	   if (pdi_valid) begin
	      pdi <= pdi_data;
	      pdi_ready <= 1;
`ifdef MR
	      pdo_valid <= 0;
`else
	      pdo_valid <= 1;
`endif
	   end
	   else begin
	      pdi <= 0;	    
	      pdi_ready <= 0;
	      pdo_valid <= 0;	   
	   end	   	   	   
	   senc <= 1;
	   sse <= 1;
	   if (last) begin
`ifdef MR
	      if (dec) begin
		 fsmn <= storeLT0;
	      end
	      else begin
		 fsmn <= idle;
	      end
`else
	      fsmn <= idle;
`endif
	   end
	   else begin
	      fsmn <= storem23;
	   end	   
	end
	storem23: begin
`ifdef TWO
	   venc <= 1;
`endif	   
	   if (dec) begin
	      decrypt <= 4'hF;	      
	   end
	   senc <= 1;
	   sse <= 1;
	   correct_cntn <= 1;	      
	   xenc <= 1;
	   xse <= 1;	      
	   erst <= 1;	      	   
	   fsmn <= encryptm2;
	   if (pdi_valid && last) begin
`ifdef MR
	      pdo_valid <= 0;
`else
	      pdo_valid <= 1;
`endif	      
	      pdi_ready <= 1;		 
	      if (mlen == 0) begin		 
		 pdi <= pdi_data;		 
	      end
	      else begin		 
		 pdi <= {pdi_data[31:4], mlen};		 
	      end	      
	   end // if (pdi_valid && last)
	   else if (pdi_valid) begin	      
`ifdef MR
	      pdo_valid <= 0;
`else
	      pdo_valid <= 1;
`endif	      
	      pdi <= pdi_data;
	      pdi_ready <= 1;		 
	   end
	   if (last) begin
`ifdef MR
	      if (dec) begin
		 fsmn <= storeLT0;
	      end
	      else begin
		 fsmn <= idle;
	      end
`else
	      fsmn <= idle;
`endif
	   end
	   else begin
	      fsmn <= encryptm2;
	   end	   
	end // case: storem
`endif
      endcase // case (fsm)      
   end
   
endmodule // cu128
