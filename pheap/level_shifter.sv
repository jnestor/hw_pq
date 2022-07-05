module level_shifter #(parameter LEVEL = 1)(
    input logic clk, rst, shift, [LEVEL - 2:0] pos_in,
    output logic [LEVEL - 2:0] pos_out);
    
    always_ff @(posedge clk) begin
        if (rst) pos_out <= 0;
        else if (shift) pos_out <= pos_in;
    end
    
endmodule
