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

module ra_pq (
    pq_if.dev di
    );

    logic clk, rst;
    kv_t kvi, kvo;
    logic replace;

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

    assign kvo = kv_v[1];

    assign empty = (kvo.key == KEYINF);
    assign full = (kv_v[PQ_CAPACITY].key != KEYINF);

    genvar i;

    ra_pq_mux3 U_MUX3 (.sel({enq,deq}), .d0(kv_v[1]), .d1({KEYINF,VAL0}), .d2(kvi), .y(kv_t1[1]));

    logic insert;
    assign insert = (enq && !deq);

    generate for (i=2; i<=PQ_CAPACITY; i++) begin
        ra_pq_mux2 U_MUX2(.sel(insert), .d0(kv_v[i]), .d1(kv_v[i-1]), .y(kv_t1[i]));
    end
    endgenerate

    generate for (i=1; i<=PQ_CAPACITY; i+=2) begin
        ra_pq_sort2 U_SORTODD (.a(kv_t1[i]), .b(kv_t1[i+1]), .minv(kv_t2[i]), .maxv(kv_t2[i+1]));
    end
    endgenerate

    generate for (i=2; i<=PQ_CAPACITY-1; i+=2) begin
        ra_pq_sort2 U_SORTEVEN (.a(kv_t2[i]), .b(kv_t2[i+1]), .minv(kv_n[i]), .maxv(kv_n[i+1]));
    end
    endgenerate

    generate for (i=1; i<=PQ_CAPACITY; i++) begin
        ra_pq_reg U_REG (.clk, .rst, .d(kv_n[i]), .q(kv_v[i]) );
    end
    endgenerate

    assign kv_n[1] = kv_t2[1];

    assign kv_n[PQ_CAPACITY] = kv_t2[PQ_CAPACITY];

endmodule: ra_pq
