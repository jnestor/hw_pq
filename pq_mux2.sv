import pq_pkg::*;

module pq_mux2(
    input kv_t a, b,
    input s,
    output kv_t y
    );

    assign y = ( s ? b : a);

endmodule
