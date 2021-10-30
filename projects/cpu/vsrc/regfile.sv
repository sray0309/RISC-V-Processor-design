
`include "defines.sv"

module regfile(
    input 	clk,
	input 	rst,
	
	input  [			   4 : 0] 	w_addr,
	input  [  `DATA_WIDTH -1 : 0] 	w_data,
	input 		  					w_ena,
	
	input  [               4 : 0] 	r_addr1,
	input  		  					r_ena1,
	input  [			   4 : 0] 	r_addr2,
	input  					 		r_ena2,
	
	output logic   [`DATA_WIDTH - 1 : 0] r_data1,
	output logic   [`DATA_WIDTH - 1 : 0] r_data2
    );

    // 32 registers
	logic [`DATA_WIDTH - 1 : 0] regs[31:0];
	
	always_ff @(posedge clk) 
	begin
		if ( rst == 1'b1 ) 
		begin
			for (int i = 0; i<32; i++) begin
				regs[i] <= `ZERO_WORD;
			end
		end
		else 
		begin
			if ((w_ena == 1'b1) && (w_addr != 5'h00))	
				regs[w_addr] <= w_data;
		end
	end
	
	always_comb begin
		if (rst == 1'b1)
			r_data1 = `ZERO_WORD;
		else if (r_ena1 == 1'b1)
			r_data1 = regs[r_addr1];
		else
			r_data1 = `ZERO_WORD;
	end
	
	always_comb begin
		if (rst == 1'b1)
			r_data2 = `ZERO_WORD;
		else if (r_ena2 == 1'b1)
			r_data2 = regs[r_addr2];
		else
			r_data2 = `ZERO_WORD;
	end

endmodule
