//-----------------------------------------------------------------------------
// Module Name   : level_shifter
// Project       : pheap - pipelined heap priority queue implementation
//-----------------------------------------------------------------------------
// Author        : Ethan Miller
// Created       : May 2021
//-----------------------------------------------------------------------------
// Description   : This module stores the node position being passed
// from one level of the pheap to the next.
//-----------------------------------------------------------------------------

module level_shifter #(parameter LEVEL = 1) (
    input logic  clk, rst, shift, 
    input logic  [LEVEL - 2:0] pos_in,
    output logic [LEVEL - 2:0] pos_out);

    always_ff @(posedge clk) begin
        if (rst) pos_out <= 0;
        else if (shift) pos_out <= pos_in;
    end

endmodule
