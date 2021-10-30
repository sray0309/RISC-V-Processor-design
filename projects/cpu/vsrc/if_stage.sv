
//--xuezhen--

`include "sys_defs.svh"

module if_stage(
  input clk,
  input rst,
  
  output logic [63 : 0]inst_addr,
  output logic         inst_ena
  
);

logic [63 : 0] pc;

// fetch an instruction
always_ff @( posedge clk )
begin
  if( rst == 1'b1 )
  begin
    pc <= `ZERO_WORD ;
  end
  else
  begin
    pc <= pc + 4;
  end
end

assign inst_addr = pc;
assign inst_ena  = ( rst == 1'b1 ) ? 0 : 1;


endmodule
