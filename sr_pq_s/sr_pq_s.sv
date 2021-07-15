//-----------------------------------------------------------------------------
// Package Name   : sr_pq_s - shift-register-based PQ
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : July 13, 2021
//-----------------------------------------------------------------------------
// Description   : Shift-register-based PQ that can do enqueue dequeue,
//                 but no replace (simultaneous enqueue and dequeue)
// If enq and deq are asserted at the same time, the enqueue is ignored
// and the dequeue operation is performed
//-----------------------------------------------------------------------------

import pq_pkg::*;

module sr_pq_s (
  pq_if.dev di
);

logic clk, rst;
kv_t kvi, kvo;

assign kvi = di.kvi;
assign di.kvo = kvo;
assign clk = di.clk;
assign rst = di.rst;


  logic full, empty, enq, deq;
  assign enq = di.enq && !full;
  assign deq = di.deq && !empty;

  assign di.full = full;
  assign di.empty = empty;
  assign di.busy = 0;  // always done in one cycle


   logic [0:PQ_CAPACITY+1] ki_lt_k_v;        // vector of comparator outputs
   kv_t [0:PQ_CAPACITY+1]  kv_v;  // vector of stored key-value pairs

   assign ki_lt_k_v[0] = 0;
   assign ki_lt_k_v[PQ_CAPACITY+1] = 1;
   assign kv_v[0] = {KEY0, VAL0};
   assign kv_v[PQ_CAPACITY+1].key = KEYINF;
   assign kv_v[PQ_CAPACITY+1].value = 0;
   assign kvo = kv_v[1];

   assign empty = (kvo.key == KEYINF);
   assign full = (kv_v[PQ_CAPACITY].key != KEYINF);

   genvar i;
   generate for (i=1; i<=PQ_CAPACITY; i++) begin
       sr_pq_s_stage #(.STAGE(i)) U_STAGE (
          .clk, .rst, .enq, .deq,
          .ki_lt_kprev(ki_lt_k_v[i-1]),
          .ki_lt_knext(ki_lt_k_v[i+1]),
          .kvi, .kvprev(kv_v[i-1]), .kvnext(kv_v[i+1]),
          .kv(kv_v[i]),
          .ki_lt_k(ki_lt_k_v[i])
       );
    end
    endgenerate

endmodule: sr_pq_s
