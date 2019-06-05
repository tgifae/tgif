module apinodec (/*AUTOARG*/
   // Outputs
   pdo_data, pdi, pdi_ready, sdi_ready, pdo_valid, dold, dnew, srst,
   senc, sse, xrst, xenc, xse, erst, correct_cnt, sl,
   // Inputs
   counter, pdi_data, pdo, pdi_valid, sdi_valid, pdo_ready, clk, rst,
   constant
   ) ;
   // SKINNY FINAL CONSTANT
   parameter FINCONST = 7'b011010;
   
   // INSTRUCTIONS
   parameter LDKEY = 4;
   parameter ACTKEY = 7;
   parameter ENC = 2;
   parameter DEC = 3;
   parameter SUCCESS = 14;
   parameter FAILURE = 15;

   //SEGMENT HEADERS
   parameter RSRVD1 = 0;
   parameter AD = 1;
   parameter NpubAD = 2; 
   parameter ADNpub = 3; 
   parameter PLAIN = 4; 
   parameter CIPHER = 5; 
   parameter CIPHERTAG = 6; 
   parameter RSRVD = 7; 
   parameter TAG = 8; 
   parameter RSRVD2 = 9; 
   parameter LENGTH = 10;
   parameter RSRVD3 = 11;  
   parameter KEY = 12; 
   parameter Npub = 13; 
   parameter Nsec = 14; 
   parameter ENCNsec = 15;

   // DOMAINS
   parameter adnormal = 4;
   parameter adfinal = 12;
   parameter adpadded = 13;
   parameter msgnormal = 2;
   parameter msgfinal = 10;
   parameter msgpadded = 11;   
   
   //STATES
   parameter idle = 0;
   parameter storekey1 = 1;
   parameter storekey2 = 2;
   parameter storekey3 = 3;
   parameter storekey4 = 4;
   parameter keyheader = 5;
   parameter nonceheader = 6;
   parameter storenonce1 = 7;
   parameter storenonce2 = 8;
   parameter storenonce3 = 9;
   parameter storenonce4 = 10;
   parameter storeL0 = 11;
   parameter storeL1 = 12;
   parameter storeL2 = 13;
   parameter storeL3 = 14;
   parameter adheader = 15;
   parameter msgheader = 16; 
   parameter storeadsp_1 = 17;
   parameter storeadsp_2 = 18;
   parameter storeadsp_3 = 19;
   parameter storeadsp_4 = 20;
   parameter storeadsf_1 = 21;
   parameter storeadsf_2 = 22;
   parameter storeadsf_3 = 23;
   parameter storeadsf_4 = 24;
   parameter encryptad = 25;  
   parameter encryptnonce = 26;   
   parameter storemp_1 = 27;
   parameter storemp_2 = 28;
   parameter storemp_3 = 29;
   parameter storemp_4 = 30;
   parameter storemf_1 = 31;
   parameter storemf_2 = 32;
   parameter storemf_3 = 33;
   parameter storemf_4 = 34;
   parameter encryptmsg = 35;
   parameter outputtag1 = 36;
   parameter outputtag2 = 37;   
   parameter outputtag3 = 38;   
   parameter outputtag4 = 39;
   parameter outputtag0 = 40;   
   parameter verifytag1 = 41;
   parameter verifytag2 = 42;	
   parameter verifytag3 = 43;	
   parameter verifytag4 = 44;
   parameter verifytag0 = 45;	
   
   output reg [31:0] pdo_data, pdi;
   output reg 	     pdi_ready, sdi_ready, pdo_valid;

   output [7:0]      dold, dnew;
   output reg 	     srst, senc, sse;
   output reg 	     xrst, xenc, xse;
   output reg 	     erst;
   output reg 	     correct_cnt;  
   output reg 	     sl;   
   
   input [55:0]      counter;   
   input [31:0]  pdi_data, pdo;
   input 	 pdi_valid, sdi_valid, pdo_ready;

   input 	 clk, rst;

   input [5:0] 	 constant;

   reg [6:0] 	 fsm, fsmn;
   reg [15:0] 	 seglen, seglenn;  
   reg [3:0] 	 flags, flagsn;
   reg [7:0]	 nonce_domain, nonce_domainn;
   reg 		 correct_cntn;

   assign dold = nonce_domain;
   assign dnew = nonce_domainn;   

   always @ (posedge clk) begin
      if (rst) begin
	 fsm <= idle;
	 seglen <= 0;
	 flags <= 0;
	 correct_cnt <= 1;
	 nonce_domain <= 0;	 
      end
      else begin
	 fsm <= fsmn;
	 seglen <= seglenn;
	 flags <= flagsn;
	 nonce_domain <= nonce_domainn;
	 correct_cnt <= correct_cntn;	 
      end
   end


   always @ ( /*AUTOSENSE*/constant or correct_cnt or flags or fsm
	     or nonce_domain or pdi_data or pdi_valid or pdo
	     or pdo_ready or sdi_valid or seglen) begin
      pdo_data <= 0;      
      pdi <= pdi_data;      
      srst   <= 0;
      senc   <= 0;
      sse    <= 0;
      xrst   <= 0;
      xenc   <= 0;
      xse    <= 0;
      erst   <= 0;
      sl <= 0;      
      sdi_ready <= 0;
      pdi_ready <= 0;
      pdo_valid <= 0;
      nonce_domainn <= nonce_domain;      
      fsmn <= fsm;
      seglenn <= seglen; 
      flagsn <= flags;
      correct_cntn <= correct_cnt;
      case (fsm) 
	idle: begin
	   nonce_domainn <= 0;	   
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      if (pdi_data[31:28] == LDKEY) begin
		 fsmn <= keyheader;		 
	      end
	      else if (pdi_data[31:28] == ENC) begin
		 correct_cntn <= 1;	      
		 fsmn <= nonceheader;
	      end
	   end
	end
	keyheader: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      if (pdi_data[31:28] == KEY) begin
		 fsmn <= storekey1;		 
	      end	      
	   end
	end
	storekey1: begin
	   if (sdi_valid) begin
	      sdi_ready <= 1;	      
	      xrst <= 1;
	      xenc <= 1;
	      xse <= 1;	      
	      fsmn <= storekey2;	      
	   end
	end
	storekey2: begin
	   if (sdi_valid) begin
	      sdi_ready <= 1;	      
	      xrst <= 1;
	      xenc <= 1;
	      xse <= 1;	      	      
	      fsmn <= storekey3;	      
	   end
	end
	storekey3: begin
	   if (sdi_valid) begin
	      sdi_ready <= 1;	      
	      xrst <= 1;
	      xenc <= 1;
	      xse <= 1;	      	      
	      fsmn <= storekey4;	      
	   end
	end
	storekey4: begin
	   if (sdi_valid) begin
	      sdi_ready <= 1;	      
	      xrst <= 1;
	      xenc <= 1;
	      xse <= 1;	      	      	      
	      fsmn <= idle;	      
	   end
	end
	nonceheader: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      senc <= 1;
	      sse <= 1;
	      srst <= 1;	      
	      if (pdi_data[31:28] == Npub) begin
		 fsmn <= storenonce1;		 
	      end	      
	   end
	end
	storenonce1: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;	      
	      fsmn <= storenonce2;	      
	   end
	end
	storenonce2: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      senc <= 1;
	      sse <= 1;	      
	      fsmn <= storenonce3;	      
	   end
	end
	storenonce3: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      senc <= 1;
	      sse <= 1;	      
	      fsmn <= storenonce4;
	      correct_cntn <= 1;
	   end
	end
	storenonce4: begin
	   if (pdi_valid) begin
	      //pdi_ready <= 1;
	      senc <= 1;
	      sse <= 1;	      
	      correct_cntn <= 1;	      
	      fsmn <= encryptnonce;
	      erst <= 1;		 
	   end
	end
	adheader: begin
	   senc <= 1;
	   srst <= 1;
	   sse <= 1;	   
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      if (pdi_data[31:28] == AD) begin
		 seglenn <= pdi_data[15:0];
		 flagsn <= pdi_data[27:24];		 
		 if (pdi_data[15:0] < 16) begin
		    fsmn <= storeadsp_1;
		 end
		 else begin
		    fsmn <= storeadsf_1;
		 end
	      end	      
	   end
	end // case: adheader
	storeadsf_1: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      seglenn <= seglen - 16;
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadsf_2;
	   end	   
	end
	storeadsf_2: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadsf_3;
	   end	   
	end
	storeadsf_3: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadsf_4;
	   end	   
	end
	storeadsf_4: begin
	   if (pdi_valid) begin
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      if (seglen == 0) begin
		 nonce_domainn <= adfinal;
	      end
	      else begin
		 nonce_domainn <= adnormal;
	      end
	      correct_cntn <= 1;	      
	      fsmn <= encryptad;
	      xenc <= 1;
	      xse <= 1;
	      erst <= 1;	      
	   end	   
	end
	storeadsp_1: begin
	   if (seglen > 0) begin	   
	      if (pdi_valid) begin
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 fsmn <= storeadsp_2;
	      end
	   end
	   else begin
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadsp_2;
	      pdi <= 0;	      	      
	   end
	end
	storeadsp_2: begin
	   if (seglen[3:0] > 4) begin
	      if (pdi_valid) begin
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 fsmn <= storeadsp_3;
	      end
	   end
	   else begin
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadsp_3;
	      pdi <= 0;	      
	   end
	end
	storeadsp_3: begin
	   if (seglen[3:0] > 8) begin
	      if (pdi_valid) begin
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 fsmn <= storeadsp_4;
	      end
	   end
	   else begin
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storeadsp_4;
	      pdi <= 0;	      
	   end
	end
	storeadsp_4: begin
	   seglenn <= 0;
	   nonce_domainn <= adpadded;	   	   
	   if (seglen[3:0] > 12) begin
	      if (pdi_valid) begin
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 correct_cntn <= 1;	      
		 fsmn <= encryptad;
		 pdi <= pdi_data | {28'h0,seglen[3:0]};
		 xenc <= 1;
		 xse <= 1;
		 nonce_domainn <= adpadded;
		 erst <= 1;	      
	      end	      
	   end // if (seglen[3:0] > 12)
	   else begin
	      senc <= 1;
	      sse <= 1;
	      correct_cntn <= 1;	      
	      fsmn <= encryptad;
	      pdi <= {28'h0,seglen[3:0]};
	      xenc <= 1;
	      xse <= 1;
	      nonce_domainn <= adpadded;
	      erst <= 1;	      
	   end // else: !if(pdi_valid)
	end // case: storetps0_4
	encryptad: begin
	   correct_cntn <= 0;
	   senc <= 1;
	   xenc <= 1;
	   if (constant == FINCONST) begin
	      //pdi_ready <= 1;	      
	      if (seglen == 0) begin
		 if (flags[1] == 1) begin
		    fsmn <= msgheader;
		 end
		 else begin
		    fsmn <= adheader;
		 end
	      end
	      else if (seglen < 16) begin
		 fsmn <= storeadsp_1;
	      end	      
	      else begin
		 fsmn <= storeadsf_1;
	      end
	   end
	end // case: encryptad
	encryptnonce: begin
	   correct_cntn <= 0;
	   senc <= 1;
	   xenc <= 1;
	   if (constant == FINCONST) begin
	      correct_cntn <= 1;	      
	      fsmn <= storeL0;
	      pdi_ready <= 1;	      
	   end
	end // case: encryptnonce
	storeL0: begin
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;	   
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
	   sl <= 1;
	   fsmn <= storeL1;	   
	end
	storeL1: begin
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;	   
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
	   sl <= 1;
	   fsmn <= storeL2;	   
	end
	storeL2: begin
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;	   
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
	   sl <= 1;
	   fsmn <= storeL3;	   
	end
	storeL3: begin
	   pdi <= 0;
	   sse <= 1;
	   senc <= 1;	   
	   xenc <= 1;
	   xse <= 1;
	   xrst <= 1;
	   sl <= 1;
	   fsmn <= adheader;	   
	end	
	msgheader: begin
	   if (pdi_valid) begin
	      if ((pdi_data[31:28] == PLAIN) || (pdi_data[31:28] == CIPHER)) begin
		 pdo_valid <= 1;
		 pdo_data <= {CIPHER, pdi_data[27:0]};
		 if (pdo_ready) begin
		    pdi_ready <= 1;
		    seglenn <= pdi_data[15:0];
		    flagsn <= pdi_data[27:24];		 
		    if (pdi_data[15:0] < 16) begin
		       fsmn <= storemp_1;		    
		    end
		    else begin
		       fsmn <= storemf_1;		    
		    end
		 end // if (pdo_ready)		 
	      end // if (pdi_data[31:28] == PLAIN)	      	      
	   end // if (pdi_valid)
	   else begin
	      pdi_ready <= 1;
	   end
	end // case: msgheader
	storemp_1: begin
	   if (pdi_valid) begin	      
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;	      
	      case (seglen[3:0])
		0: begin
		   pdi <= 32'h0;
		   pdo_valid <= 0;
		end
		1: begin
		   pdo_data <= {pdo[31:24], 24'h0};
		   pdo_valid <= 1;
		end
		2: begin
		   pdo_data <= {pdo[31:16], 16'h0};
		   pdo_valid <= 1;
		end
		3: begin
		   pdo_data <= {pdo[31:8], 8'h0};
		   pdo_valid <= 1;
		end
		default: begin
		   pdo_data <= pdo;
		   pdo_valid <= 1;
		end
	      endcase // case (seglen[3:0])	     
	      if (pdo_ready) begin
		 fsmn <= storemp_2;
	      end
	   end	   	   
	end
	storemp_2: begin
	   if (seglen[3:0] > 4) begin
	      if (pdi_valid) begin	      
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 case (seglen[3:0]) 
		   5: begin
		      pdo_data <= {pdo[31:24], 24'h0};
		   end
		   6: begin
		      pdo_data <= {pdo[31:16], 16'h0};
		   end
		   7: begin
		      pdo_data <= {pdo[31:8], 8'h0};
		   end
		   default: begin
		      pdo_data <= pdo;
		   end
		 endcase // case (seglen[3:0])	     		 
		 pdo_valid <= 1;
		 if (pdo_ready) begin
		    fsmn <= storemp_3;
		 end
	      end
	   end
	   else begin
	      pdi <= 32'h0;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storemp_3;
	   end
	end
	storemp_3: begin
	   if (seglen[3:0] > 8) begin
	      if (pdi_valid) begin
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 case (seglen[3:0]) 
		   9: begin
		      pdo_data <= {pdo[31:24], 24'h0};
		   end
		   10: begin
		      pdo_data <= {pdo[31:16], 16'h0};
		   end
		   11: begin
		      pdo_data <= {pdo[31:8], 8'h0};
		   end
		   default: begin
		      pdo_data <= pdo;
		   end
		 endcase // case (seglen[3:0])	     		 
		 pdo_valid <= 1;
		 if (pdo_ready) begin
		    fsmn <= storemp_4;
		 end
	      end
	   end
	   else begin
	      pdi <= 32'h0;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storemp_4;
	   end
	end
	storemp_4: begin
	   seglenn <= 0;	   
	   if (seglen[3:0] > 12) begin
	      if (pdi_valid) begin
		 pdi <= pdi_data | {28'h0,seglen[3:0]};	      		 
		 pdi_ready <= 1;	      
		 senc <= 1;
		 sse <= 1;
		 nonce_domainn <= msgpadded;	
		 correct_cntn <= 1;	      
		 xenc <= 1;
		 xse <= 1;	      		 
		 erst <= 1;
		 case (seglen[3:0]) 
		   13: begin
		      pdo_data <= {pdo[31:24], 24'h0};
		   end
		   14: begin
		      pdo_data <= {pdo[31:16], 16'h0};
		   end
		   15: begin
		      pdo_data <= {pdo[31:8], 8'h0};
		   end
		   default: begin
		      pdo_data <= pdo;
		   end
		 endcase // case (seglen[3:0])	     		 		 
		 pdo_data <= pdo;
		 pdo_valid <= 1;
		 if (pdo_ready) begin
		    fsmn <= encryptmsg;
		 end	      	      		 
	      end
	   end
	   else begin
	      pdi <= {28'h0,seglen[3:0]};	      
	      senc <= 1;
	      sse <= 1;
	      nonce_domainn <= msgpadded;	
	      correct_cntn <= 1;	      
	      xenc <= 1;
	      xse <= 1;	      	      
	      erst <= 1;
	      fsmn <= encryptmsg;	      
	   end // else: !if(seglen[3:0] > 12)
	end // case: storemp_4	
	storemf_1: begin
	   if (pdi_valid) begin
	      pdo_valid <= 1;
	      pdo_data <= pdo;	      
	      seglenn <= seglen - 16;	      
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storemf_2;
	   end	   	   
	end
	storemf_2: begin
	   if (pdi_valid) begin
	      pdo_valid <= 1;
	      pdo_data <= pdo;	      	      
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storemf_3;
	   end	   	   
	end
	storemf_3: begin
	   if (pdi_valid) begin
	      pdo_valid <= 1;
	      pdo_data <= pdo;	      	      
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      fsmn <= storemf_4;
	   end	   	   
	end
	storemf_4: begin
	   if (pdi_valid) begin
	      pdo_valid <= 1;
	      pdo_data <= pdo;	     	      
	      pdi_ready <= 1;	      
	      senc <= 1;
	      sse <= 1;
	      if (seglen == 0) begin
		 nonce_domainn <= msgfinal;	
	      end
	      else begin
		 nonce_domainn <= msgnormal;	
	      end	      
	      correct_cntn <= 1;	      
	      xenc <= 1;
	      xse <= 1;	      
	      erst <= 1;	      
	      fsmn <= encryptmsg;
	   end	   	   
	end
	encryptmsg: begin
	   correct_cntn <= 0;
	   senc <= 1;
	   xenc <= 1;
	   if (constant == FINCONST) begin	      
	      if (seglen == 0) begin
		 if (flags[1] == 1) begin
		    fsmn <= outputtag0;
		 end
		 else begin
		    fsmn <= msgheader;		    
		 end
	      end
	      else if (seglen < 16) begin
		 fsmn <= storemp_1;		 
	      end
	      else begin
		 fsmn <= storemf_1;		 
	      end
	   end
	end // case: encryptmsg
	outputtag0: begin
	   pdi <= 0;	   
	   pdo_valid <= 1;	   
	   pdo_data <= {TAG,4'h3,8'h0,16'h010};
	   if (pdo_ready) begin
	      fsmn <= outputtag1;	      
	   end
	end
	outputtag1: begin
	   pdi <= 0;	   
	   senc <= 1;
	   sse <= 1;
	   xenc <= 1;
	   xse <= 1;
	   pdo_valid <= 1;	   
	   pdo_data <= pdo;
	   if (pdo_ready) begin
	      fsmn <= outputtag2;	      
	   end	   
	end
	outputtag2: begin
	   pdi <= 0;	   
	   senc <= 1;
	   sse <= 1;
	   xenc <= 1;
	   xse <= 1;
	   pdo_valid <= 1;	   
	   pdo_data <= pdo;
	   if (pdo_ready) begin
	      fsmn <= outputtag3;	      
	   end	   
	end
	outputtag3: begin
	   pdi <= 0;	   
	   senc <= 1;
	   sse <= 1;
	   xenc <= 1;
	   xse <= 1;
	   pdo_valid <= 1;	   
	   pdo_data <= pdo;
	   if (pdo_ready) begin
	      fsmn <= outputtag4;	      
	   end	   
	end
	outputtag4: begin
	   pdi <= 0;	   
	   senc <= 1;
	   sse <= 1;
	   xenc <= 1;
	   xse <= 1;
	   pdo_valid <= 1;	   
	   pdo_data <= pdo;
	   if (pdo_ready) begin
	      fsmn <= idle;	      
	   end	   	   
	end // case: outputtag4
      endcase // case (fsm)      
	  


      
   end
   

   
endmodule // apinodec
