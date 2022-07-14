//-----------------------------------------------------------------------------
// Module Name   : leq
// Project       : pheap - pipelined heap priority queue implementation
//-----------------------------------------------------------------------------
// Author        : Ethan Miller (revised by John Nestor)
// Created       : May 2021
//-----------------------------------------------------------------------------
// Description   : This module controls an individual level of the pheap
// for all levels except level1, which uses the leq1 module
//-----------------------------------------------------------------------------

`include "pheapTypes.sv"

module leq
    import pq_pkg::*;
    import pheapTypes::*;

    #(parameter LEVEL=2)
    (
    input logic clk, rst, start,
    input logic [LEVEL - 2:0] startPos,
    input kv_t in,
    input pheapTypes::entry_t rTop, rBotL, rBotR,
    input pheapTypes::opcode_t op,
    output logic wenTop, active,
    output pheapTypes::done_t done,
    output logic [LEVEL - 2:0] raddrTop, wraddrTop,
    output logic [LEVEL - 1:0] raddrBot, endPos,
    output kv_t out,
    output pheapTypes::entry_t wData  // write to level memory
);


function logic [LEVEL-1:0] left_child(input logic [LEVEL-2:0] n)
    return {n, 1'b0}
endfunction

function logic [LEVEL-1:0] right_child(input logic [LEVEL-2:0] n)
    return {n, 1'b1}
endfunction

// comparison functions are designed so that inactive nodes
// are always "less than" active nodes

function logic cmp_kv_entry_gt(
    input kv_t kv,
    input entry_t e
    );
    if (!e.active) return 1'b1;
    else return cmp_kv_entry_gt(kv, e.kv);
endfunction

function logic cmp_entry_entry_gt(
    input entry_t e1, e2
    );
    if (!e1.active && !e2.active) return false;
    else if (e1.active && !e2.active) return true;
    else if (e1.active && e2.active) return cmp__kv_gt(e1.kv, e2.kv);
    else return 1'b0;
endfunction

typedef enum logic {READ_MEM, SET_OUT} states_t;
states_t state, next;

kv_t in_reg;

logic in_gt_L, in_gt_R, L_gt_R;

assign in_gt_L = cmp_kv_entry_gt(in_reg, rBotL);
assign in_gt_R = cmp_kv_entry_gt(in_reg, rBotR);
assign L_gt_r = cmp_entry_entry_gt(rBotL, rBotR);

always_ff @(posedge clk) begin
    if (rst) state <= READ_MEM;
    else state <= next;

    if (state == READ_MEM && start)
        in_reg <= in;
end

always_comb begin
    done = DONE;
    endPos = 'b0;
    wraddrTop = startPos;
    wenTop = 1'b0;
    raddrTop = startPos;
    raddrBot = {startPos, 1'b0};
    out = KV_EMPTY;
    wData = ENTRY_EMPTY;

    case (state)
        READ_MEM: begin  // read top from current level, children from next level
            if (start) begin
                active = 1;
                done = WAIT;
                next = SET_OUT;
            end else begin
                next = READ_MEM;
                active = 0;
            end
        end

        SET_OUT: begin
            next = READ_MEM;
            active = 1;
            if (op == LEQ) begin
                if (~rTop.active) begin
                    wData.active = 1'b1;
                    wData.capacity = rTop.capacity - 1;
                    wData.kv = in_reg;
                    wenTop = 1'b1;
                    done = DONE;
                end else begin
                    if (rTop.kv.key < in_reg.key) begin
                        out = rTop.kv;
                        wData.active = 1'b1;
                        wData.capacity = (rTop.capacity == 0) ? 0 : rTop.capacity - 1;
                        wData.kv = in_reg;
                        wenTop = 1'b1;
                    end else begin out = in_reg;
                        wData.active = 1'b1;
                        wData.capacity = (rTop.capacity == 0) ? 0 : rTop.capacity - 1;
                        wData.kv = rTop.kv;
                        wenTop = 1'b1;
                    end
                    if (rBotL.capacity != 0 && rBotR.capacity != 0)
                        endPos = (rBotL.kv.key <= rBotR.kv.key) ? {startPos, 1'b0} : {startPos, 1'b1};
                    else if (rBotL.capacity != 0)
                        endPos = {startPos, 1'b0};
                    else
                        endPos = {startPos, 1'b1};
                    done = NEXT_LEVEL;
                end
            end
            else if (op == DEQ) begin
                out = rTop.kv;
                wData.capacity = rTop.capacity + 1;
                wenTop = 1'b1;
                if (!cmp_kv_entry_gt(in,rBotL) && !(cmp_kv_entry_gt(in,rBotR)))
                    done = DONE;
                    wData.kv = KV_EMPTY;
                    wData.active = 1'b0;
                end else if (rBotL.active && rBotR.active) begin
                    wData.kv = (rBotL.kv.key >= rBotR.kv.key) ? rBotL.kv : rBotR.kv;
                    wData.active = 1'b1;
                    if (rBotL.kv.key >= rBotR.kv.key) endPos = left_child(startPos);
                    else endPos = right_child(startPos);
                    done = NEXT_LEVEL;
                end else if (rBotL.active) begin
                    wData.kv = rBotL.kv;
                    wData.active = 1'b1;
                    endPos = left_child(startPos);
                    done = NEXT_LEVEL;
                end else begin
                    wData.kv = rBotR.kv;
                    wData.active = 1'b1;
                    endPos = right_child(startPos);
                    done = NEXT_LEVEL;
                end
            end
            else if (op == ENQ_DEQ) begin
                // the top will always be overwritten here, but if
                // he new value is < either of the the chldren
                // we want to write the biggest child as the new top
                // and pass ENQ_DEQ to next level
                wData.active = 1;
                wenTop = 1;
                next = READ_MEM;
                active = 1;
                if (in_gt_L && in_gt_R)) begin  // heap property satisfied
                    wData.kv = in_reg;          // just write in top
                    done = DONE;
                end
                else if (!in_gt_L && !in_gt_R) begin
                    if (L_gt_R) begin
                        wData.kv = rBotL;
                        endPos = left_child(startPos);
                    end
                    else begin
                        wData.kv = rBotR;
                        endPos = right_child(startPos);
                    end
                    out = in_reg;
                    done = NEXT_LEVEL;
                end
                else if (in_gt_L) begin
                    wData.kv = rBotL;
                    endPos = left_child(startPos);
                    out = in_reg;
                    done = NEXT_LEVEL;
                end
                else begin // in_gt_R
                    wData.kv = rBotR;
                    endPos = right_child(startPos);
                    out = in_reg;
                    done = NEXT_LEVEL;
                end
            end
        end
    endcase
end

endmodule
