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
`include "../pq_pkg.sv"
import pq_pkg::*;

    interface pq_if (input logic clk, rst);
        logic ivalid;
        logic irdy;
        logic busy;
        logic full;
        kv_t idata;
        logic ovalid;
        logic ordy;
        kv_t odata;

        // used to implement a device
        modport dev (
        input ivalid,
        output irdy,
        input idata,
        output busy,
        output full,
        output ovalid,
        input ordy,
        output odata
        ) ;

        // use to connect to a device
        modport client (
        output ivalid,
        input irdy,
        output idata,
        input busy,
        input full,
        input ovalid,
        output ordy,
        input odata
        ) ;

    endinterface
