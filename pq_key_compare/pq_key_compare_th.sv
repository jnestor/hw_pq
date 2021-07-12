//-----------------------------------------------------------------------------
// Module Name   : pq_key_compare_th - compatator timing harness
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : July 8, 2021
//-----------------------------------------------------------------------------
// Description   : Timing harness for doing timing measurements on comparator
//-----------------------------------------------------------------------------

import pq_pkg::*;

module pq_key_compare_th(
    input logic clk,
    input kv_t a_in, b_in,
    output logic a_lt_b_r
    );

    kv_t a_r, b_r;
    logic a_lt_b;

    always_ff @(posedge clk) begin
        a_r <= a_in;
        b_r <= b_in;
        a_lt_b_r <= a_lt_b;
    end

    pq_key_compare U_COMPARE(.a(a_r), .b(b_r), .a_lt_b);

endmodule
