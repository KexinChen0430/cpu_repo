/*
File Name   : ALU.v
Description : RISC-V RV32I 算数逻辑单元
Written By  : Tealer Guo
Data        : 2019/04/20
*/
module ALU(
	input[31:0] rs1_num,
	input[31:0] rs2_num,
	// ALU操作数
	input[9:0] alu_op,
	// 结果输出
	output[31:0] rd_num
);
	// 实例化模块
	ALU_sched schedule(
		.rs1_num(rs1_num),
		.rs2_num(rs2_num),
		.alu_op(alu_op),
		.rd_num(rd_num)
	);
endmodule
// ALU调度
module ALU_sched(
	input[31:0] rs1_num,
	input[31:0] rs2_num,
	input[9:0] alu_op,
	// 单个rd_num输出
	output[31:0] rd_num,
	// add
	input[31:0] add_rs1,
	input[31:0] add_rs2,
	output[31:0] A_add_rd,
	// sub
	input[31:0] sub_rs1,
	input[31:0] sub_rs2,
	output[31:0] S_sub_rd,
	// sll
	input[31:0] sll_rs1,
	input[31:0] sll_rs2,
	output[31:0] SLL_sll_rd,
	// slt
	input[31:0] slt_rs1,
	input[31:0] slt_rs2,
	output[31:0] SLT_slt_rd,
	// sltu
	input[31:0] sltu_rs1,
	input[31:0] sltu_rs2,
	output[31:0] SLTU_sltu_rd,
	// xor
	input[31:0] xor_rs1,
	input[31:0] xor_rs2,
	output[31:0] X_xor_rd,
	// srl
	input[31:0] srl_rs1,
	input[31:0] srl_rs2,
	output[31:0] SRL_srl_rd,
	// sra
	input[31:0] sra_rs1,
	input[31:0] sra_rs2,
	output[31:0] SRA_sra_rd,
	// or
	input[31:0] or_rs1,
	input[31:0] or_rs2,
	output[31:0] O_or_rd,
	// and
	input[31:0] and_rs1,
	input[31:0] and_rs2,
	output[31:0] AND_and_rd
);
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
	// 临时变量
	reg[31:0] rd_num_temp;
	// 多路选择器
	// add
	always @(*)
	begin
		if(alu_op===10'b0000000001)
			rd_num_temp=A_add_rd;
	end
	// sub
	always @(*)
	begin
		if(alu_op===10'b0000000010)
			rd_num_temp=S_sub_rd;
	end
	// sll
	always @(*)
	begin
		if(alu_op===10'b0000000011)
			rd_num_temp=SLL_sll_rd;
	end
	// slt
	always @(*)
	begin
		if(alu_op===10'b0000000101)
			rd_num_temp=SLT_slt_rd;
	end
	// sltu
	always @(*)
	begin
		if(alu_op===10'b0000000110)
			rd_num_temp=SLTU_sltu_rd;
	end
	// xor
	always @(*)
	begin
		if(alu_op===10'b0000000111)
			rd_num_temp=X_xor_rd;
	end
	// srl
	always @(*)
	begin
		if(alu_op===10'b0000001000)
			rd_num_temp=SRL_srl_rd;
	end
	// sra
	always @(*)
	begin
		if(alu_op===10'b0000001001)
			rd_num_temp=SRA_sra_rd;
	end
	// or
	always @(*)
	begin
		if(alu_op===10'b0000001010)
			rd_num_temp=O_or_rd;
	end
	// and
	always @(*)
	begin
		if(alu_op===10'b0000001011)
			rd_num_temp=AND_and_rd;
	end
	// 提交临时变量
	assign rd_num=rd_num_temp;
endmodule
// 加法
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
	output[31:0] slt_rd
);
	// 临时变量
	reg[31:0] slt_rd_temp;
	// MUX
	always @(*)
	begin
		if(slt_rs1<slt_rs2)
			slt_rd_temp=32'b11111111111111111111111111111111;
		else begin
			slt_rd_temp=32'b00000000000000000000000000000000;
		end
	end
	// 提交临时变量
	assign slt_rd=slt_rd_temp;
endmodule
// 无符号小于则置位
module sltu_32(
	input[31:0] sltu_rs1,
	input[31:0] sltu_rs2,
	output[31:0] sltu_rd
);
	// 临时变量
	reg[31:0] sltu_rd_temp;
	// MUX
	always @(*)
	begin
		if(sltu_rs1[30:0]<sltu_rs2[30:0])
			sltu_rd_temp=32'b11111111111111111111111111111111;
		else begin
			sltu_rd_temp=32'b00000000000000000000000000000000;
		end
	end
	// 提交临时变量
	assign sltu_rd=sltu_rd_temp;
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