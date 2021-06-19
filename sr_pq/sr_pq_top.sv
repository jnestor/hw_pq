//-----------------------------------------------------------------------------
// Package Name   : sr_pq_top
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : June 18, 2021
//-----------------------------------------------------------------------------
// Description   : Top-level simulation file for sr_pq
//                 using interface
//-----------------------------------------------------------------------------

//`include "../pk_pkg.sv"
import pq_pkg::*;

module sr_pq_top;

    logic clk;

    always begin
        clk = 0; #5;
        clk = 1; #5;
    end

    pq_if PQ_IF(clk);

    sr_pq DUV(PQ_IF.dev);

    sr_pq_tb TB(PQ_IF.tb);

endmodule
