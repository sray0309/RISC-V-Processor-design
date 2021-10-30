module adder(
    input clk,
    input [3:0] a,
    input [3:0] b,
    output reg [3:0] c
);

    always @(posedge clk) begin
        c <= a + b;
    end
    
endmodule