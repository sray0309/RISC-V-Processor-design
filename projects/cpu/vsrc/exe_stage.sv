
//--xuezhen--

`include "sys_defs.svh"

module alu(
	input [`DATA_WIDTH-1:0] opa,
	input [`DATA_WIDTH-1:0] opb,
	ALU_FUNC     func,

	output logic [`DATA_WIDTH-1:0] result
);
	wire signed [`DATA_WIDTH-1:0] signed_opa, signed_opb;
	wire signed [2*`DATA_WIDTH-1:0] signed_mul, mixed_mul;
	wire        [2*`DATA_WIDTH-1:0] unsigned_mul;
	assign signed_opa = opa;
	assign signed_opb = opb;
	assign signed_mul = signed_opa * signed_opb;
	assign unsigned_mul = opa * opb;
	assign mixed_mul = signed_opa * opb;

	always_comb begin
		case (func)
			ALU_ADD:      result = opa + opb;
			ALU_SUB:      result = opa - opb;
			ALU_AND:      result = opa & opb;
			ALU_SLT:      result = signed_opa << signed_opb;
			ALU_SLTU:     result = opa << opb;
			ALU_OR:       result = opa | opb;
			ALU_XOR:      result = opa ^ opb;
			ALU_SRL:      result = opa >> opb[4:0];
			ALU_SLL:      result = opa << opb[4:0];
			ALU_SRA:      result = signed_opa >>> opb[4:0]; // arithmetic from logical shift
			ALU_MUL:      result = signed_mul[`DATA_WIDTH-1:0];
			ALU_MULH:     result = signed_mul[2*`DATA_WIDTH-1:`DATA_WIDTH];
			ALU_MULHSU:   result = mixed_mul[2*`DATA_WIDTH-1:`DATA_WIDTH];
			ALU_MULHU:    result = unsigned_mul[2*`DATA_WIDTH-1:`DATA_WIDTH];

			default:      result = `DATA_WIDTH'hfacebeec;  // here to prevent latches
		endcase
	end
endmodule // alu

module brcond(// Inputs
	input [`DATA_WIDTH-1:0] rs1,    // Value to check against condition
	input [`DATA_WIDTH-1:0] rs2,
	input  [2:0] func,  // Specifies which condition to check

	output logic cond    // 0/1 condition result (False/True)
);

	logic signed [`DATA_WIDTH-1:0] signed_rs1, signed_rs2;
	assign signed_rs1 = rs1;
	assign signed_rs2 = rs2;
	always_comb begin
		case (func)
			3'b000: cond = signed_rs1 == signed_rs2;  // BEQ
			3'b001: cond = signed_rs1 != signed_rs2;  // BNE
			3'b100: cond = signed_rs1 < signed_rs2;   // BLT
			3'b101: cond = signed_rs1 >= signed_rs2;  // BGE
			3'b110: cond = rs1 < rs2;                 // BLTU
			3'b111: cond = rs1 >= rs2;                // BGEU
      default: cond = 0;
		endcase
	end
	
endmodule // brcond

module exe_stage(
  input                       clk,
  input                       rst,
  input ID_EX_PACKET          id_packet_in,
  
  output EX_MEM_PACKET         ex_packet_out
);

  logic [`DATA_WIDTH-1 : 0] opa_mux_out;
  logic [`DATA_WIDTH-1 : 0] opb_mux_out;

  // opa mux
  always_comb begin
    opa_mux_out = `DATA_WIDTH'hdeadfbac;
    case (id_packet_in.opa_select)
			OPA_IS_RS1:  opa_mux_out = id_packet_in.rs1_value;
			OPA_IS_NPC:  opa_mux_out = id_packet_in.NPC;
			OPA_IS_PC:   opa_mux_out = id_packet_in.PC;
			OPA_IS_ZERO: opa_mux_out = 0;
		endcase
  end
  // opb mux

  always_comb begin
		case (id_packet_in.opb_select)
			OPB_IS_RS2: opb_mux_out = id_packet_in.rs2_value;
			OPB_IS_I_IMM: opb_mux_out = `RV64_signext_Iimm(id_packet_in.inst);
			OPB_IS_S_IMM: opb_mux_out = `RV64_signext_Simm(id_packet_in.inst);// double check?
			OPB_IS_B_IMM: opb_mux_out = `RV64_signext_Bimm(id_packet_in.inst);// double check?
			OPB_IS_U_IMM: opb_mux_out = `RV64_signext_Uimm(id_packet_in.inst);// double check?
			OPB_IS_J_IMM: opb_mux_out = `RV64_signext_Jimm(id_packet_in.inst);// double check?
      default: opb_mux_out = `DATA_WIDTH'hfacefeed;
    endcase 
	end
  alu alu(
    .opa(opa_mux_out),
    .opb(opb_mux_out),
    .func(id_packet_in.alu_func),
    .result(ex_packet_out.alu_result)
  );

  brcond brcond (
		.rs1(), 
		.rs2(),
		.func(),

		.cond()
	);

  assign ex_packet_out.NPC = id_packet_in.NPC;
  assign ex_packet_out.take_branch = 1'b0;
  assign ex_packet_out.rs2_value = id_packet_in.rs2_value;
  assign ex_packet_out.rd_mem = id_packet_in.rd_mem;
  assign ex_packet_out.wr_mem = id_packet_in.wr_mem;
  assign ex_packet_out.dest_reg_addr = id_packet_in.dest_reg_addr;
  assign ex_packet_out.halt = id_packet_in.halt;
  assign ex_packet_out.illegal = id_packet_in.illegal;
  assign ex_packet_out.csr_op = id_packet_in.csr_op;
  assign ex_packet_out.valid = id_packet_in.valid;
  assign ex_packet_out.mem_size = id_packet_in.inst.r.funct3; // double check?

endmodule
