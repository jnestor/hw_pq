//-----------------------------------------------------------------------------
// Module Name   : pheapTypes
// Project       : pheap - pipelined heap priority queue implementation
//-----------------------------------------------------------------------------
// Author        : Ethan Miller
// Created       : May 2021
//-----------------------------------------------------------------------------
// Description   : This package declares types and data structures
// used in the pheap implementation.
//-----------------------------------------------------------------------------

`ifndef PHEAPTYPES
`define PHEAPTYPES
package pheapTypes;

    parameter LEVELS = 16;

    // done_t indicates the status of each level
    typedef enum logic [1:0] {DONE, NEXT_LEVEL, WAIT} done_t;

    // opcode_t specifies the operation to be performed by each level
    // FREE (do nothing), LEQ (enqueue), or DEQ (dequeue)
    typedef enum logic [1:0] {FREE, LEQ, DEQ} opcode_t;

    // type for priority value need to modify this to include a data value, too
    typedef logic [31:0] pValue;

    // entry_t used for each node in the pHeap
    typedef struct packed {
        pValue priorityValue;
        logic [LEVELS - 1:0] capacity;
        logic active;
    } entry_t;

    // operation and item passed down from one level to another
    typedef struct packed {
        opcode_t levelOp;
        logic [31:0] priorityValue;
    } opArray_t;

endpackage
`endif
