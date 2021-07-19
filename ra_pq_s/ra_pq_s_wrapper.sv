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

module ra_pq_s_wrapper(
    input logic clk, rst,
    input kv_t kvi,
    input logic replace,
    output logic full,
    output logic busy,
    output logic empty,
    output kv_t kvo,
    input logic deq
    );

    pq_rd_if U_PQ_IF_S (.clk);

    ra_pq_s U_RA_PQ_S(U_PQ_IF_S.dev);

   // is it really this easy?
    assign U_PQ_IF_S.rst = rst;
    assign U_PQ_IF_S.kvi = kvi;
    assign U_PQ_IF_S.replace = replace;
    assign full = U_PQ_IF_S.full;
    assign busy = U_PQ_IF_S.busy;
    assign empty = U_PQ_IF_S.empty;
    assign kvo = U_PQ_IF_S.kvo;
    assign U_PQ_IF_S.deq = deq;

endmodule
