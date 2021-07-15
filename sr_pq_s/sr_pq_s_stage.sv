//-----------------------------------------------------------------------------
// Package Name  : sr_pq_stage_s - one stage of shift-register PQ
// Project       : HWPQ: Hardware Priority Queue Study
//-----------------------------------------------------------------------------
// Author        : John Nestor
// Created       : July 13, 2021
//-----------------------------------------------------------------------------
// Description   : Implements one stage of the shift-regsiter PQ
//                 Simplified to perform enqueue & dequeue only
//                 (no replace operation)
//-----------------------------------------------------------------------------

import pq_pkg::*;

module sr_pq_s_stage (
    input logic clk, rst, enq, deq, ki_lt_kprev, ki_lt_knext,
    input kv_t kvi,      // global key-valu input
    input kv_t kvprev,   // from previous stage (for right shift on enq)
    input kv_t kvnext,   // from next stage (for left shift on deq)
    output kv_t kv,      // key-value stored in this stage
    output logic ki_lt_k // comparator output: input key < current key in this stage
    );

    parameter STAGE = 0;  // should be overriden when instantiating

    assign ki_lt_k = (kvi.key < kv.key);

    always_ff @(posedge clk)
    begin
        if (rst)
        begin
            kv <= KV_EMPTY;
        end
        // else if (replace)
        // begin
        //     if (!ki_lt_k && !ki_lt_knext)
        //     begin  // shift left
        //         kv <= kvnext;
        //     end
        //     else if ((!ki_lt_k || (STAGE==1)) && ki_lt_knext) // always remove 1st stage
        //     begin  // insert here for simultaneous enq, deq
        //         kv <= kvi;
        //     end  // otherwise, this stage doesnt' change
        // end
        else if (deq)
        begin
            kv <= kvnext;
        end
        else if (enq)
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

endmodule: sr_pq_s_stage
