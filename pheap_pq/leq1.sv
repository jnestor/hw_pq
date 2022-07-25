//-----------------------------------------------------------------------------
// Module Name   : leq1 - level manager for top level
// Project       : pheap - pipelined heap priority queue implementation
//-----------------------------------------------------------------------------
// Author        : Ethan Miller (revised by John Nestor)
// Created       : May 2021
//-----------------------------------------------------------------------------
// Description   : This module controls the top level of the pHeap
//-----------------------------------------------------------------------------

`include "pheapTypes.sv"

module leq1
    import pq_pkg::*;
    import pheapTypes::*;
    (
    input logic clk, rst, start,
    input kv_t in,
    input pheapTypes::entry_t rBotL, rBotR,
    input pheapTypes::opcode_t op,
    output logic active,
    output pheapTypes::done_t done,
    output logic raddrBot, endPos,  // level 1 node index only 1 bit
    output kv_t out, head_out,
    output logic full, empty
);

logic wenTop;
const logic [LEVELS-1:0] MAX_CAPACITY = '1;

pheapTypes::entry_t rTop, wData;
pheapTypes::entry_t level_mem = {32'h00000000, MAX_CAPACITY, 1'b0};

assign rTop = level_mem;
assign head_out = level_mem.kv;  // always output root node

assign full = (level_mem.capacity==0);
assign empty = (level_mem.capacity==MAX_CAPACITY);

const logic left_child = 1'b0;
const logic right_child = 1'b1;

logic in_gt_T, in_gt_L, in_gt_R, L_gt_R;

assign in_gt_T = cmp_kv_entry_gt(in, rTop);
assign in_gt_L = cmp_kv_entry_gt(in, rBotL);
assign in_gt_R = cmp_kv_entry_gt(in, rBotR);
assign L_gt_R = cmp_entry_entry_gt(rBotL, rBotR);

// storage for root node on level 1
always_ff @(posedge clk) begin
    if (rst) begin
        level_mem <= {32'h00000000, MAX_CAPACITY, 1'b0};
    end
    else if (wenTop) begin
        level_mem <= wData;
    end
end

typedef enum logic {READ_MEM, SET_OUT} states_t;
states_t state, next;

always_ff @(posedge clk) begin
    if (rst) state <= READ_MEM;
    else state <= next;
end

always_comb begin
    done = DONE;
    endPos = 'b0;
    wenTop = 1'b0;
    raddrBot = 1'b0;
    out = KV_EMPTY;
    wData = ENTRY_EMPTY;
    active = 0;

    case (state)
        READ_MEM: begin  // read children from next level
            if (start) begin
                active = 1;
                done = WAIT;
                next = SET_OUT;
            end else begin
                active = 0;
                next = READ_MEM;
            end
        end

        SET_OUT: begin
            next = READ_MEM;
            active = 1;
            if (op == LENQ) begin
                if (!rTop.active) begin
                    wData.active = 1'b1;
                    wData.capacity = rTop.capacity - 1;
                    wData.kv = in; //gotta fix this - write the prioritity, decremented capacity and active
                    wenTop = 1'b1;
                    done = DONE;
                end
                else begin
                    if (in_gt_T) begin //also fix this - if currentpriority less than priority to be written
                        out = rTop.kv; //take a look at this logic: idk if legal
                        wData.active = 1'b1;
                        wData.capacity = (rTop.capacity == 0) ? 0 : rTop.capacity - 1;
                        wData.kv = in;
                        wenTop = 1'b1;
                    end else begin out = in;
                        wData.active = 1'b1;
                        wData.capacity = (rTop.capacity == 0) ? 0 : rTop.capacity - 1;
                        wData.kv = rTop.kv;
                        wenTop = 1'b1;
                    end
                    // chose which subtree to push down to
                    // the L_gt_R test is not in the B&L paper
                    if (!rBotR.active) endPos = right_child;
                    else if (!rBotL.active) endPos = left_child;
                    else if ((rBotL.capacity != 0) && (rBotR.capacity != 0))
                        endPos = (!L_gt_R) ? left_child : right_child;
                    else if (rBotL.capacity != 0)
                        endPos = left_child;
                    else
                        endPos = right_child;
                    done = NEXT_LEVEL;
                end
            end else if (op == LDEQ) begin
                // if there at least one active child, replace
                // rTop with the child with the largest value
                out = rTop.kv;
                wData.capacity = rTop.capacity + 1;
                wenTop = 1'b1;
                if (!rBotL.active && !rBotR.active) begin
                    done = DONE;
                    wData.kv = {KEY0,VAL0};  // will ned to change for min-pq
                    wData.active = 1'b0;
                end
                else if (L_gt_R) begin // compare accoutns for inactive children
                    wData.kv = rBotL.kv;
                    wData.active = 1'b1;
                    endPos = left_child;
                    done = NEXT_LEVEL;
                end
                else begin
                    wData.kv = rBotR.kv;
                    wData.active = 1'b1;
                    endPos = right_child;
                    done = NEXT_LEVEL;
                end
            end
            else if (op == LREPL) begin
                // the top will always be overwritten here, but if
                // the new value is < either of the the chldren
                // we want to write the biggest child as the new top
                // and pass ENQ_DEQ to next level
                wData.active = 1;
                wenTop = 1;
                next = READ_MEM;
                if (in_gt_L && in_gt_R) begin  // heap property satisfied
                    wData.kv = in;          // just write in top
                    done = DONE;
                end
                else if (!in_gt_L && !in_gt_R) begin
                    if (L_gt_R) begin
                        wData.kv = rBotL.kv;
                        endPos = left_child;
                    end
                    else begin
                        wData.kv = rBotR.kv;
                        endPos = right_child;
                    end
                    out = in;
                    done = NEXT_LEVEL;
                end
                else if (!in_gt_L) begin
                    wData.kv = rBotL.kv;
                    endPos = left_child;
                    out = in;
                    done = NEXT_LEVEL;
                end
                else begin // !in_gt_R
                    wData.kv = rBotR.kv;
                    endPos = right_child;
                    out = in;
                    done = NEXT_LEVEL;
                end
            end
        end
    endcase
end

endmodule
