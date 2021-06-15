//
//  Single stage for shift-register PQ
//

module sr_pq_stage  #(parameter KW=4, VW=4) (
    input logic clk, rst, push, pop, ki_lt_kprev, ki_lt_knext,
    input logic [KW+VW-1:0] kvi, kvprev, kvnext,
    output logic [KW+VW-1:0] kv,  // key stored in this stage
    output logic ki_lt_k
    );
    
    parameter [KW-1:0] KEYINF = '1;
    parameter [VW-1:0] VAL0 = '0;

  logic unsigned [KW-1:0] k, ki;
  assign k = kv[KW+VW-1:VW];
  assign ki = kvi[KW+VW-1:VW];

  assign ki_lt_k = (ki < k);

  always_ff @(posedge clk)
    begin
      if (rst)
        begin
          kv <= { KEYINF, VAL0 };
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
