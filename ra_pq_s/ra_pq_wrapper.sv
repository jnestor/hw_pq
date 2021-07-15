//-----------------------------------------------------------------------------
// Package Name   : sr_pq_wrapper - interface wrapper for top-level sr_pq
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : July 13, 2021
//-----------------------------------------------------------------------------
// Description   : Instantiates sr_pq with inteface and connects to external
//                 pins for synthesis
//-----------------------------------------------------------------------------

import pq_pkg::*;

module ra_pq_wrapper(
    input logic clk, rst,
    input kv_t kvi,
    input logic enq,
    output logic full,
    output logic busy,
    output logic empty,
    output kv_t kvo,
    input logic deq
    );

    pq_if U_PQ_IF (.clk);

    ra_pq U_RA_PQ(U_PQ_IF.dev);

   // is it really this easy?
    assign U_PQ_IF.rst = rst;
    assign U_PQ_IF.kvi = kvi;
    assign U_PQ_IF.enq = enq;
    assign full = U_PQ_IF.full;
    assign busy = U_PQ_IF.busy;
    assign empty = U_PQ_IF.empty;
    assign kvo = U_PQ_IF.kvo;
    assign U_PQ_IF.deq = deq;

endmodule
