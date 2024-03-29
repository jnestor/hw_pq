//`include "../pk_pkg.sv"
import pq_pkg::*;

module sr_pq_tb (pq_if.tb ti);

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
      do_enq(8,14);
      @ti.cb;
      do_enq(14,14);
      @ti.cb;
      do_enq(9,10);
      do_enq(9,11);
      do_enq(9,12);
      do_enq(55,55);
      do_enq(5,5);
      do_enq(30,30);
      @ti.cb;  // something funny here!
      do_enq_and_deq(1,1);
      do_enq_and_deq(16,16);
      while (!ti.cb.empty) do_deq();
      repeat (4) @ti.cb;
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

endmodule: sr_pq_tb
