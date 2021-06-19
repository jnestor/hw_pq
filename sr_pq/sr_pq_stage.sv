//
//  Single stage for shift-register PQ
//


//`include "../pk_pkg.sv"
import pq_pkg::*;

module sr_pq_stage (
    input logic clk, rst, push, pop, ki_lt_kprev, ki_lt_knext,
    input kv_t kvi,      // global key-valu input
    input kv_t kvprev,   // from previous stage (for right shift on push)
    input kv_t kvnext,   // from next stage (for left shift on pop)
    output kv_t kv,      // key-value stored in this stage
    output logic ki_lt_k // comparator output: input key < current key in this stage
    );

  assign ki_lt_k = (kvi.key < kv.key);

  always_ff @(posedge clk)
    begin
      if (rst)
        begin
          kv <= KV_EMPTY;
        end
      else if (pop && push)
        begin
            if (!ki_lt_k && !ki_lt_knext)
                begin  // shift left
                    kv <= kvnext;
                end
            else if (!ki_lt_k && ki_lt_knext)
                begin  // insert here for simultaneous push, pop
                    kv <= kvi;
                end  // otherwise, this stage doesnt' change
        end
      else if (pop)
        begin
            kv <= kvnext;
        end
      else if (push)
        begin
            if (!ki_lt_kprev && ki_lt_k)
                begin
                    kv <= kvi;
                end
            else if (ki_lt_kprev && ki_lt_k)
                begin
                    kv <= kvprev;
                end
        end  // otherwise, this stage doesn't change
    end

endmodule: sr_pq_stage
