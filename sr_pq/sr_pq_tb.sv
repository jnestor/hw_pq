//`include "../pk_pkg.sv"
import pq_pkg::*;

module sr_pq_tb (pq_if.tb ti);

    task push(input logic [KEY_WIDTH-1:0] key, input logic [VAL_WIDTH-1:0] val);
        assert(irdy==1);
        ti.idata <= {key,val};
        ti.ivalid <= 1;
        ti.ordy <= 0;
        @ti.cb;
        ti.ivald <=0;
    endtask

    task pop()
        assert(ovalid==1);
        ti.ivalid <= 0;
        ti.ordy <= 1;
    endtask

    task push_and_pop(input logic [KEY_WIDTH-1:0] key, input logic [VAL_WIDTH-1:0] val);
        // need to check irdy, ovalid here
        assert (irdy==1 && ovalid==1);
        ti.data <= {key,val};
        ti.ivalid <= 1;
        ti.ordy <= 1;
        @ti.cb;
        ti.ivalid <= 0;
        ti.ordy <= 0;
    endtask

  initial begin
      ti.rst <= 1;
      ti.ivalid <= 0;
      ti.ordy <= 0;
      @ti.cb;
      ti.rst <= 0;
      push(8,14);
      push (12,12);
      @(ti.cb);
      push(3,13);
      push(10,10);
      @ti.cb;  // shoud register full here
      pop();
      push(2,13);
      @ti.cb;  // should register full again
      push_and_pop(1,11);
      @ti.cb;
      repeat(4) pop();
      $stop;
  end

endmodule: sr_pq_tb
