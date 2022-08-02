//-----------------------------------------------------------------------------
// Module Name   : ra_pq_s
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : June 24, 2021
//-----------------------------------------------------------------------------
// Description   : "Register Array" min-priority queue patterened after
//                  Huang, Lim, and Cong, FPL 2014.  Note that
//                  this functions like a pipelined odd-even sort.
// This version *only* performs replace & dequeue as described
// in the HLC paper
//-----------------------------------------------------------------------------

//`include "../pk_pkg.sv"
import pq_pkg::*;

module ra_pq_s (
    pq_rd_if.dev di
    );

    logic clk, rst;
    kv_t kvi, kvo;

    assign kvi = di.kvi;
    assign di.kvo = kvo;
    assign clk = di.clk;
    assign rst = di.rst;


    logic full, empty, replace, deq;
    assign replace = di.replace;
    assign deq = di.deq;

    assign di.full = full;
    assign di.empty = empty;
    assign di.busy = 0;  // always done in one cycle

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

    // a note about "empty":  Since the queue is initialized with all dummy values
    // it technically isn't empty although this is a little counterintuitive
    assign empty = (kvo.key == KEYINF);  // true when the queue is full of "dummy" KEYINF values

    assign full = (kvo.key != KEYNEGINF);  // true when all iniital "dummy" KEY0 values have been replaced

    genvar i;

    ra_pq_mux3 U_MUX3 (.sel({replace,deq}), .d0(kv_v[1]), .d1({KEYINF,VAL0}), .d2(kvi), .y(kv_t1[1]));

    // got rid of the first stage of mux2's here
    assign kv_t1[2:RA_CAPACITY] = kv_v[2:RA_CAPACITY];

    generate for (i=1; i<=RA_CAPACITY; i+=2) begin
        ra_pq_sort2 U_SORTODD (.a(kv_t1[i]), .b(kv_t1[i+1]), .minv(kv_t2[i]), .maxv(kv_t2[i+1]));
    end
    endgenerate

    generate for (i=2; i<=RA_CAPACITY-1; i+=2) begin
        ra_pq_sort2 U_SORTEVEN (.a(kv_t2[i]), .b(kv_t2[i+1]), .minv(kv_n[i]), .maxv(kv_n[i+1]));
    end
    endgenerate

    generate for (i=1; i<=RA_CAPACITY; i++) begin
        ra_pq_reg U_REG (.clk, .rst, .d(kv_n[i]), .q(kv_v[i]) );
    end
    endgenerate

    assign kv_n[1] = kv_t2[1];

    assign kv_n[RA_CAPACITY] = kv_t2[RA_CAPACITY];

endmodule: ra_pq_s
