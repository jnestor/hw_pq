//-----------------------------------------------------------------------------
// Module Name   : leq1
// Project       : pheap - pipelined heap priority queue implementation
//-----------------------------------------------------------------------------
// Author        : Ethan Miller
// Created       : May 2021
//-----------------------------------------------------------------------------
// Description   : This module controls the top level of the pHeap
//-----------------------------------------------------------------------------

`include "pheapTypes.sv"

module leq1
    import pheapTypes::*;

    (input logic clk, rst, start, [31:0] in , pheapTypes::entry_t rBotL, rBotR, pheapTypes::opcode_t op,
    output pheapTypes::done_t done, logic raddrBot, endPos, [31:0] out
);

logic wenTop;
const logic [LEVELS-1:0] MAX_CAPACITY = '1;
pheapTypes::entry_t rTop, wData;
pheapTypes::entry_t level_mem = {32'h00000000, MAX_CAPACITY, 1'b0};

// storage for root node on level 1
always_ff @(posedge clk) begin
    if (rst) begin
        level_mem <= {32'h00000000, MAX_CAPACITY, 1'b0};
        rTop <= {32'h00000000, MAX_CAPACITY, 1'b0};
    end
    else if (wenTop) begin
        level_mem <= wData;
        if (wenTop) rTop <= wData;
        else rTop <= level_mem;
    end else rTop <= level_mem;

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
    out = 0;
    wData = 'b0;
    case (state)
        READ_MEM: begin
            if (start) begin
                done = WAIT;


                next = SET_OUT;
            end else next = READ_MEM;
        end

        SET_OUT: begin
            next = READ_MEM;
            if (op == LEQ) begin
                if (~rTop.active) begin
                    wData.active = 1'b1;
                    wData.capacity = rTop.capacity - 1;
                    wData.priorityValue = in; //gotta fix this - write the prioritity, decremented capacity and active
                    wenTop = 1'b1;
                    done = DONE;
                end else begin
                    if (rTop.priorityValue < in) begin //also fix this - if currentpriority less than priority to be written
                        out = rTop.priorityValue; //take a look at this logic: idk if legal
                        wData.active = 1'b1;
                        wData.capacity = (rTop.capacity == 0) ? 0 : rTop.capacity - 1;
                        wData.priorityValue = in;
                        wenTop = 1'b1;
                    end else begin out = in;
                        wData.active = 1'b1;
                        wData.capacity = (rTop.capacity == 0) ? 0 : rTop.capacity - 1;
                        wData.priorityValue = rTop.priorityValue;
                        wenTop = 1'b1;
                    end
                    if (rBotL.capacity != 0 && rBotR.capacity != 0)
                        endPos = (rBotL.priorityValue <= rBotR.priorityValue) ? 1'b0 : 1'b1;
                    else if (rBotL.capacity != 0)
                        endPos = 1'b0;
                    else
                        endPos = 1'b1;

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
                    endPos = (rBotL.priorityValue >= rBotR.priorityValue) ? 1'b0 : 1'b1;
                    done = NEXT_LEVEL;
                end
            end
        end
    endcase
end

endmodule
