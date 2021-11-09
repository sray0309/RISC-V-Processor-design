
//--xuezhen--

`include "sys_defs.svh"
`include "ISA.svh"

module decoder(

	input IF_ID_PACKET if_packet,
	
	output ALU_OPA_SELECT opa_select,
	output ALU_OPB_SELECT opb_select,
	output DEST_REG_SEL   dest_reg, // mux selects
	output ALU_FUNC       alu_func,
	output logic rd_mem, wr_mem, cond_branch, uncond_branch,
	output logic csr_op,    // used for CSR operations, we only used this as 
	                        //a cheap way to get the return code out
	output logic halt,      // non-zero on a halt
	output logic illegal,    // non-zero on an illegal instruction
	output logic valid_inst  // for counting valid instructions executed
	                        // and for making the fetch stage die on halts/
	                        // keeping track of when to allow the next
	                        // instruction out of fetch
	                        // 0 for HALT and illegal instructions (die on halt)

);

  INST inst;
	logic valid_inst_in;
	
	assign inst          = if_packet.inst;
	assign valid_inst_in = if_packet.valid;
	assign valid_inst    = valid_inst_in & ~illegal;
	
	always_comb begin
		// default control values:
		// - valid instructions must override these defaults as necessary.
		//	 opa_select, opb_select, and alu_func should be set explicitly.
		// - invalid instructions should clear valid_inst.
		// - These defaults are equivalent to a noop
		// * see sys_defs.vh for the constants used here
		opa_select = OPA_IS_RS1;
		opb_select = OPB_IS_RS2;
		alu_func = ALU_ADD;
		dest_reg = DEST_NONE;
		csr_op = `FALSE;
		rd_mem = `FALSE;
		wr_mem = `FALSE;
		cond_branch = `FALSE;
		uncond_branch = `FALSE;
		halt = `FALSE;
		illegal = `FALSE;
		if(valid_inst_in) begin
			casez (inst) 
				`RV32_ADDI: begin
					dest_reg   = DEST_RD;
					opb_select = OPB_IS_I_IMM;
				end
				default: illegal = `TRUE;

		endcase // casez (inst)
		end // if(valid_inst_in)
	end // always


endmodule

module id_stage(
  input clk,
  input rst,
  input IF_ID_PACKET if_packet_out,
  input [`DATA_WIDTH - 1 : 0] rd_data,
  
  output logic [              7 : 0] inst_opcode,
  output logic [`DATA_WIDTH - 1 : 0] op1,
  output logic [`DATA_WIDTH - 1 : 0] op2
);

logic [`DATA_WIDTH - 1 : 0] rs1_data;
logic [`DATA_WIDTH - 1 : 0] rs2_data;

logic                       rs1_r_ena;
logic [              4 : 0] rs1_r_addr;
logic                       rs2_r_ena;
logic [              4 : 0] rs2_r_addr;
logic                       rd_w_ena;
logic [              4 : 0] rd_w_addr;

regfile Regfile(
  .clk(clk),
  .rst(rst),
  .w_addr(rd_w_addr),
  .w_data(rd_data),
  .w_ena(rd_w_ena),
  
  .r_addr1(rs1_r_addr),
  .r_data1(rs1_data),
  .r_ena1(rs1_r_ena),
  .r_addr2(rs2_r_addr),
  .r_data2(rs2_data),
  .r_ena2(rs2_r_ena)
);

logic [31:0] inst;
assign inst = if_packet_out.inst;
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

assign inst_opcode[0] = (  rst == 1'b1 ) ? 0 : inst_addi;
assign inst_opcode[1] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[2] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[3] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[4] = (  rst == 1'b1 ) ? 0 : inst_addi;
assign inst_opcode[5] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[6] = (  rst == 1'b1 ) ? 0 : 0;
assign inst_opcode[7] = (  rst == 1'b1 ) ? 0 : 0;




assign rs1_r_ena  = ( rst == 1'b1 ) ? 0 : inst_addi;
assign rs1_r_addr = ( rst == 1'b1 ) ? 0 : ( inst_addi == 1'b1 ? rs1 : 0 );
assign rs2_r_ena  = 0;
assign rs2_r_addr = 0;

assign rd_w_ena   = ( rst == 1'b1 ) ? 0 : inst_addi;
assign rd_w_addr  = ( rst == 1'b1 ) ? 0 : ( inst_addi == 1'b1 ? rd  : 0 );

assign op1 = ( rst == 1'b1 ) ? 0 : ( inst_addi == 1'b1 ? rs1_data : 0 );
assign op2 = ( rst == 1'b1 ) ? 0 : ( inst_addi == 1'b1 ? { {52{imm[11]}}, imm } : 0 );


endmodule
