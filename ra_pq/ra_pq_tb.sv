//`include "../pk_pkg.sv"
//-----------------------------------------------------------------------------
// Module Name   : ra_pq_tb - testbench for register arry PQ
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : July 2021
//-----------------------------------------------------------------------------
// Description   : Testbench for register array PQ
//-----------------------------------------------------------------------------

import pq_pkg::*;

module ra_pq_tb (pq_if.tb ti);

    task do_enq (input logic [KEY_WIDTH-1:0] key, input logic [VAL_WIDTH-1:0] val);
        ti.cb.kvi <= {key,val};
        ti.cb.enq <= 1;
        ti.cb.deq <= 0;
        @ti.cb;
        ti.cb.enq <=0;
    endtask

    task do_deq();
        // while (ti.cb.ovalid==0) @ti.cb; // wait until there is something to remove
        assert(ti.cb.empty==0);
        ti.cb.enq <= 0;
        ti.cb.deq <= 1;
        @ti.cb;
        ti.cb.deq <= 0;
    endtask

    task do_enq_and_deq(input logic [KEY_WIDTH-1:0] key, input logic [VAL_WIDTH-1:0] val);
        $display("enq_deq <%d,%d>", key, val);
        ti.cb.kvi <= {key,val};
        ti.cb.enq <= 1;
        ti.cb.deq <= 1;
        @ti.cb;
        ti.cb.enq <= 0;
        ti.cb.deq <= 0;
    endtask

    task empty_pq;
        while (!ti.cb.empty) begin
            do_deq;
        end
        repeat (4) @ti.cb;
    endtask

  initial begin
      @ti.cb;
      ti.cb.rst <= 1;
      ti.cb.enq <= 0;
      ti.deq <= 0;
      ti.kvi = {0,0};

      @ti.cb;
      ti.cb.rst <= 0;
      $stop;
      @ti.cb;
      do_enq(8,14);
      @ti.cb;
      do_enq(11,11);
      do_enq(9,9);
      do_enq(10,10);
      @ti.cb;
      @ti.cb;
      repeat(4) do_deq();
      @ti.cb;
      do_enq(15,15);
      do_enq(1,11);
      do_enq(10,10);
      do_enq_and_deq(12,12);
      @ti.cb;
      empty_pq;
//      do_enq_and_deq(2,12);
//      @ti.cb;
//      do_enq(9,10);
//      do_enq(9,11);
//      do_enq(9,12);
//      @ti.cb;  // something funny here!
//      do_enq_and_deq(1,11);
//      repeat (4) do_deq();
//      do_enq_and_deq(11,1);
      @ti.cb;
//      do_enq (12,12);
//      @(ti.cb);
//      do_enq(3,13);
//      do_enq(10,10);
//      @ti.cb;  // shoud register full here
//      do_deq();
//      do_enq(2,13);
//      @ti.cb;  // should register full again
//      do_enq_and_deq(1,11);
//      @ti.cb;
//      repeat(4) do_deq();
     $stop;
  end

endmodule: ra_pq_tb
