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

module ra_pq_s_tb (pq_rd_if.tb ti);

    task do_replace (input logic [KEY_WIDTH-1:0] key, input logic [VAL_WIDTH-1:0] val);
        ti.cb.kvi <= {key,val};
        ti.cb.replace <= 1;
        ti.cb.deq <= 0;
        @ti.cb;
        ti.cb.replace <=0;
    endtask

    task do_deq();
        // while (ti.cb.ovalid==0) @ti.cb; // wait until there is something to remove
        assert(ti.cb.empty==0);
        ti.cb.replace <= 0;
        ti.cb.deq <= 1;
        @ti.cb;
        ti.cb.deq <= 0;
    endtask

  initial begin
      @ti.cb;
      ti.cb.rst <= 1;
      ti.cb.replace <= 0;
      ti.deq <= 0;

      @ti.cb;
      ti.cb.rst <= 0;
      // @ti.cb;
      do_replace(8,14);
      @ti.cb;
      do_replace(11,11);
      do_replace(9,9);
      do_replace(10,10);
      @ti.cb;
      do_deq();
      do_replace(1,1);
      @ti.cb;
      repeat(3) do_deq();
      @ti.cb;
     $stop;
  end

endmodule: ra_pq_s_tb
