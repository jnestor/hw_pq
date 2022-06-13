//-----------------------------------------------------------------------------
// Module Name   : seven_seg_n: Seven-segment decoder with active low outputs
// Project       : RTL Hardware Design and Verification using SystemVerilog
//-----------------------------------------------------------------------------
// Author        : John Nestor  <nestorj@lafayette.edu>
// Created       : Feb 2020
//-----------------------------------------------------------------------------
// Description   : BCD seven-segment decoder with active low outputs.
// Segments are ordered as follows: segs_n[6]=g, segs_n[0]=a
//-----------------------------------------------------------------------------

module sevenseg_ext_n(
		 input logic [6:0]  d,
		 output logic [6:0] segs_n,  // ordered g(6) - a(0)
		 output logic dp_n
		 );
   logic blank, dp, dash;
   assign blank = d[6];
   assign dp = d[5];
   assign dash = d[4];

   assign dp_n = !(!blank && dp);

   always_comb begin
	   if (blank) segs_n = 7'b1111111;
	   else if (dash) segs_n = 7'b0111111;
	   else begin
		   case (d[3:0])     //  gfedcba
			   4'd0: segs_n = 7'b1000000;
			   4'd1: segs_n = 7'b1111001;
			   4'd2: segs_n = 7'b0100100;
			   4'd3: segs_n = 7'b0110000;
			   4'd4: segs_n = 7'b0011001;
			   4'd5: segs_n = 7'b0010010;
			   4'd6: segs_n = 7'b0000010;
			   4'd7: segs_n = 7'b1111000;
			   4'd8: segs_n = 7'b0000000;
			   4'd9: segs_n = 7'b0010000;
			   4'd10: segs_n = 7'b0001000;  // "A"
			   4'd11: segs_n = 7'b0001100;  // "P"
			   4'd12: segs_n = 7'b1000110;  // "C"
			   4'd15: segs_n = 7'b0001110;  // "F"
			   default: segs_n = 7'b1111111;
		   endcase
	   end
   end
endmodule: sevenseg_ext_n
