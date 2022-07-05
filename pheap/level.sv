`include "pheapTypes.sv"

module level
    import pheapTypes::*;

    #(parameter LEVEL=2)
    (input logic clk, wenTop, topActive, [LEVEL - 2:0] raddrTop, raddrBot, wraddrTop, pheapTypes::entry_t aTop,
    output pheapTypes::entry_t yTop, yBotL, yBotR
);



    logic we_a, we_b;
    logic [LEVEL - 2:0] addr_a, addr_b;
    logic [$bits(pheapTypes::entry_t) - 1 : 0] data_a, data_b;
    logic [$bits(pheapTypes::entry_t) - 1 : 0] q_a, q_b;

    assign we_b = 0;
    always_comb begin

        data_b = 0;
        if (topActive) begin
            we_a = wenTop;
            addr_a = wraddrTop;
            addr_b = raddrTop;
            data_a = aTop;
            yTop = q_b;
            yBotL = 0;
            yBotR = 0;
        end else begin
            data_a = 0;
            we_a = 0;
            addr_a = raddrBot;
            addr_b = raddrBot + 1;
            yBotL = q_a;
            yBotR = q_b;
            yTop = 0;
        end
    end

    levelRam #(LEVEL) U_RAM(.clk, .we_a, .we_b, .addr_a, .addr_b, .data_a, .data_b, .q_a, .q_b);


endmodule: level
