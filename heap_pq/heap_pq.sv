// Heap implementation of a priority queue
//
//

//`include "../pk_pkg.sv"
import pq_pkg::*;

module heap_pq (
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

    assign di.full = full;
    assign di.empty = empty;
    assign di.busy = 0;  // always done in one cycle


    // heap array - PQ_CAPACITY must be a power of 2 (minus 1)
    kv_t heap [1:PQ_CAPACITY];  // vector of stored key-value pairs

    // index of last item in heap
    logic [$clog2(PQ_CAPACITY)-1:0] last;

    assign empty = (last == 0);

    assign full = (last == PQ_CAPACITY);








endmodule: sr_pq
