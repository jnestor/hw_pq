// Heap implementation of a priority queue
//
//

import pq_pkg::*;

module heap_pq (
    pq_if.dev di
    );

    logic clk, rst;
    kv_t kvi, kvo;
    logic idle;

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
    assign di.busy = !idle;  // always done in one cycle

    // index of last item in heap
    logic [$clog2(PQ_CAPACITY)-1:0] heap_size, heap_size_next;

    assign empty = (heap_size == 0);

    assign full = (heap_size == PQ_CAPACITY);

    logic [$clog2(PQ_CAPACITY)-1:0] ni, ni_next, nj, nj_next, nmin, nmin_next;

    kv_t i_kv, i_kv_next, j_kv, j_kv_next, min_kv, min_kv_next;

    // memory signals
    logic [KEY_WIDTH+VAL_WIDTH-1:0] din, dout;
    logic [$clog2(PQ_CAPACITY)-1:0] addr;
    logic we;
    logic aov;  // overflow bit when calculating left, right children

    kv_t din_kv, dout_kv;

    assign din = din_kv;
    assign dout_kv = kv_t'(dout);

    // memory (BRAM) for heap storage
    mem_swsr #(.W(KEY_WIDTH+VAL_WIDTH), .D(PQ_CAPACITY+1)) U_HEAPMEM (
        .clk, .we, .addr, .din, .dout
    );

    typedef enum logic [3:0] {
        IDLE, ENQ_ST, ENQ_RDP, ENQ_SWP, ENQ_SWP2, DEQ_ST, DEQ_ST2,
        HPFY_ST, HPFY_RDL, HPFY_RDR, HPFY_SWP, HPFY_SWP2, ENQ_DEQ_ST
    } states_t;

    states_t state, next;

    function [$clog2(PQ_CAPACITY):0] left(logic [$clog2(PQ_CAPACITY)-1:0] ni);
        left = ni << 1;
    endfunction

    function [$clog2(PQ_CAPACITY):0] right(logic [$clog2(PQ_CAPACITY)-1:0] ni);
        right = (ni << 1) | 1;
    endfunction

    function [$clog2(PQ_CAPACITY)-1:0] parent(logic [$clog2(PQ_CAPACITY)-1:0] ni);
        parent = ni >> 1;
    endfunction


    always_ff @(posedge clk) begin
        if (rst) begin
            heap_size <= 0;
            ni <= 1;
            nj <= 0;      // set initially to error value
            nmin <= 0;
            i_kv <= {KEY0,VAL0};
            j_kv <= {KEY0,VAL0};
            min_kv <= {KEY0,VAL0};
            state <= IDLE;
        end
        else begin
            state <= next;
            heap_size <= heap_size_next;
            ni <= ni_next;
            nj <= nj_next;
            nmin <= nmin_next;
            i_kv <= i_kv_next;
            j_kv <= j_kv_next;
            min_kv <= min_kv_next;
        end
    end

    // output register - load when we write the root of the heap
    always_ff @(posedge clk) begin
        if (rst) kvo <= {KEY0,VAL0};
        else if (we && (addr==1)) kvo <= din_kv;
    end

    always_comb begin
        heap_size_next = heap_size;
        ni_next = ni;
        nj_next = nj;
        nmin_next = nmin;
        i_kv_next = i_kv;
        j_kv_next = j_kv;
        min_kv_next = min_kv;
        addr = 0;
        din_kv = {KEY0,VAL0};
        we = 0;
        idle = 0;
        next = IDLE;  // should not happen
        case (state)
            IDLE: begin
                idle = 1;
                if (replace) next = ENQ_DEQ_ST;
                else if (enq && !full) next = ENQ_ST;
                else if (deq && !empty) next = DEQ_ST;
                else next = IDLE;
            end
            ENQ_ST: begin
                heap_size_next = heap_size + 1;
                ni_next = heap_size_next;
                i_kv_next = kvi;
                din_kv = kvi;
                addr = heap_size_next;
                we = 1;
                if (ni_next==1) next = IDLE;
                else next = ENQ_RDP;
            end
            ENQ_RDP: begin
                if (ni==1) next = IDLE;  // done!
                else begin
                    nj_next = parent(ni);
                    addr = nj_next;      // read parent from RAM
                    next = ENQ_SWP;
                end
            end
            ENQ_SWP: begin
                if (dout_kv.key < i_kv.key) next = IDLE;  // heap property satisfied
                else begin
                    j_kv_next = dout;
                    addr = parent(ni);
                    din_kv = i_kv;
                    we = 1;
                    next = ENQ_SWP2;
                end
            end
            ENQ_SWP2: begin
                addr = ni;
                din_kv = j_kv;
                we = 1;
                ni_next = parent(ni);
                next = ENQ_RDP;
            end
            ENQ_DEQ_ST: begin
                addr = 1;
                ni_next = 1;
                we = 1;         // write kvi into RAM
                din_kv = kvi;
                i_kv_next = kvi;
                min_kv_next = kvi;  // prep for heapify
                nmin_next = 1;
                next = HPFY_ST;
            end
            DEQ_ST: begin
                addr = heap_size;  // read last item in heap
                next = DEQ_ST2;
                heap_size_next = heap_size - 1;
            end
            DEQ_ST2: begin
                addr = 1;       // write it into first item in heap
                we = 1;
                din_kv = dout_kv;
                i_kv_next = dout_kv;    // move to ni for heapify
                ni_next = 1;
                min_kv_next = dout_kv;  // set min to ni for heapify
                nmin_next = 1;
                next = HPFY_ST;
            end
            HPFY_ST: begin
                {aov,addr} = left(ni);  // set up to read left child
                if ({aov,addr} > heap_size) next = IDLE;
                else next = HPFY_RDL;
            end
            HPFY_RDL: begin
                if (dout_kv.key < min_kv.key) begin
                    nmin_next = left(ni);
                    min_kv_next = dout_kv;
                end
                {aov,addr} = right(ni);
                if ({aov,addr} > heap_size) next = HPFY_SWP;
                else next = HPFY_RDR;
            end
            HPFY_RDR: begin
                if (dout_kv.key < min_kv.key) begin
                    nmin_next = right(ni);
                    min_kv_next = dout_kv;
                end
                next = HPFY_SWP;
            end
            HPFY_SWP: begin
                if (nmin == ni) next = IDLE;
                else begin
                    addr = ni;
                    din_kv = min_kv;
                    we = 1;
                    next = HPFY_SWP2;
                end
            end
            HPFY_SWP2: begin
                addr = nmin;
                din_kv = i_kv;
                min_kv_next = i_kv; // set up for next comparison
                we = 1;
                ni_next = nmin;
                i_kv_next = i_kv;
                next = HPFY_ST;
            end
        endcase
    end

endmodule
