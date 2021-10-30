
//--xuezhen--

`include "sys_defs.svh"

module if_stage(
  input                clk,
  input                rst,
  input [ `XLEN-1 : 0] inst,
  input                stall,
  input [      63 : 0] target_PC,
  
  output logic [63 : 0] inst_addr,
  output logic          inst_ena,
  output IF_ID_PACKET   if_packet_out

);

logic [63 : 0] PC, NPC;

// fetch an instruction
always_ff @( posedge clk )
begin
  if( rst == 1'b1 ) begin
    PC <= `ZERO_WORD ;
    inst_ena <= 1'b0;
  end
  else begin 
    PC <= NPC;
    inst_ena <= 1'b1;
  end
end

assign inst_addr = PC;
assign NPC = PC + 4;
assign if_packet_out.inst = inst;
assign if_packet_out.valid = 1;
assign if_packet_out.NPC = NPC;
assign if_packet_out.PC = PC;

endmodule
