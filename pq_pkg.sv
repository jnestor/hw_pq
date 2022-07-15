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

    parameter KEY_WIDTH=8;
    parameter VAL_WIDTH=8;
    parameter PQ_CAPACITY=15;

    parameter [KEY_WIDTH-1:0] KEYINF = '1;
    parameter [KEY_WIDTH-1:0] KEY0 = '0;
    parameter [VAL_WIDTH-1:0] VAL0 = '0;

    typedef enum logic {MIN_PQ, MAX_PQ} pq_type_t;

    parameter pq_type_t PQ_TYPE = MAX_PQ;

    typedef struct packed {
    logic [KEY_WIDTH-1:0] key;    // priority value
    logic [VAL_WIDTH-1:0] value;  // data payload
    } kv_t;

    parameter kv_t KV_EMPTY = {KEYINF, VAL0};

    task print_kv(input kv_t kv);
        $write("[K=%d V=%d]", kv.key, kv.value);
    endtask

    function cmp_kv_gt(input kv_t k1, k2);
        if (PQ_TYPE==MAX_PQ) return (k1.key > k2.key);
        else return (k1.key < k2.key);
    endfunction

endpackage

`endif
