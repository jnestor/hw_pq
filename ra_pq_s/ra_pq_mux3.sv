//-----------------------------------------------------------------------------
// Module Name   : ra_mux3
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor  <nestorj@lafayette.edu>
// Created       : June 29, 2021
//-----------------------------------------------------------------------------
// Description   : 3-1 mux for key-value data items note
//                 y=d2 when sel == 2 OR 3
//-----------------------------------------------------------------------------
import pq_pkg::*;

module ra_pq_mux3 (
    input kv_t  d0, d1, d2,
    input logic [1:0] sel,
    output kv_t y
    );

    always_comb begin
        case (sel)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            2'b11: y = d2;
        endcase
    end

endmodule: ra_pq_mux3
