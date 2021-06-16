// Shift-register version of the priority queue
//
//

`include "../pk_pkg.sv"
import pq_pkg::*;

module sr_pq (
  pq_int.pq_devint di
);

logic clk;

assign clk = di.clk;

  
  logic full, empty;
  

   logic [0:PQ_CAPACITY+1] ki_lt_k_v;        // vector of comparator outputs
   kv_t [0:PQ_CAPACITY+1]  kv_v;  // vector of stored key-value pairs

   assign ki_lt_k_v[0] = 0;   
   assign ki_lt_k_v[PQ_CAPACITY+1] = 1;
   assign kv_v[0] = di.idata;
   assign kv_v[DEPTH+1].key = KEYINF;
   assign kvo = kv_v[1];

   assign empty = (kv_v.key == KEYINF);
   assign full = (kv_v[DEPTH].key != KEYINF);

   genvar i;
   generate for (i=1; i<=PQ_CAPACITY; i++) begin
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
