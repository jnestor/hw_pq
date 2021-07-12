import pq_pkg::*;

module pq_key_compare(
    input kv_t a, b,
    output a_lt_b
    );

    assign a_lt_b = (a.key < b.key);

endmodule
