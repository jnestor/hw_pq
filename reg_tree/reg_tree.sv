//-----------------------------------------------------------------------------
// Module Name   : reg_tree
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : June 14, 2022
//-----------------------------------------------------------------------------
// Description   : "Register Tree" min-priority queue patterened after
//                  Huang, Lim, and Cong, FPL 2014.
//-----------------------------------------------------------------------------

import pq_pkg::*;


module reg_tree_pq (
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

    parameter NUM_LEVELS=$clog2(PQ_CAPACITY+1);

    generate
        genvar i, lvl, lvl_width;

        for (lvl=0, lvl <= NUM_LEVELS; lvl++) begin
            if (lvl==0) begin


            end
            else if lvl


        end

    endgenerate

endmodule
