//`include "../pk_pkg.sv"
import pq_pkg::*;

module sr_pq_tb (pq_if.tb ti);

  initial begin
      ti.rst <= 1;
      ti.ordy <= 0;
      @ti.cb;
      ti.rst <= 0;
      @(ti.cb);
      ti.idata <= {4'd4,4'd14};
      ti.ivalid <= 1;
      @ti.cb;
      ti.ivalid <= 0;
      @ti.cb;
      ti.idata <= {4'd12,4'd12};
      ti.ivalid <= 1;
      @ti.cb;
      ti.idata <= {4'd3,4'd13};
      @ti.cb;
      ti.idata <= {4'd1,4'd11};
      @ti.cb;
      ti.ivalid <= 0;
      @ti.cb;
      ti.ordy <= 1;
      repeat (3) @ti.cb;
      ti.ordy <= 0;
      @ti.cb;
      ti.ordy <= 1;
      @ti.cb;
      ti.ordy <= 0;
      @ti.cb;
      ti.idata <= {4'd5,4'd15};
      ti.ivalid <= 1;
      @ti.cb;
      // try inserting and removing at same time
      ti.idata <= {4'd1,4'd11};
      ti.ordy <= 1;
      @ti.cb;
      ti.ordy <= 0;
      ti.ivalid <= 0;
      @ti.cb;
      $stop;
  end

endmodule: sr_pq_tb
