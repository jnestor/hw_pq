// Shift-register version of the priority queue
//
//

//`include "../pk_pkg.sv"
import pq_pkg::*;

module sr_pq (
  pq_if.dev di
);

logic clk, rst;
kv_t kvi, kvo;

assign kvi = di.idata;
assign di.odata = kvo;

assign clk = di.clk;

assign rst = di.rst;

  
  logic full, empty;
  logic push, pop;
  
  assign di.full = full;
  assign di.irdy = !full;
  assign di.ovalid = !empty;
  assign di.busy = 0;  // always done in one cycle
  
  assign push = di.ivalid && di.irdy;
  assign pop = di.ordy && di.ovalid;
  
   logic [0:PQ_CAPACITY+1] ki_lt_k_v;        // vector of comparator outputs
   kv_t [0:PQ_CAPACITY+1]  kv_v;  // vector of stored key-value pairs

   assign ki_lt_k_v[0] = 0;   
   assign ki_lt_k_v[PQ_CAPACITY+1] = 1;
   assign kv_v[0] = {KEY0, VAL0};
   assign kv_v[PQ_CAPACITY+1].key = KEYINF;
   assign kv_v[PQ_CAPICTY+1].value = 0;
   assign kvo = kv_v[1];

   assign empty = (kvo.key == KEYINF);
   assign full = (kv_v[PQ_CAPACITY].key != KEYINF);

   genvar i;
   generate for (i=1; i<=PQ_CAPACITY; i++) begin
       sr_pq_stage U_STAGE (
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
