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

task print_pheap;
    $root.pheap_pq_top.DUV.print_pheap();
endtask

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
        $display("enqueue-dequeue (NOT FULLY TESTED YET!)");
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
      @ti.cb;
      do_enq(13,11);
      repeat (4) @ti.cb;
      print_pheap;
      do_enq(12,15);
      repeat (4) @ti.cb;
      print_pheap;
      do_enq(10,15);
      repeat (4) @ti.cb;
      print_pheap;
      do_enq(15,15);
      repeat (8) @ti.cb;
      print_pheap;
      do_enq(3,3);
      repeat (8) @ti.cb;
      print_pheap;
      do_enq(9,9);
      repeat (12) @ti.cb;
      print_pheap;
      // do_enq_and_deq(6,6);
      // repeat (4) @ti.cb;
      // print_pheap;
      // do_enq_and_deq(14,8);
      // repeat (4) @ti.cb;
      // print_pheap;
      // do_enq_and_deq(9,9);
      // repeat (8) @ti.cb;
      //print_pheap;
      // @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // do_enq(11,14);
      // repeat (4) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // do_enq(15,11);
      // repeat (4) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // do_enq(9,9);
      // repeat (4) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // do_enq(8,55);
      // repeat (8) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // do_enq(35,53);
      // repeat (8) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // do_enq(12,12);
      // repeat (8) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // do_enq(1,53);
      // repeat (8) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // repeat (4) @ti.cb;
      // do_deq();
      // repeat (4) @ti.cb;
      // do_deq();
      // repeat (4) @ti.cb;
      // do_deq();
      // repeat (8) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // do_deq();
      // repeat (8) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // do_deq();
      // repeat (8) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // do_deq();
      // repeat (8) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // repeat (4) @ti.cb;
      // do_deq();
      // repeat (8) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // do_deq();
      // repeat (8) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // do_deq();
      // repeat (8) @ti.cb;
      // $root.pheap_pq_top.DUV.print_pheap();
      // repeat (4) @ti.cb;

     $stop;
  end

endmodule
