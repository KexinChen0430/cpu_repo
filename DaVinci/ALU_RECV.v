/*
File Name   : ALU_RECV.v
Description : RISC-V RV32I 算数逻辑单元
Written By  : Tealer Guo
Data        : 2019/04/30
*/
module ALU_RECV(
	// input clk,
	// input reset,
	// input enable,
	input[9:0] alu_op,
	input[4:0] ls_op,
	input[4:0] j_op,
	input[4:0] b_op,
	input[31:0] pc_in,
	input[31:0] rs1,
	input[31:0] rs2,
	input[31:0] address_imm,
	output reg[31:0] rd,
	output reg[31:0] pc_out,
	output reg[31:0] address,
	///////////无关///////////
	// add
	output[31:0] A_add_rd,
	// sub
	output[31:0] S_sub_rd,
	// sll
	output[31:0] SLL_sll_rd,
	// slt
	output[31:0] SLT_slt_rd,
	// sltu
	output[31:0] SLTU_sltu_rd,
	// xor
	output[31:0] X_xor_rd,
	// srl
	output[31:0] SRL_srl_rd,
	// sra
	output[31:0] SRA_sra_rd,
	// or
	output[31:0] O_or_rd,
	// and
	output[31:0] AND_and_rd
	);
	// temp
	reg[31:0] rs1_num;
	reg[31:0] rs2_num;
	// MUX
	// alu_op
	always @* begin
		case(alu_op)
			10'b0000000001:begin
				rs1_num=rs1;
				rs2_num=rs2;
				rd=A_add_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b0000000010:begin
				rs1_num=rs1;
				rs2_num=rs2;
				rd=S_sub_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b0000000011:begin
				rs1_num=rs1;
				rs2_num=rs2;
				rd=SLL_sll_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b0000000101:begin
				rs1_num=rs1;
				rs2_num=rs2;
				rd=SLT_slt_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b0000000110:begin
				rs1_num=rs1;
				rs2_num=rs2;
				rd=SLTU_sltu_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b0000000111:begin
				rs1_num=rs1;
				rs2_num=rs2;
				rd=X_xor_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b0000001000:begin
				rs1_num=rs1;
				rs2_num=rs2;
				rd=SRL_srl_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b0000001001:begin
				rs1_num=rs1;
				rs2_num=rs2;
				rd=SRA_sra_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b0000001010:begin
				rs1_num=rs1;
				rs2_num=rs2;
				rd=O_or_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b0000001011:begin
				rs1_num=rs1;
				rs2_num=rs2;
				rd=AND_and_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			// i
			10'b1000000001:begin
				rs1_num=rs1;
				rs2_num=address_imm;
				rd=A_add_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b1000000010:begin
				rs1_num=rs1;
				rs2_num=address_imm;
				rd=S_sub_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b1000000011:begin
				rs1_num=rs1;
				rs2_num=address_imm;
				rd=SLL_sll_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b1000000101:begin
				rs1_num=rs1;
				rs2_num=address_imm;
				rd=SLT_slt_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b1000000110:begin
				rs1_num=rs1;
				rs2_num=address_imm;
				rd=SLTU_sltu_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b1000000111:begin
				rs1_num=rs1;
				rs2_num=address_imm;
				rd=X_xor_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b1000001000:begin
				rs1_num=rs1;
				rs2_num=address_imm;
				rd=SRL_srl_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b1000001001:begin
				rs1_num=rs1;
				rs2_num=address_imm;
				rd=SRA_sra_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b1000001010:begin
				rs1_num=rs1;
				rs2_num=address_imm;
				rd=O_or_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			10'b1000001011:begin
				rs1_num=rs1;
				rs2_num=address_imm;
				rd=AND_and_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
		endcase
	end
	// ls_op
	always @* begin
		case(ls_op)
			5'b00001:begin // lb
				rs1_num=rs1;
				rs2_num=address_imm;
				address=A_add_rd;
				rd={32{1'b0}};
				pc_out={32{1'b0}};
			end
			5'b00010:begin // lh
				rs1_num=rs1;
				rs2_num=address_imm;
				address=A_add_rd;
				rd={32{1'b0}};
				pc_out={32{1'b0}};
			end
			5'b00011:begin // lw
				rs1_num=rs1;
				rs2_num=address_imm;
				address=A_add_rd;
				rd={32{1'b0}};
				pc_out={32{1'b0}};
			end
			5'b00100:begin // lui
				rs2_num={{28{1'b0}},4'b1100};
				rs1_num=address_imm;
				rd=SLL_sll_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			5'b00101:begin // auipc
				rs1_num=pc_in;
				rs2_num=address_imm;
				rd=A_add_rd;
				address={32{1'b0}};
				pc_out={32{1'b0}};
			end
			5'b00110:begin // sb
				rs1_num=rs1;
				rs2_num=address_imm;
				address=A_add_rd;
				rd={32{1'b0}};
				pc_out={32{1'b0}};
			end
			5'b00111:begin // sh
				rs1_num=rs1;
				rs2_num=address_imm;
				address=A_add_rd;
				rd={32{1'b0}};
				pc_out={32{1'b0}};
			end
			5'b01000:begin // sw
				rs1_num=rs1;
				rs2_num=address_imm;
				address=A_add_rd;
				rd={32{1'b0}};
				pc_out={32{1'b0}};
			end
		endcase
	end
	// j_op
	always @* begin
		case(j_op)
			5'b00001:begin // jalr
				rs1_num=rs1;
				rs2_num=address_imm;
				pc_out=A_add_rd;
				rd=pc_in+4;
				address={32{1'b0}};
			end
			5'b00010:begin // jal
				rs1_num=pc_in;
				rs2_num=address_imm;
				pc_out=A_add_rd;
				rd=pc_in+4;
				address={32{1'b0}};
			end
		endcase
	end
	// b_op
	always @* begin
		case(b_op)
			5'b00001:begin // beg
				if(rs1==rs2) begin
					rs1_num=pc_in;
					rs2_num=address_imm;
					pc_out=A_add_rd;
					rd={32{1'b0}};
					address={32{1'b0}};
				end
			end
			5'b00010:begin // bne
				if(rs1!=rs2) begin
					rs1_num=pc_in;
					rs2_num=address_imm;
					pc_out=A_add_rd;
					rd={32{1'b0}};
					address={32{1'b0}};
				end
			end
			5'b00011:begin // blt
				if(rs1<=rs2) begin
					rs1_num=pc_in;
					rs2_num=address_imm;
					pc_out=A_add_rd;
					rd={32{1'b0}};
					address={32{1'b0}};
				end
			end
			5'b00100:begin // bge
				if(rs1>=rs2) begin
					rs1_num=pc_in;
					rs2_num=address_imm;
					pc_out=A_add_rd;
					rd={32{1'b0}};
					address={32{1'b0}};
				end
			end
			5'b00101:begin // bltu
				if(rs1[30:0]<=rs2[30:0]) begin
					rs1_num=pc_in;
					rs2_num=address_imm;
					pc_out=A_add_rd;
					rd={32{1'b0}};
					address={32{1'b0}};
				end
			end
			5'b00111:begin // bgeu
				if(rs1[30:0]>=rs2[30:0]) begin
					rs1_num=pc_in;
					rs2_num=address_imm;
					pc_out=A_add_rd;
					rd={32{1'b0}};
					address={32{1'b0}};
				end
			end
		endcase
	end
	// 实例化模块
	add_32 add_add(
		.add_rs1(rs1_num),
		.add_rs2(rs2_num),
		.add_rd(A_add_rd)
	);
	sub_32 sub_sub(
		.sub_rs1(rs1_num),
		.sub_rs2(rs2_num),
		.sub_rd(S_sub_rd)
	);
	sll_32 sll_sll(
		.sll_rs1(rs1_num),
		.sll_rs2(rs2_num),
		.sll_rd(SLL_sll_rd)
	);
	slt_32 slt_slt(
		.slt_rs1(rs1_num),
		.slt_rs2(rs2_num),
		.slt_rd(SLT_slt_rd)
	);
	sltu_32 sltu_sltu(
		.sltu_rs1(rs1_num),
		.sltu_rs2(rs2_num),
		.sltu_rd(SLTU_sltu_rd)
	);
	xor_32 xor_xor(
		.xor_rs1(rs1_num),
		.xor_rs2(rs2_num),
		.xor_rd(X_xor_rd)
	);
	srl_32 srl_srl(
		.srl_rs1(rs1_num),
		.srl_rs2(rs2_num),
		.srl_rd(SRL_srl_rd)
	);
	sra_32 sra_sra(
		.sra_rs1(rs1_num),
		.sra_rs2(rs2_num),
		.sra_rd(SRA_sra_rd)
	);
	or_32 or_or(
		.or_rs1(rs1_num),
		.or_rs2(rs2_num),
		.or_rd(O_or_rd)
	);
	and_32 and_and(
		.and_rs1(rs1_num),
		.and_rs2(rs2_num),
		.and_rd(AND_and_rd)
	);
endmodule
/////////////////////////实现//////////////////////////////
module add_32(
	input[31:0] add_rs1,
	input[31:0] add_rs2,
	output[31:0] add_rd
);
	assign add_rd=add_rs1+add_rs2;
endmodule
// 减法
module sub_32(
	input[31:0] sub_rs1,
	input[31:0] sub_rs2,
	output[31:0] sub_rd
);
	assign sub_rd=sub_rs1-sub_rs2;
endmodule
// 逻辑左移
module sll_32(
	input[31:0] sll_rs1,
	input[31:0] sll_rs2,
	output[31:0] sll_rd
);
	assign sll_rd=sll_rs1<<sll_rs2[4:0];
endmodule
// 小于则置位
module slt_32(
	input[31:0] slt_rs1,
	input[31:0] slt_rs2,
	output reg[31:0] slt_rd
);
	// MUX
	always @(*)
	begin
		if(slt_rs1<slt_rs2)
			slt_rd=32'b11111111111111111111111111111111;
		else begin
			slt_rd=32'b00000000000000000000000000000000;
		end
	end
endmodule
// 无符号小于则置位
module sltu_32(
	input[31:0] sltu_rs1,
	input[31:0] sltu_rs2,
	output reg[31:0] sltu_rd
);
	// MUX
	always @(*)
	begin
		if(sltu_rs1[30:0]<sltu_rs2[30:0])
			sltu_rd=32'b11111111111111111111111111111111;
		else begin
			sltu_rd=32'b00000000000000000000000000000000;
		end
	end
endmodule
// 异或
module xor_32(
	input[31:0] xor_rs1,
	input[31:0] xor_rs2,
	output[31:0] xor_rd
);
	assign xor_rd=xor_rs1^xor_rs2;
endmodule
// 逻辑右移
module srl_32(
	input[31:0] srl_rs1,
	input[31:0] srl_rs2,
	output[31:0] srl_rd
);
	assign srl_rd=srl_rs1>>srl_rs2[4:0];
endmodule
// 算数右移
module sra_32(
	input[31:0] sra_rs1,
	input[31:0] sra_rs2,
	output[31:0] sra_rd
);
	assign sra_rd=($signed(sra_rs1))>>>sra_rs2[4:0];
endmodule
// 或
module or_32(
	input[31:0] or_rs1,
	input[31:0] or_rs2,
	output[31:0] or_rd
);
	assign or_rd=or_rs1|or_rs2;
endmodule
// 与
module and_32(
	input[31:0] and_rs1,
	input[31:0] and_rs2,
	output[31:0] and_rd
);
	assign and_rd=and_rs1&and_rs2;
endmodule