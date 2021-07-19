//-----------------------------------------------------------------------------
// Interface Name  : pq_if
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : June 24, 2021
//-----------------------------------------------------------------------------
// Description   : Interface for PQ supporting only replace & dequue
//-----------------------------------------------------------------------------
//`include "../pq_pkg.sv"
import pq_pkg::*;

    interface pq_rd_if (input logic clk);
        logic rst;
        kv_t kvi;
        logic replace;
        logic full;
        logic busy;
        logic empty;
        kv_t kvo;
        logic deq;

        // used to implement a device
        modport dev (
            input clk, rst,
            input kvi, replace, deq,
            output full, busy, empty, kvo
        ) ;

        // use to connect to a device
        modport client (
            input clk, rst,
            output kvi, replace, deq,
            input full, busy, empty, kvo
        ) ;

        clocking cb @(posedge clk);
            default output #1;
            output  #1 rst, replace, kvi;
            input full, busy, empty;
            output #1 kvo;
            output  #1 deq;
        endclocking

        // use to connect to a testbench
        modport tb (
            clocking cb,
            output rst,
            output kvi, replace, deq,
            input full, busy, empty, kvo
        ) ;

    endinterface
