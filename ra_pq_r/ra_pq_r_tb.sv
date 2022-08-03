//`include "../pk_pkg.sv"
//-----------------------------------------------------------------------------
// Module Name   : ra_pq_tb - testbench for register arry PQ
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : July 2021
//-----------------------------------------------------------------------------
// Description   : Testbench for register array "reduced" PQ
//-----------------------------------------------------------------------------

import pq_pkg::*;

module ra_pq_r_tb (pq_if.tb ti);

    task do_enq (input logic [KEY_WIDTH-1:0] key, input logic [VAL_WIDTH-1:0] val);
        // while (ti.cb.busy == 1) begin
        //     @ti.cb;
        // end
        assert (ti.cb.full==0)
        else $warning("do_enq: attempting when queue full at %t", $time);
        ti.cb.kvi <= {key,val};
        ti.cb.enq <= 1;
        ti.cb.deq <= 0;
        do begin
            @ti.cb;
        end while (ti.cb.busy==0);
        @ti.cb;
        ti.cb.enq <=0;
        @ti.cb;
    endtask

    task do_deq();
        @(ti.cb iff ti.cb.busy==0);
        //while (ti.cb.busy == 1) @ti.cb;
        assert(ti.cb.empty==0)  // squawk if we try to deqeue when empty
        else $warning("do_deq: attempting when queue empty at %t", $time);
        ti.cb.enq <= 0;
        ti.cb.deq <= 1;
        @ti.cb;
        ti.cb.deq <= 0;
        @ti.cb;
    endtask

    task do_enq_and_deq(input logic [KEY_WIDTH-1:0] key, input logic [VAL_WIDTH-1:0] val);
        //while (ti.cb.busy == 1) @ti.cb;
        @(ti.cb iff ti.cb.busy==0);
        // no need to check empty & full since it can complete either way
        ti.cb.kvi <= {key,val};
        ti.cb.enq <= 1;
        ti.cb.deq <= 1;
        @ti.cb;
        ti.cb.enq <= 0;
        ti.cb.deq <= 0;
        @(ti.cb);
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

      @ti.cb;
      ti.cb.rst <= 0;
      @ti.cb;
      do_enq(8,14);
      repeat (4) @ti.cb;
      do_enq(11,11);
      @ti.cb;
      @ti.cb;
      do_enq(9,9);
      @ti.cb;
      do_enq(12,12);
      @ti.cb;
      @ti.cb;
      do_enq_and_deq(13,13);
      do_enq_and_deq(1,1);
      repeat (4) do_deq;
      @ti.cb;
      @ti.cb;
      do_enq(10,10);
      do_enq(11,1);
      do_enq(1,1);
      empty_pq;
      @ti.cb;
      @ti.cb;

     $stop;
  end

endmodule: ra_pq_r_tb
