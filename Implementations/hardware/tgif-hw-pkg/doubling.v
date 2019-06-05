module doubling (/*AUTOARG*/
   // Outputs
   so,
   // Inputs
   si, dold, dnew
   ) ;
   output [127:0] so;
   input [127:0]  si;
   input [7:0] 	  dold, dnew;

   wire [127:0]   li, lo;
   
   assign li = {si[7:0] ^ dold,
		si[15:8],
		si[23:16],
		si[31:24],
		si[39:32],
		si[47:40],
		si[55:48],
		si[63:56],
		si[71:64],
		si[79:72],
		si[87:80],
		si[95:88],
		si[103:96],
		si[111:104],
		si[119:112],
		si[127:120]
		}; 

   assign lo = {li[126:0], li[127]} ^ {120'h0, li[127], 4'h0, li[127], li[127] , 1'b0};

   assign so = {lo[7:0],
		lo[15:8],
		lo[23:16],
		lo[31:24],
		lo[39:32],
		lo[47:40],
		lo[55:48],
		lo[63:56],
		lo[71:64],
		lo[79:72],
		lo[87:80],
		lo[95:88],
		lo[103:96],
		lo[111:104],
		lo[119:112],
		lo[127:120] ^ dnew
		}; 
   
endmodule // doubling


