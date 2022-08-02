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
        if (ti.cb.busy == 0) begin
            @ti.cb;  // wait because next cycle will be even
        end
        ti.cb.kvi <= {key,val};
        ti.cb.enq <= 1;
        ti.cb.deq <= 0;
        @ti.cb;
        ti.cb.enq <=0;
    endtask

    task do_deq();
        // while (ti.cb.ovalid==0) @ti.cb; // wait until there is something to remove
        assert(ti.cb.empty==0);  // wait for an odd cycle
        if (ti.cb.busy == 0) @ti.cb;
        ti.cb.enq <= 0;
        ti.cb.deq <= 1;
        @ti.cb;
        ti.cb.deq <= 0;
    endtask

    task do_enq_and_deq(input logic [KEY_WIDTH-1:0] key, input logic [VAL_WIDTH-1:0] val);
        if (ti.cb.busy == 0) @ti.cb; // wait for an odd cycle
        ti.cb.kvi <= {key,val};
        assert(ti.cb.empty==0);  // wait for an odd cycle
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

      @ti.cb;
      ti.cb.rst <= 0;
      // @ti.cb;
      do_enq(8,14);
      @ti.cb;
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
