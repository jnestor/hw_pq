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


typedef enum logic {READ_MEM, SET_OUT} states_t;
states_t state, next;

kv_t in_reg;

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
            end else if (op == DEQ) begin
                out = rTop.kv;
                wData.capacity = rTop.capacity + 1;
                wenTop = 1'b1;
                if (!rBotL.active && !rBotR.active) begin
                    done = DONE;
                    wData.kv = KV_EMPTY;
                    wData.active = 1'b0;
                end else if (rBotL.active && rBotR.active) begin
                    wData.kv = (rBotL.kv.key >= rBotR.kv.key) ? rBotL.kv : rBotR.kv;
                    wData.active = 1'b1;
                    endPos = (rBotL.kv.key >= rBotR.kv.key) ? {startPos, 1'b0} : {startPos, 1'b1};
                    done = NEXT_LEVEL;
                end else if (rBotL.active) begin
                    wData.kv = rBotL.kv;
                    wData.active = 1'b1;
                    endPos = {startPos, 1'b0};
                    done = NEXT_LEVEL;
                end else begin
                    wData.kv = rBotR.kv;
                    wData.active = 1'b1;
                    endPos = {startPos, 1'b1};
                    done = NEXT_LEVEL;
                end
            end
        end

    endcase
end

endmodule
