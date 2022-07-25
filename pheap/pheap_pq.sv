//-----------------------------------------------------------------------------
// Module Name   : pheap_pq
// Project       : pheap - pipelined heap priority queue implementation
// with standardized interface
//-----------------------------------------------------------------------------
// Author        : Ethan Miller (revised by John Nestor)
// Created       : May 2021
//-----------------------------------------------------------------------------
// Description   : Top-level module for pipelined heap priority queue
//-----------------------------------------------------------------------------

`include "pheapTypes.sv"

module pheap_pq (
  pq_if.dev di
);
    import pq_pkg::*;
    import pheapTypes::*;

    logic clk, rst;
    kv_t kvi, kvo;

    assign kvi = di.kvi;
    assign di.kvo = kvo;
    assign clk = di.clk;
    assign rst = di.rst;


    logic full, empty, enq, deq, replace, busy;
    assign enq = di.enq && !di.deq && !full;
    assign deq = di.deq && !di.enq && !empty;
    assign replace = di.enq && di.deq && !empty;

    assign di.full = full;
    assign di.empty = empty;
    assign di.busy = busy;  // always done in one cycle

    // provide a warning for PQ_CAPACITY
    initial begin
        assert  (PQ_CAPACITY == 2**LEVELS-1) else begin
            $warning("PQ_CAPACITY (%d) in pheap should be a power of 2 minus one", PQ_CAPACITY);
            $warning("Actual capacity is %d", 2**LEVELS-1);
        end
    end

//    (input logic clk, rst, valid, [31:0] priorityIn, pheapTypes::opcode_t toperation,
//    output logic rdy, [31:0] priorityOut, valid_out
//    );

    // operation & associated item for each level
    pheapTypes::opArray_t opArray [LEVELS:1];

    initial begin  // initialize for simulation only?
        for (int i = 1; i <= LEVELS; i++) begin
            opArray[i].levelOp = FREE;
            opArray[i].kv = KV_EMPTY;
        end
    end

    logic wenTop [LEVELS:1];     // write enables for memory (level modules)
    logic start [LEVELS:1];      // starts operation at each level when 1
    logic actives [LEVELS:1];    // indicate to memory (level module) if level is active
    logic shift_pos [LEVELS:1];  // initiate a shift at a level when asserted
    pheapTypes::done_t [LEVELS:1] done ;  // status for each level
    pheapTypes::entry_t [LEVELS:1] a;     // write data for subtree root at each level
    pheapTypes::entry_t [LEVELS:1] yTop ;  // read data fir current subtree root at each level
    pheapTypes::entry_t [LEVELS + 1:1] yBotL ;  // read data for current left child at each level
    pheapTypes::entry_t [LEVELS + 1:1] yBotR ;  // read data for current right child at each lvel
    kv_t outs [LEVELS:1];  // level output for each level
    //assign priorityOut = outs[1]; // top-level output
    assign yBotL[LEVELS + 1] = 'b0;  // level below bottom level has capacity=0
    assign yBotR[LEVELS + 1] = 'b0;  // level below bottom level has capacity=0

    genvar i;
    generate
        for (i = 1; i <= LEVELS; i = i + 1) begin: genHeap
            logic [i - 2:0] raddrTop ;
            logic [i - 1:0] raddrBot ;
            logic [i - 2:0] wraddrTop;
            logic [i - 2:0] startPos;
            logic [i - 1:0] endPos;

            if ((i != 1) && (i != LEVELS)) begin // instantiate middle levels
                level #(i) I_LEVEL(.clk, .topActive(actives[i]), .wenTop(wenTop[i]),
                .raddrTop(genHeap[i].raddrTop), .raddrBot(genHeap[i - 1].raddrBot),
                .wraddrTop(genHeap[i].wraddrTop), .aTop(a[i]), .yTop(yTop[i]),
                .yBotR(yBotR[i]), .yBotL(yBotL[i]));

                leq #(i) I_LEQ(.clk, .rst, .start(start[i]),
                .startPos(genHeap[i].startPos), .in(opArray[i].kv),
                .rTop(yTop[i]), .rBotL(yBotL[i + 1]), .rBotR(yBotR[i + 1]),
                .op(opArray[i].levelOp), .wenTop(wenTop[i]), .active(actives[i]),
                .done(done[i]), .raddrTop(genHeap[i].raddrTop),
                .raddrBot(genHeap[i].raddrBot), .wraddrTop(genHeap[i].wraddrTop),
                .endPos(genHeap[i].endPos), .out(outs[i]), .wData(a[i]));

                level_shifter #(i) I_SHIFTER(.clk, .rst, .shift(shift_pos[i - 1]),
                .pos_in(genHeap[i - 1].endPos), .pos_out(genHeap[i].startPos));
            end
            else if (i == 1) begin  // instantiate top level
                leq1 I_LEQ1(.clk, .rst, .start(start[i]), .in(opArray[i].kv),
                .rBotL(yBotL[i + 1]), .rBotR(yBotR[i + 1]),
                .op(opArray[i].levelOp), .active(actives[i]), .done(done[i]),
                .raddrBot(genHeap[i].raddrBot),
                .endPos(genHeap[i].endPos), .out(outs[i]), .head_out(kvo),
                .full, .empty);
            end else begin // instantiate bottom level
                level #(i) I_LEVEL(.clk, .topActive(actives[i]), .wenTop(wenTop[i]),
                .raddrTop(genHeap[i].raddrTop), .raddrBot(genHeap[i - 1].raddrBot),
                .wraddrTop(genHeap[i].wraddrTop), .aTop(a[i]), .yTop(yTop[i]),
                .yBotR(yBotR[i]), .yBotL(yBotL[i]));

                leq #(i) I_LEQ(.clk, .rst, .start(start[i]),
                .startPos(genHeap[i].startPos), .in(opArray[i].kv), .rTop(yTop[i]),
                .rBotL(yBotL[i + 1]), .rBotR(yBotR[i + 1]),
                .op(opArray[i].levelOp), .wenTop(wenTop[i]), .active(actives[i]),
                .done(done[i]), .raddrTop(genHeap[i].raddrTop),
                .raddrBot(genHeap[i].raddrBot), .wraddrTop(genHeap[i].wraddrTop),
                .endPos(genHeap[i].endPos), .out(outs[i]), .wData(a[i]));

                level_shifter #(i) I_SHIFTER(.clk, .rst, .shift(shift_pos[i - 1]),
                .pos_in(genHeap[i - 1].endPos), .pos_out(genHeap[i].startPos));
            end
        end

        task print_pheap();
            // print root at level 1
            $display("pheap at time %t", $time());
            print_entry(genHeap[1].genblk1.I_LEQ1.level_mem);
            $display("");
            print_entry(genHeap[2].genblk1.I_LEVEL.U_RAM.level_ram[0]);
            print_entry(genHeap[2].genblk1.I_LEVEL.U_RAM.level_ram[1]);
            $display("");
            print_entry(genHeap[3].genblk1.I_LEVEL.U_RAM.level_ram[0]);
            print_entry(genHeap[3].genblk1.I_LEVEL.U_RAM.level_ram[1]);
            print_entry(genHeap[3].genblk1.I_LEVEL.U_RAM.level_ram[2]);
            print_entry(genHeap[3].genblk1.I_LEVEL.U_RAM.level_ram[3]);
            $display("");
            print_entry(genHeap[4].genblk1.I_LEVEL.U_RAM.level_ram[0]);
            print_entry(genHeap[4].genblk1.I_LEVEL.U_RAM.level_ram[1]);
            print_entry(genHeap[4].genblk1.I_LEVEL.U_RAM.level_ram[2]);
            print_entry(genHeap[4].genblk1.I_LEVEL.U_RAM.level_ram[3]);
            print_entry(genHeap[4].genblk1.I_LEVEL.U_RAM.level_ram[4]);
            print_entry(genHeap[4].genblk1.I_LEVEL.U_RAM.level_ram[5]);
            print_entry(genHeap[4].genblk1.I_LEVEL.U_RAM.level_ram[6]);
            print_entry(genHeap[4].genblk1.I_LEVEL.U_RAM.level_ram[7]);
            $display("\n");
        endtask
    endgenerate

    assign busy = actives[1] || actives[2];
    //assign rdy = (done[1] == DONE && (done[2] == DONE || done[2] == NEXT_LEVEL));
    //assign valid_out = ((done[1] == DONE || done[1] == NEXT_LEVEL) && (opArray[1].levelOp == DEQ));


    always_ff @(posedge clk) begin
        if (enq) begin
            start[1] <= 1;
            opArray[1].kv <= kvi;
            opArray[1].levelOp <= LENQ;
        end
        else if (deq) begin
            start[1] <= 1;
            opArray[1].kv <= KV_EMPTY;
            opArray[1].levelOp = LDEQ;
        end
        else if (replace) begin
            start[1] <= 1;
            opArray[1].kv <= kvi;
            opArray[1].levelOp = LREPL;
        end
        else start[1] <= 0;


        //shift ops down
        for (int i = 1; i < LEVELS; i++) begin
            if (done[i] == NEXT_LEVEL) begin
                opArray[i + 1].kv <= outs[i];
                opArray[i + 1].levelOp <= opArray[i].levelOp;
                start[i + 1] <= 1;
            end else begin
                opArray[i + 1].kv <= KV_EMPTY;
                start[i + 1] <= 0;
            end
        end
    end

    always_comb begin
        for (int i = 1; i < LEVELS; i++) begin
            if (done[i] == NEXT_LEVEL) begin
                shift_pos[i] = 1;
            end else begin
                shift_pos[i] = 0;
            end
        end

    end



endmodule
