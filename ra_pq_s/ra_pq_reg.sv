//-----------------------------------------------------------------------------
// Module Name   : ra_mux2
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor  <nestorj@lafayette.edu>
// Created       : June 29, 2021
//-----------------------------------------------------------------------------
// Description   : 2-1 mux for key-value data items
//-----------------------------------------------------------------------------
import pq_pkg::*;

module ra_pq_reg (
    input logic clk, rst,
    input  kv_t  d,
    output kv_t q
    );

    always_ff @(posedge clk) begin
        if (rst) q <= {KEYNEGINF,VAL0};
        else q <= d;
    end


endmodule: ra_pq_reg
