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
        $display("enqueue <%d,%d>", key, val);
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
            repeat (4) @ti.cb;
        end
        repeat (4) @ti.cb;
        print_pheap;
    endtask


    task enqueue_15;
        const int ENQ_SPACE=8;
        do_enq(15,15);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(11,11);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(9,9);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(8,8);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(35,35);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(20,20);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(6,6);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(12,12);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(18,18);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(60,60);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(5,5);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(40,40);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(17,17);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(85,85);
        repeat (ENQ_SPACE) @ti.cb;
        print_pheap;
        do_enq(3,3);
        repeat (8) @ti.cb;  // allow full completion
        print_pheap;
    endtask;

    task replace_15;
        const int ENQ_DEQ_SPACE=4;
        do_enq_and_deq(33,33); //1
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(44,44); //2
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(22,22); //3
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(99,99); //4
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(88,88); //5
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(11,11); //6
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(99,99); //7
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(101,101); //8
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(28,28); //9
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(7,7); //10
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(222,222); //11
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(37,37); //12
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(13,13); //13
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(114,114); //14
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
        do_enq_and_deq(215,215); //15
        repeat (ENQ_DEQ_SPACE) @ti.cb;
        print_pheap;
    endtask

  initial begin
      @ti.cb;
      ti.cb.rst <= 1;
      ti.cb.enq <= 0;
      ti.deq <= 0;
      @ti.cb;
      ti.cb.rst <= 0;
      @ti.cb;
      enqueue_15;
      repeat (4) @ti.cb;
      replace_15;
      $stop;
      empty_pq;
      repeat (8) @ti.cb;
      print_pheap;

      //
      // from yesterday 7/15
      // @ti.cb;
      // do_enq(13,11);
      // repeat (4) @ti.cb;
      // print_pheap;
      // do_enq(12,15);
      // repeat (4) @ti.cb;
      // print_pheap;
      // do_enq(10,15);
      // repeat (4) @ti.cb;
      // print_pheap;
      // do_enq(15,15);
      // repeat (8) @ti.cb;
      // print_pheap;
      // do_enq(3,3);
      // repeat (8) @ti.cb;
      // print_pheap;
      // do_enq(9,9);
      // repeat (12) @ti.cb;
      // print_pheap;
      //
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
