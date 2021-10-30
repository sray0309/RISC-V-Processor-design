//top.v
module top (
    input clk,
    input reset,
    output logic [3:0] out);
    
    always_ff @(posedge clk) begin
        out <= reset ? 0 : out + 1;
    end
    
endmodule
