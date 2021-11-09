
//--xuezhen--

`timescale 1ns / 1ps

`include "sys_defs.svh"


module rvcpu(
  input            clk,
  input            rst,
  input  [31 : 0]  inst,
  
  output logic [63 : 0]  inst_addr, 
  output logic           inst_ena,
  output logic [63 : 0]  rd_data
);

IF_ID_PACKET if2id_packet;
ID_EX_PACKET id2ex_packet;
EX_MEM_PACKET ex2mem_packet;
// id_stage
// id_stage -> regfile
logic rs1_r_ena;
logic [4 : 0]rs1_r_addr;
logic rs2_r_ena;
logic [4 : 0]rs2_r_addr;
logic rd_w_ena;
logic [4 : 0]rd_w_addr;
// id_stage -> exe_stage
logic [4 : 0]inst_type;
logic [7 : 0]inst_opcode;
logic [`DATA_WIDTH  - 1 : 0] op1;
logic [`DATA_WIDTH  - 1 : 0] op2;

// regfile -> id_stage
logic [`DATA_WIDTH  - 1 : 0] r_data1;
logic [`DATA_WIDTH  - 1 : 0] r_data2;

// exe_stage -> regfile
// logic [`DATA_WIDTH  - 1 : 0 ]rd_data;

if_stage If_stage(
  .clk(clk),
  .rst(rst),
  .inst(inst),
  .stall(1'b0),
  .target_PC(64'h0),
  
  .inst_addr(inst_addr),
  .inst_ena(inst_ena),
  .if_packet_out(if2id_packet)
);

id_stage Id_stage(
  .clk(clk),
  .rst(rst),
  .if_packet_in(if2id_packet),
  
  .wb_reg_write_en(ex2mem_packet.dest_reg_addr != `ZERO_REG),
  .wb_reg_write_addr(ex2mem_packet.dest_reg_addr),
  .wb_reg_write_data(ex2mem_packet.alu_result),

  .id_packet_out(id2ex_packet)
);

exe_stage Exe_stage(
  .clk(clk),
  .rst(rst),
  .id_packet_in(id2ex_packet),

  .ex_packet_out(ex2mem_packet)
);

endmodule
