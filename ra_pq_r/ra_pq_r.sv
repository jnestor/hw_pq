//-----------------------------------------------------------------------------
// Module Name   : ra_pq_sort2
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : June 24, 2021
//-----------------------------------------------------------------------------
// Description   : Modified "Register Array" min-priority queue patterened after
//                 Huang, Lim, and Cong, FPL 2014 but with only a single
//                 stage of sorting.  The tradeoff is that enqueue, dequeue,
//                 & replace operations can only be performed every other
//                clock cycle.
//                On "odd" clock cycles, enqueue, dequeue, and the first
//                stage of sorting take place.  On "even" clock cycles
//                the second stage of sorting takes place using the same
//                sort2 modules
// An advantage of this approach is that the first stage of multiplexers
// can be used for both enqueue during the odd cycle and shifting
// during the even cycle.
//-----------------------------------------------------------------------------

//`include "../pk_pkg.sv"
import pq_pkg::*;

module ra_pq_r (
    pq_if.dev di
    );

    logic clk, rst;
    kv_t kvi, kvo;
    logic replace;
    logic even;

    always_ff @(posedge clk) begin
        if (rst) even <= 0;
        else even <= !even;
    end

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
    assign di.busy = even;  // can't enqueue or dequeue on even cycles

    // number of stages must be even!
    parameter RA_CAPACITY = ((PQ_CAPACITY[0] == 0) ? PQ_CAPACITY : PQ_CAPACITY+1);

    // provide a warning for PQ_CAPACITY
    initial begin
        assert  (PQ_CAPACITY == RA_CAPACITY) else begin
            $warning("PQ_CAPACITY (%d) in ra_pq should be EVEN", PQ_CAPACITY);
            $warning("RA_CAPACITY increased to %d", RA_CAPACITY);
        end
    end


    kv_t [1:RA_CAPACITY]  kv_v, kv_t1, kv_t2, kv_n;  // vector of stored key-value pairs

    assign kvo = kv_v[1];

    assign empty = (kvo.key == KEYINF);
    assign full = (kv_v[RA_CAPACITY].key != KEYINF);

    genvar i;

    ra_pq_mux3 U_MUX3 (.sel({enq|replace,deq}), .d0(kv_v[1]), .d1({KEYINF,VAL0}), .d2(kvi), .y(kv_t1[1]));

    logic insert;
    assign insert = (enq && !deq)&&!even || even;

    generate for (i=2; i<=RA_CAPACITY; i++) begin
        ra_pq_mux2 U_MUX2(.sel(insert), .d0(kv_v[i]), .d1(kv_v[i-1]), .y(kv_t1[i]));
    end
    endgenerate

    generate for (i=1; i<=RA_CAPACITY; i+=2) begin
        ra_pq_sort2 U_SORTODD (.a(kv_t1[i]), .b(kv_t1[i+1]), .minv(kv_t2[i]), .maxv(kv_t2[i+1]));
    end
    endgenerate

    ra_pq_mux2 U_SRTMUX1 (.sel(even), .d0(kv_t2[1]), .d1(kv_t1[1]), .y(kv_n[1]));

    generate for (i=2; i<=RA_CAPACITY-1; i++) begin
        ra_pq_mux2 U_SRTMUX (.sel(even), .d0(kv_t2[i]), .d1(kv_t2[i+1]), .y(kv_n[i]));
    end
    endgenerate

    ra_pq_mux2 U_SRTMUXN (.sel(even), .d0(kv_t2[RA_CAPACITY]), .d1(kv_v[RA_CAPACITY]), .y(kv_n[RA_CAPACITY]));

    generate for (i=1; i<=RA_CAPACITY; i++) begin
        ra_pq_reg U_REG (.clk, .rst, .d(kv_n[i]), .q(kv_v[i]) );
    end
    endgenerate

endmodule: ra_pq_r
