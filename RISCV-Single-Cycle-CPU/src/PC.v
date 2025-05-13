module JorU_PCandRD(
	input isJorU,
	input [1:0]  JUtype,
	input [31:0] old_PC, imm, rs1,
	output reg [31:0] rd, new_PC
);
parameter 
    is_jalr = 0, is_jal = 1, is_auipc = 2, is_lui = 3; 
always@(*)
begin
	if(isJorU)
		case(JUtype)
			is_jalr: begin //JALR
				rd = old_PC + 4; 
                new_PC = imm + rs1;
			end
            is_jal: begin //JAL
				rd = old_PC + 4;
				new_PC = old_PC + imm;
			end
			is_auipc: begin //AUIPC
				rd = old_PC + imm;
				new_PC = old_PC + 4;
			end
			is_lui: begin //LUI
				rd = imm;
				new_PC = old_PC + 4;
			end
		endcase
	else begin
		rd = 0;
		new_PC = 0;
	end
end
endmodule

/*module JorU_PCandRD(
	input isJorU, jalr,
	input [2:0]  op_first3,
	input [31:0] old_PC, imm, rs1,
	output reg [31:0] rd, new_PC
);
always@(*)
begin
	if(isJorU)
		case(op_first3)
			3'b110: begin 
                if(jalr)begin //JALR
                    rd = old_PC + 4;
                    new_PC = imm + rs1;
                end
                else begin //JAL
                    rd = old_PC + 4;
				    new_PC = old_PC + imm;
                end
            end
			3'b001: begin //AUIPC
				rd = old_PC + imm;
				new_PC = old_PC + 4;
			end
			2'b10: begin //LUI
				rd = imm;
				new_PC = old_PC + 4;
			end
		endcase
	else begin
		rd = 0;
		new_PC = 0;
	end
end
endmodule
*/
module PCSrc(
    input branch, Zero, isJorU,
    output reg [1:0]pc_src
);

reg must_branch;
always @(*) begin
    must_branch = branch & Zero;
    if(isJorU)
        pc_src = 2'b11;
    else if(must_branch)
        pc_src = 2'b01;
    else
        pc_src = 2'b10;
end
endmodule


module PCmux(
    input isJorU,
    input [1:0]pc_src,
    input [31:0]old_pc, imm, pc_fromJU,
    output reg [31:0]new_pc
);
always @(*) begin
    case (pc_src)
        2'b11:
            if(isJorU)
                new_pc = pc_fromJU;
            else
                new_pc = old_pc + 4;
        2'b10:
            new_pc = old_pc + 4;
        2'b01:
            new_pc = old_pc + imm;
        default: 
            new_pc = old_pc + 4;
    endcase

end
endmodule


module PC(
    input clk, instr_read,
    input [31:0] new_addr,
    output reg [31:0] PC_addr
);
initial
	PC_addr = 0;

always@(negedge clk)
    begin
        if(instr_read) begin
            PC_addr <= new_addr; 
        end
    end     
endmodule