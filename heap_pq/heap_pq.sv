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
    logic [$clog2(PQ_CAPACITY)-1:0] heap_size, heap_size_next;

    assign empty = (heap_size == 0);

    assign full = (heap_size == PQ_CAPACITY);

    kv_t kv_ni, kv_ni_next, kv_nj, kv_njnext, kv_cmp, kv_min, kv_min_next;


    typedef enum logic [3:0] {IDLE, ENQ_WR, ENQ_RDP, ENQ_SW1, ENQ_SW2, DEQ_ST, DEQ_MVLAST, HPFY_ST, ..., DEQ_ST} states_t;

    states_t state, next;

    always_ff @(posedge clk) begin
        if (rst) begin
            heap_size <= 0;
            kv_ni <= {KEY0,VAL0};
            kv_nj <= {KEY0,VAL0};
            kv_min <= {KEY0,VAL0};
            state <= IDLE;
        end
        else begin
            heap_size <= heap_size_next;
            kv_ni <= kv_ni_next;
            kv_nj <= kv_nj_next;
            kv_min <= kv_min_next;
            state <= next;
        end

    end








endmodule: sr_pq
