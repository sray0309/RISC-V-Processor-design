
//--xuezhen--

`include "sys_defs.svh"

module if_stage(
  input                clk,
  input                rst,
  input [ `XLEN-1 : 0] inst,
  input                stall,
  input [     63 : 0 ] target_PC,
  
  output logic [63 : 0] inst_addr,
  output logic         inst_ena,
  output IF_ID_PACKET if_packet_out
  
);

logic [63 : 0] PC, NPC;

// fetch an instruction
always_ff @( posedge clk )
begin
  if( rst == 1'b1 ) PC <= `ZERO_WORD ;
  else PC <= NPC;
end

assign NPC = PC + 4;
assign inst_addr = PC;
assign inst_ena  = ( rst == 1'b1 ) ? 0 : 1;


endmodule
