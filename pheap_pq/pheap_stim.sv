`include "pheapTypes.sv"

module pheap_stim import pheapTypes::*;;
    logic clk, rst, valid, rdy, valid_out;
    logic [31:0] priorityIn, priorityOut;
    pheapTypes::opcode_t toperation;

    pheap U_PHEAP(.clk, .rst, .valid, .priorityIn, .toperation, .rdy, .priorityOut, .valid_out);

    parameter CLK_PD = 10;

    always begin
        clk = 1'b0; #(CLK_PD/2);
        clk = 1'b1; #(CLK_PD/2);
    end

    task enqueue(input logic [31:0] pri);
        while (!rdy) @(posedge clk);
        //#1;
        valid = 1;
        toperation = LEQ;
        priorityIn = pri;
        #(CLK_PD);
        valid = 0;

    endtask:enqueue

    task dequeue;
        while (!rdy) @(posedge clk);
        #1;
        valid = 1;
        toperation = DEQ;
        priorityIn = 0;
        #(CLK_PD);
        valid = 0;
        while (!valid_out) @(posedge clk);
        $display("Dequeued element: %h", priorityOut);

    endtask:dequeue

    logic [31:0] randInput;
    task enqueue_rand(input int num_entries);
        randInput = $urandom();

        for(int i = 0; i < num_entries; i++) begin
            $display("Enqueuing random value: %h", randInput);
            enqueue(randInput);
            randInput = $urandom();
        end

    endtask:enqueue_rand

    task dequeue_num(input int num_entries);
        for(int i = 0; i < num_entries; i++) begin
            dequeue;
        end
    endtask: dequeue_num

    initial begin
        valid = 0;
        rst = 1;
        priorityIn = 0;
        #(CLK_PD); #1;
        rst = 0;
        valid = 1;
        toperation = LEQ;
        priorityIn = 32'h38;
        #(CLK_PD * 2);
        valid = 0;
        #(CLK_PD * 5);
        enqueue(32'h10);
        #(CLK_PD * 5);
        enqueue(32'h90);
        #(CLK_PD*5);
        enqueue(32'h85);
        enqueue(32'h84);
        dequeue();
        #(CLK_PD*5);
        dequeue();
        #(CLK_PD*5);
        dequeue();
        #(CLK_PD*5);
        dequeue();
        dequeue();
        #(CLK_PD*5);
        //enqueue_rand(16);
        //dequeue_num(15);
        //#(CLK_PD * 20);
        $stop;
    end

endmodule
