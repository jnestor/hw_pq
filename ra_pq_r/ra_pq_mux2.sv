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

module ra_pq_mux2 (
    input kv_t  d0, d1,
    input logic sel,
    output kv_t y
    );

//    assign y = ((sel==1) ? d1 : d0);
    always_comb begin
        if (sel == 0) y = d0;
        else y = d1;
    end

endmodule: ra_pq_mux2
