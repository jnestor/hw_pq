//-----------------------------------------------------------------------------
// Module Name   : pheapTypes
// Project       : pheap - pipelined heap priority queue implementation
//-----------------------------------------------------------------------------
// Author        : Ethan Miller
// Created       : May 2021
// Revised       : July 2022 by J. Nestor
//-----------------------------------------------------------------------------
// Description   : This package declares types and data structures
// used in the pheap implementation.
// NOTE: PQ_CAPACITY should be set to a power of 2 minus one
//-----------------------------------------------------------------------------

`ifndef PHEAPTYPES
`define PHEAPTYPES

package pheapTypes;

    import pq_pkg::*;

    parameter LEVELS = $clog2(PQ_CAPACITY+1);

    // done_t indicates the status of each level
    typedef enum logic [1:0] {DONE, NEXT_LEVEL, WAIT} done_t;

    // opcode_t specifies the operation to be performed by each level
    // FREE (do nothing), LEQ (enqueue), or DEQ (dequeue)
    typedef enum logic [1:0] {FREE, LENQ, LDEQ, LREPL} opcode_t;

    // type for priority value need to modify this to include a data value, too
    //typedef logic [31:0] pValue;

    // entry_t used for each node in the pHeap
    typedef struct packed {
    //pValue priorityValue;
    kv_t kv;
    logic [LEVELS - 1:0] capacity;
    logic active;
    } entry_t;

    parameter entry_t ENTRY_EMPTY = {KV_EMPTY,{LEVELS{1'b0}},1'b00};

    // operation and item passed down from one level to another
    typedef struct packed {
    opcode_t levelOp;
    //logic [31:0] priorityValue;
    kv_t kv;
    } opArray_t;

    // comparison functions are designed so that inactive nodes
    // are always "less than" active nodes

    function logic cmp_kv_entry_gt(
        input kv_t kv,
        input entry_t e
        );
        //        $display("calling kv_entry_gt  <%d %d> %d %de",
        //                 e.kv.key, e.kv.value, e.capacity, e.active);
        if (!e.active) return 1'b1;
        else return cmp_kv_gt(kv, e.kv);
    endfunction

    function logic cmp_entry_entry_gt(
        input entry_t e1, e2
        );
        if (!e1.active && !e2.active) return 1'b0;
        else if (e1.active && !e2.active) return 1'b1;
        else if (e1.active && e2.active) return cmp_kv_gt(e1.kv, e2.kv);
        else return 1'b0;
    endfunction

    task print_entry(entry_t e);
        $write("[<]");
        print_kv(e.kv);
        $write("> %d %d]", e.capacity, e.active);
    endtask

endpackage
`endif
