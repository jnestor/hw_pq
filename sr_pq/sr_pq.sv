// Shift-register version of the priority queue
//
//

module sr_pq #(parameter KW=4, VW=4, DEPTH=4) (
  input logic clk, rst, push, pop,
  input logic [KW+VW-1:0] kvi,
  output logic [KW+VW-1:0] kvo,  // lowest element in queue
  output logic full, empty
  );
   parameter [KW-1:0] KEYINF = '1;
   parameter [VW-1:0] VAL0 = '0;
  

   logic [0:DEPTH+1] ki_lt_k_v;        // vector of comparator outputs
   logic [0:DEPTH+1][KW+VW-1:0] kv_v;  // vector of stored key-value pairs

   assign ki_lt_k_v[0] = 0;   
   assign ki_lt_k_v[DEPTH+1] = 1;
   assign kv_v[0] = kvi;
   assign kv_v[DEPTH+1] = { KEYINF, VAL0 };
   assign kvo = kv_v[1];

   assign empty = (kv_v[1][KW+VW-1:VW] == KEYINF);
   assign full = (kv_v[DEPTH][KW+VW-1:VW] != KEYINF);

   genvar i;
   generate for (i=1; i<=DEPTH; i++) begin
       sr_pq_stage  #(.KW(KW), .VW(VW)) U_STAGE (
          .clk, .rst, .push, .pop,
          .ki_lt_kprev(ki_lt_k_v[i-1]), 
          .ki_lt_knext(ki_lt_k_v[i+1]),
          .kvi, .kvprev(kv_v[i-1]), .kvnext(kv_v[i+1]),
          .kv(kv_v[i]),
          .ki_lt_k(ki_lt_k_v[i])
       );
    end
    endgenerate

endmodule: sr_pq
