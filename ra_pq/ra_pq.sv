//-----------------------------------------------------------------------------
// Module Name   : ra_pq_sort2
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : June 24, 2021
//-----------------------------------------------------------------------------
// Description   : "Register Array" min-priority queue patterened after
//                  Huang, Lim, and Cong, FPL 2014.  Note that
//                  this functions like a pipelined odd-even sort.
//-----------------------------------------------------------------------------

//`include "../pk_pkg.sv"
import pq_pkg::*;

module sr_pq (
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
    assign replace = di.enq && di.deq && !empty;

    assign di.full = full;
    assign di.empty = empty;
    assign di.busy = 0;  // always done in one cycle


    kv_t [1:PQ_CAPACITY]  kv_v, kv_t1, kv_t2, kv_n;  // vector of stored key-value pairs

   assign ki_lt_k_v[PQ_CAPACITY+1] = 1;
   assign kvo = kv_v[1];

   assign empty = (kvo.key == KEYNEGINF);
   assign full = (kv_v[PQ_CAPACITY].key != KEYINF);

   genvar i;

   generate for (i=2; i<=PQ_CAPACITY; i++) begin
       mux2(.sel(enq && !deq), .a(kv_v[i]), .b(kv_v[i-1]), .y(kv_t1[i]));
   end
endgenerate

   generate for (i=1; i<=PQ_CAPACITY; i+=2) begin
       ra_pq_sort2(.a(kv_v[i]), .b(kv_v[i+1]), .min(kv_t[i]), .max(kv_t[i+1]));
   end
   endgenerate

   generate for (i=2; i<=PQ_CAPACITY-1; i+=2) begin
       ra_pq_sort2(.a(kv_t2[i]), .b(kv_t2[i+1]), .min(kv_n[i]), .max(kv_n[i+1]));
   end
   endgenerate

   generate for (i=1; i=PQ_CAPACITY; i++) begin
       ra_pq_reg (.clk, .rst, kv_n[i], kv_v[i] );
   end
   endgenerate

   assign kv_n[0] = kv_t[0];

   assign kv_n[PQ_CAPACITY] = kv_t[PQ_CAPACITY];

   always_ff @(posedge clk)


endmodule: sr_pq
