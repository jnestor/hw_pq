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
    parameter PQ_CAPACITY=4;

    typedef enum logic {MIN_PQ, MAX_PQ} pq_type_t;

    parameter pq_type_t PQ_TYPE = MIN_PQ;

    parameter [KEY_WIDTH-1:0] KEYMAX = '1;
    parameter [KEY_WIDTH-1:0] KEY0 = '0;
    parameter [VAL_WIDTH-1:0] VAL0 = '0;

    // KEYINF represents the "highest" priority and is used as a sentinel
    // value by some implementations.  Its actual value depends on whether
    // we are implemeting a MIN_PQ or MAX_PQ.
    // CAUTION: The KEYINF sentinel value CANNOT be used as a key during operation
    parameter KEYINF = (PQ_TYPE == MIN_PQ) ? KEYMAX : KEY0;
    // KEYNEGINF represents the "lowest" priority and is used as a sentinel
    // value by the ra_pq_s priority queue.  Its actual value depends on
    // whether we are implementing an MIN_PQ or MAX_PQ.
    // CAUTION: The KEYNEGINF sentinel value CANNOT be used as a key during
    // operation of the sr_pq_s module
    parameter KEYNEGINF = (PQ_TYPE == MIN_PQ) ? KEY0 : KEYMAX;

    typedef struct packed {
    logic [KEY_WIDTH-1:0] key;    // priority value
    logic [VAL_WIDTH-1:0] value;  // data payload
    } kv_t;

    parameter kv_t KV_EMPTY = {KEYINF, VAL0};

    task print_kv(input kv_t kv);
        $write("[K=%d V=%d]", kv.key, kv.value);
    endtask

    // Compare keys to determine "highest" priority
    // paremeterized by PQ_TYPE
    function logic cmp_kv_gt(input kv_t k1, k2);
        //$display("cmp_kv_gt(%d,%d)", k1.key, k2.key);
        if (PQ_TYPE==MAX_PQ) begin
            return (k1.key > k2.key);
        end
        else begin
            return (k1.key < k2.key);
        end
    endfunction

    // Compare keys to determine "lowest" priority
    // paremeterized by PQ_TYPE
    function logic cmp_kv_lt(input kv_t k1, k2);
        if (PQ_TYPE==MAX_PQ) begin
            return (k1.key < k2.key);
        end
        else begin
            return (k1.key > k2.key);
        end
    endfunction

endpackage

`endif
