//-----------------------------------------------------------------------------
// Module Name   : reg_tree_node
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : June 14, 2022
//-----------------------------------------------------------------------------
// Description   : "Register Tree" node module
// When cpsw_en=1, do a compare-and-swap with the left and right children,
// i.e., if either left or right input has a key less than node,
// swap node with the smallest child
//-----------------------------------------------------------------------------

import pq_pkg::*;

module reg_tree_node(
    input logic clk, rst, cpsw_en,
    input kv_t parent, left, right,
    input logic parent_swap,
    output logic left_swap, right_swap,
    output kv_t val;
    );

    kv_t min_child, val_next;
    logic left_lt_right;

    assign left_lt_right = left < right;

    always_ff @(posedge clk) begin
        if (rst) val = {KEY0,VAL0};
        else val = val_next;
    end

    always_comb begin
        left_lt_right = (left < right);
        left_swap = 0;
        right_swap = 0;
        min_child = {KEY0,VAL0};
        val_next = val;
        if (cpsw_en) begin
            if (left_lt_right) min_child = left;
            else min_child = right;
            if (min_child < val) begin
                if (left_lt_right) begin
                    left_swap = 1;
                    val_next = left;
                end
                else begin
                    right_swap = 1;
                    val_next = right;
                end
            end
        end
        else begin  // swap with parent
            if (parent_swap) val_next = parent;
        end
    end

endmodule
