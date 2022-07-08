//-----------------------------------------------------------------------------
// Module Name   : leq
// Project       : pheap - pipelined heap priority queue implementation
//-----------------------------------------------------------------------------
// Author        : Ethan Miller
// Created       : May 2021
//-----------------------------------------------------------------------------
// Description   : This module controls an individual level of the pheap
// for all levels except level1, which uses the leq1 module
//-----------------------------------------------------------------------------

`include "pheapTypes.sv"

module leq
    import pheapTypes::*;

    #(parameter LEVEL=2)
    (input logic clk, rst, start, [LEVEL - 2:0] startPos, pValue in, pheapTypes::entry_t rTop, rBotL, rBotR, pheapTypes::opcode_t op,
    output logic wenTop, active, pheapTypes::done_t done, [LEVEL - 2:0] raddrTop, wraddrTop, [LEVEL - 1:0] raddrBot, [LEVEL - 1:0] endPos, [31:0] out, pheapTypes::entry_t wData
);


typedef enum logic {READ_MEM, SET_OUT} states_t;
states_t state, next;

pValue in_reg;

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
    out = 0;
    wData = 'b0;

    case (state)
        READ_MEM: begin
            if (start) begin
                active = 1;
                done = WAIT;
// ???whye the empty lines here?  was something else supposed to be here?

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
                    wData.priorityValue = in_reg;
                    wenTop = 1'b1;
                    done = DONE;
                end else begin
                    if (rTop.priorityValue < in_reg) begin
                        out = rTop.priorityValue;
                        wData.active = 1'b1;
                        wData.capacity = (rTop.capacity == 0) ? 0 : rTop.capacity - 1;
                        wData.priorityValue = in_reg;
                        wenTop = 1'b1;
                    end else begin out = in_reg;
                        wData.active = 1'b1;
                        wData.capacity = (rTop.capacity == 0) ? 0 : rTop.capacity - 1;
                        wData.priorityValue = rTop.priorityValue;
                        wenTop = 1'b1;
                    end
                    if (rBotL.capacity != 0 && rBotR.capacity != 0)
                        endPos = (rBotL.priorityValue <= rBotR.priorityValue) ? {startPos, 1'b0} : {startPos, 1'b1};
                    else if (rBotL.capacity != 0)
                        endPos = {startPos, 1'b0};
                    else
                        endPos = {startPos, 1'b1};

                    done = NEXT_LEVEL;
                end
            end else if (op == DEQ) begin
                out = rTop.priorityValue;
                wData.capacity = rTop.capacity + 1;
                wenTop = 1'b1;
                if (~rBotL.active && ~rBotR.active) begin
                    done = DONE;
                    wData.priorityValue = 'b0;
                    wData.active = 1'b0;
                end else begin
                    wData.priorityValue = (rBotL.priorityValue >= rBotR.priorityValue) ? rBotL.priorityValue : rBotR.priorityValue;
                    wData.active = 1'b1;
                    endPos = (rBotL.priorityValue >= rBotR.priorityValue) ? {startPos, 1'b0} : {startPos, 1'b1};
                    done = NEXT_LEVEL;
                end
            end
        end

    endcase
end

endmodule
