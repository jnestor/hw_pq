//-----------------------------------------------------------------------------
// Package Name   : heap_pq_wrapper - interface wrapper for top-level heap_pq
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : June 13, 2022
//-----------------------------------------------------------------------------
// Description   : Instantiates heap_pq with inteface through pushbuttons,
//                 pseven seg output
//-----------------------------------------------------------------------------

import pq_pkg::*;

module heap_pq_hw(
    input logic clk, rst,
    input [15:0] kvi_logic,
    input logic enq,
    output logic full,
    output logic busy,
    output logic empty,
    output [15:0] logic kvo_logic;
    input logic deq
    );

    kv_t kvi, kvo;

    assign kvi = kv_t'kvi_logic;
    assign kvi_logic = kvo;

    logic enq_pb, deq_pb, enq_deq_pb;

    // add code here to instantiate debouncers, single pulsers,
    // 7-segment controller

    pq_if U_PQ_IF (.clk);

    heap_pq U_HEAP_PQ(U_PQ_IF.dev);

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
