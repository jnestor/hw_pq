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

package pq_pkg;

    // struct data type for <key,value> pairs

    parameter KEY_WIDTH=4;
    parameter VAL_WIDTH=4;
    parameter PQ_CAPACITY=4;

    typedef packed struct {
    logic [KEY_WIDTH-1:0] key;    // priority value
    logic [VAL_WIDTH-1:0] value;  // data payload
    } kv_t;

    interface pq_int (input logic clk, rst);
        logic ivalid;
        logic irdy;
        logic busy;
        logic full;
        kv_t idata;
        logic ovalid;
        logic ordy;
        kv_t odata;

        // used to implement a device
        modport pq_devint(
        input logic clk,
        input logic ivalid,
        output logic irdy,
        input kv_t idata,
        output logic busy,
        output logic full,
        output logic ovalid,
        input logic ordy,
        output kv_t odata;
        ) ;

        // use to connect to a device
        modport pq_clint(
        input  logic clk,
        output logic ivalid,
        input logic irdy,
        output kv_t idata,
        input logic busy,
        input logic full,
        input logic ovalid,
        output logic ordy,
        input kv_t odata;
        ) ;

    endinterface

endpackage
