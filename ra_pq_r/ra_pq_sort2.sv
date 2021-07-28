//-----------------------------------------------------------------------------
// Module Name   : ra_pq_sort2
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : June 24, 2021
//-----------------------------------------------------------------------------
// Description   : Sorts two key-value pairs by key
//-----------------------------------------------------------------------------

import pq_pkg::*;

module ra_pq_sort2(
    input kv_t a, b,
    output kv_t maxv, minv
    );

    always_comb begin
        if (a.key < b.key) begin
            maxv = b;
            minv = a;
        end else begin
            maxv = a;
            minv = b;
        end
    end

endmodule : ra_pq_sort2
