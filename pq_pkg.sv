//-----------------------------------------------------------------------------
// Package Name   : pq_pkg
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : June 15, 2021
//-----------------------------------------------------------------------------
// Description   : Package defining data types and standard interface
//                 for hardware priority queues.  This package will be
//                 used in several different HWPQ implementations
//-----------------------------------------------------------------------------

`ifndef PQ_PKG
`define PQ_PKG

package pq_pkg;

    // struct data type for <key,value> pairs

    parameter KEY_WIDTH=4;
    parameter VAL_WIDTH=4;
    parameter PQ_CAPACITY=4;

    parameter [KEY_WIDTH-1:0] KEYINF = '1;
    parameter [KEY_WIDTH-1:0] KEY0 = '0;
    parameter [VAL_WIDTH-1:0] VAL0 = '0;

    typedef struct packed {
        logic [KEY_WIDTH-1:0] key;    // priority value
        logic [VAL_WIDTH-1:0] value;  // data payload
    } kv_t;

    parameter kv_t KV_EMPTY = {KEYINF, VAL0};

endpackage

`endif
