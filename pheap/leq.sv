//-----------------------------------------------------------------------------
// Module Name   : leq -level manager
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

logic [LEVEL-1:0] left_child, right_child;
assign left_child  = {startPos, 1'b0};
assign right_child = {startPos, 1'b1};

// max capacity of node at thsi level and subtree
const logic [LEVELS-LEVEL:0] LEVEL_MAX_CAPACITY = '1;

typedef enum logic {READ_MEM, SET_OUT} states_t;
states_t state, next;

kv_t in_reg;

logic in_gt_L, in_gt_T, in_gt_R, L_gt_R;

assign in_gt_T = cmp_kv_entry_gt(in_reg, rTop);
assign in_gt_L = cmp_kv_entry_gt(in_reg, rBotL);
assign in_gt_R = cmp_kv_entry_gt(in_reg, rBotR);
assign L_gt_R = cmp_entry_entry_gt(rBotL, rBotR);

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
    raddrBot = left_child;
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
            if (op == LENQ) begin
                if (!rTop.active) begin
                    wData.active = 1'b1;
                    // this bit of obtusenss eliminates the need to initialize RAM with capacity values
                    // if (!rTop.active) begin
                    //     wData.capacity = (2**(LEVELS-LEVEL+1))-1;
                    //     $display("initializing capacity LEVEL %d at %d",LEVEL,wData.capacity);
                    // end
                    // else
                    wData.capacity = LEVEL_MAX_CAPACITY - 1;
                    wData.kv = in_reg;
                    wenTop = 1'b1;
                    done = DONE;
                end else begin
                    if (in_gt_T) begin  // move current node down & replace rTop with in
                        out = rTop.kv;
                        wData.active = 1'b1;
                        wData.capacity = (rTop.capacity == 0) ? 0 : rTop.capacity - 1;
                        wData.kv = in_reg;
                        wenTop = 1'b1;
                    end else begin
                        out = in_reg;
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
            end
            else if (op == LDEQ) begin
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
                // he new value is either in_reg or one of the  chldren
                // we want to write the biggest child as the new top
                // and pass ENQ_DEQ to next level
                wData.active = 1;
                wenTop = 1;
                next = READ_MEM;
                if (in_gt_L && in_gt_R) begin  // heap property satisfied
                    wData.kv = in_reg;          // just write in top
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
                    out = in_reg;
                    done = NEXT_LEVEL;
                end
                else if (!in_gt_L) begin
                    wData.kv = rBotL.kv;
                    endPos = left_child;
                    out = in_reg;
                    done = NEXT_LEVEL;
                end
                else begin // !in_gt_R
                    wData.kv = rBotR.kv;
                    endPos = right_child;
                    out = in_reg;
                    done = NEXT_LEVEL;
                end
            end
        end
    endcase
end

endmodule
