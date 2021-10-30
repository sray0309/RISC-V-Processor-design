
//--xuezhen--

`include "sys_defs.svh"

module exe_stage(
  input                       rst,
  input [              4 : 0] inst_type_i,
  input [              7 : 0] inst_opcode,
  input [`DATA_WIDTH - 1 : 0] op1,
  input [`DATA_WIDTH - 1 : 0] op2,
  
  output logic [              4 : 0] inst_type_o,
  output logic [`DATA_WIDTH - 1 : 0] rd_data
);

assign inst_type_o = inst_type_i;

always_comb begin
  if( rst == 1'b1 )
  begin
    rd_data = `ZERO_WORD;
  end
  else
  begin
    case( inst_opcode )
	  `INST_ADD: begin rd_data = op1 + op2;  end
	  default:   begin rd_data = `ZERO_WORD; end
	endcase
  end
end



endmodule
