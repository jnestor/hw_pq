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

module pheap_pq_tb (pq_if.tb ti);

    task do_enq (input logic [KEY_WIDTH-1:0] key, input logic [VAL_WIDTH-1:0] val);
        $display("enqueue [%d,%d]", key, val);
        ti.cb.kvi <= {key,val};
        ti.cb.enq <= 1;
        ti.cb.deq <= 0;
        @ti.cb;
        ti.cb.enq <=0;
    endtask

    task do_deq();
        $display("dequeue");
        // while (ti.cb.ovalid==0) @ti.cb; // wait until there is something to remove
        assert(ti.cb.empty==0);
        ti.cb.enq <= 0;
        ti.cb.deq <= 1;
        @ti.cb;
        ti.cb.deq <= 0;
    endtask

    task do_enq_and_deq(input logic [KEY_WIDTH-1:0] key, input logic [VAL_WIDTH-1:0] val);
        $display("enqueue-dequeue (NOT IMPLEMENTED YET!)");
        ti.cb.kvi <= {key,val};
        ti.cb.enq <= 1;
        ti.cb.deq <= 1;
        @ti.cb;
        ti.cb.enq <= 0;
        ti.cb.deq <= 0;
    endtask

  initial begin
      @ti.cb;
      ti.cb.rst <= 1;
      ti.cb.enq <= 0;
      ti.deq <= 0;

      @ti.cb;
      ti.cb.rst <= 0;
      // @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      do_enq(11,14);
      repeat (4) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      do_enq(15,11);
      repeat (4) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      do_enq(9,9);
      repeat (4) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      do_enq(8,55);
      repeat (8) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      do_enq(35,53);
      repeat (8) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      do_enq(12,12);
      repeat (8) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      do_enq(1,53);
      repeat (8) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      // repeat (4) @ti.cb;
      // do_deq();
      // repeat (4) @ti.cb;
      // do_deq();
      repeat (4) @ti.cb;
      do_deq();
      repeat (8) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      do_deq();
      repeat (8) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      do_deq();
      repeat (8) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      do_deq();
      repeat (8) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      repeat (4) @ti.cb;
      do_deq();
      repeat (8) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      do_deq();
      repeat (8) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      do_deq();
      repeat (8) @ti.cb;
      $root.pheap_pq_top.DUV.print_pheap();
      repeat (4) @ti.cb;
      // do_enq(10,10);
      // @ti.cb;
      // @ti.cb;
      // repeat(4) do_deq();
      // @ti.cb;
      // do_enq(15,15);
      // do_enq(1,11);
      // do_enq(10,10);
      //do_enq_and_deq(12,12);
      @ti.cb;
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

endmodule
