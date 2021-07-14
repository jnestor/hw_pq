//-----------------------------------------------------------------------------
// Module Name   : pq_key_compare - comparator for PQ
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : July 8, 2021
//-----------------------------------------------------------------------------
// Description   : Compare two keys based on width parameter
// set in pk_pkg
//-----------------------------------------------------------------------------

import pq_pkg::*;

module pq_key_compare(
    input kv_t a, b,
    output logic a_lt_b
    );

    assign a_lt_b = (a.key < b.key);

endmodule
