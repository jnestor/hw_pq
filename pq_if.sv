//-----------------------------------------------------------------------------
// Interface Name  : pq_if
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : June 24, 2021
//-----------------------------------------------------------------------------
// Description   : "Standard"  interface for hardware priority queues
//                 for use with multiple implmentations
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
            output  #1 rst, enq, kvi;
            input full, busy, empty;
            output #1 kvo;
            output  #1 deq;
        endclocking

        // use to connect to a testbench
        modport tb (
            clocking cb,
            output rst,
            output kvi, enq, deq,
            input full, busy, empty, kvo
        ) ;

    endinterface
