
//--xuezhen--

`include "sys_defs.svh"

module id_stage(
  input rst,
  input [31:0]          inst,
  input [`DATA_WIDTH - 1 : 0] rs1_data,
  input [`DATA_WIDTH - 1 : 0] rs2_data,
  
  
  output logic rs1_r_ena,
  output logic [              4 : 0] rs1_r_addr,
  output logic                       rs2_r_ena,
  output logic [              4 : 0] rs2_r_addr,
  output logic                       rd_w_ena,
  output logic [              4 : 0] rd_w_addr,
  
  output logic [              4 : 0] inst_type,
  output logic [              7 : 0] inst_opcode,
  output logic [`DATA_WIDTH - 1 : 0] op1,
  output logic [`DATA_WIDTH - 1 : 0] op2
);

// logic [31:0] inst;
// assign inst = if_packet_out.inst;
// I-type
logic [6  : 0]opcode;
logic [4  : 0]rd;
logic [2  : 0]func3;
logic [4  : 0]rs1;
logic [11 : 0]imm;
assign opcode = inst[6  :  0];
assign rd     = inst[11 :  7];
assign func3  = inst[14 : 12];
assign rs1    = inst[19 : 15];
assign imm    = inst[31 : 20];

wire inst_addi =   ~opcode[2] & ~opcode[3] & opcode[4] & ~opcode[5] & ~opcode[6]
                 & ~func3[0] & ~func3[1] & ~func3[2];

// arith inst: 10000; logic: 01000;
// load-store: 00100; j: 00010;  sys: 000001
assign inst_type[4] = ( rst == 1'b1 ) ? 0 : inst_addi;

assign inst_opcode[0] = (  rst == 1'b1 ) ? 0 : inst_addi;
assign inst_opcode[1] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[2] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[3] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[4] = (  rst == 1'b1 ) ? 0 : inst_addi;
assign inst_opcode[5] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[6] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[7] = (  rst == 1'b1 ) ? 0 : 0;




assign rs1_r_ena  = ( rst == 1'b1 ) ? 0 : inst_type[4];
assign rs1_r_addr = ( rst == 1'b1 ) ? 0 : ( inst_type[4] == 1'b1 ? rs1 : 0 );
assign rs2_r_ena  = 0;
assign rs2_r_addr = 0;

assign rd_w_ena   = ( rst == 1'b1 ) ? 0 : inst_type[4];
assign rd_w_addr  = ( rst == 1'b1 ) ? 0 : ( inst_type[4] == 1'b1 ? rd  : 0 );

assign op1 = ( rst == 1'b1 ) ? 0 : ( inst_type[4] == 1'b1 ? rs1_data : 0 );
assign op2 = ( rst == 1'b1 ) ? 0 : ( inst_type[4] == 1'b1 ? { {52{imm[11]}}, imm } : 0 );


endmodule
