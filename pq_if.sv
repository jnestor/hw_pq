//-----------------------------------------------------------------------------
// Package Name   : pq_pkg
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : June 15, 2021
//-----------------------------------------------------------------------------
// Description   : Package defining data types and standard interface
//                 for hardware priority queues.  This package will be
//                 used in several different HWPQ implementations
//-----------------------------------------------------------------------------
//`include "../pq_pkg.sv"
import pq_pkg::*;

    interface pq_if (input logic clk);
        logic rst;
        kv_t kvi;
        logic enq;
        logic full;
        logic busy;
        logic empty;
        kv_t kvo;
        logic deq;

        kv_t odata;

        // used to implement a device
        modport dev (
            input clk, rst,
            input kvi, enq, deq,
            output full, busy, empty, kvo
        ) ;

        // use to connect to a device
        modport client (
            input clk, rst,
            output kvi, enq, deq,
            input full, busy, empty, kvo
        ) ;

        clocking cb @(posedge clk);
            default output #1;
            output  rst, enq, kvi;
            input full, busy, empty;
            output kvo;
            output  deq;
        endclocking

        // use to connect to a testbench
        modport tb (
            clocking cb,
            output rst,
            output kvi, enq, deq,
            input full, busy, empty, kvo
        ) ;

    endinterface
