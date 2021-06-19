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
//`include "../pq_pkg.sv"
import pq_pkg::*;

    interface pq_if (input logic clk);
        logic rst;
        logic ivalid;
        logic irdy;
        logic busy;
        logic full;
        kv_t idata;
        logic ovalid;
        logic ordy;
        kv_t odata;

        clocking cb @(posedge clk);
            output rst, ivalid, idata;
            input irdy;
            input busy, full;
            input ovalid, odata;
            output ordy;
        endclocking

        // used to implement a device
        modport dev (
        input clk,
        input rst,
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
        input clk,
        input rst,
        output ivalid,
        input irdy,
        output idata,
        input busy,
        input full,
        input ovalid,
        output ordy,
        input odata
        ) ;
        
        // use to connect to a testbench
        modport tb (
        clocking cb,
        output rst,
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
