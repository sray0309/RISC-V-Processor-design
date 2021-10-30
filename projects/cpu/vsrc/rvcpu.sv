
//--xuezhen--

`timescale 1ns / 1ps

`include "sys_defs.svh"


module rvcpu(
  input            clk,
  input            rst,
  input  [31 : 0]  inst,
  
  output logic [63 : 0]  inst_addr, 
  output logic           inst_ena
);

IF_ID_PACKET if2id_packet;
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

// exe_stage
// exe_stage -> other stage
logic [4 : 0]inst_type_o;
// exe_stage -> regfile
logic [`DATA_WIDTH  - 1 : 0 ]rd_data;

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
  .rst(rst),
  .if_packet_out(if2id_packet),
  .rs1_data(r_data1),
  .rs2_data(r_data2),
  
  .rs1_r_ena(rs1_r_ena),
  .rs1_r_addr(rs1_r_addr),
  .rs2_r_ena(rs2_r_ena),
  .rs2_r_addr(rs2_r_addr),
  .rd_w_ena(rd_w_ena),
  .rd_w_addr(rd_w_addr),
  .inst_type(inst_type),
  .inst_opcode(inst_opcode),
  .op1(op1),
  .op2(op2)
);

exe_stage Exe_stage(
  .rst(rst),
  .inst_type_i(inst_type),
  .inst_opcode(inst_opcode),
  .op1(op1),
  .op2(op2),
  
  .inst_type_o(inst_type_o),
  .rd_data(rd_data)
);

regfile Regfile(
  .clk(clk),
  .rst(rst),
  .w_addr(rd_w_addr),
  .w_data(rd_data),
  .w_ena(rd_w_ena),
  
  .r_addr1(rs1_r_addr),
  .r_data1(r_data1),
  .r_ena1(rs1_r_ena),
  .r_addr2(rs2_r_addr),
  .r_data2(r_data2),
  .r_ena2(rs2_r_ena)
);

endmodule
