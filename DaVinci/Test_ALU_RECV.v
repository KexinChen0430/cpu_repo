/*
File Name   : Test_ALU_RECV.v
Description : RISC-V RV32I 算数逻辑单元 测试
Written By  : Tealer Guo
Data        : 2019/04/30
*/
`timescale 1ns/1ns
module Test_ALU_RECV;
	// reg reset;
	// reg enabl;,
	reg[9:0] alu_op;
	reg[4:0] ls_op;
	reg[4:0] j_op;
	reg[4:0] b_op;
	reg[31:0] pc_in;
	reg[31:0] rs1;
	reg[31:0] rs2;
	reg[31:0] address_imm;
	wire[31:0] rd;
	wire[31:0] pc_out;
	wire[31:0] address;

	ALU_RECV test_alu_recv(
		.alu_op(alu_op),
		.ls_op(ls_op),
		.j_op(j_op),
		.b_op(b_op),
		.pc_in(pc_in),
		.pc_out(pc_out),
		.address(address),
		.rs1(rs1),
		.rs2(rs2),
		.address_imm(address_imm),
		.rd(rd)
		);

	initial begin
		#0 alu_op=1000000001;ls_op={5{1'b1}};j_op={5{1'b1}};b_op={5{1'b1}};pc_in={32{1'b0}};rs1={{31{1'b0}},{1{1'b1}}};rs2={32{1'b0}};address_imm={{31{1'b0}},{1{1'b1}}}; // addi
		#5 alu_op={10{1'b1}};ls_op=5'b00011;j_op={5{1'b1}};b_op={5{1'b1}};pc_in={32{1'b0}};rs1={{28{1'b0}},4'b1101};rs2={32{1'b0}};address_imm={{31{1'b0}},{1{1'b1}}}; // lw
		#5 alu_op={10{1'b1}};ls_op={5{1'b1}};j_op=5'b00010;b_op={5{1'b1}};pc_in={{30{1'b0}},2'b11};rs1={32{1'b0}};rs2={32{1'b0}};address_imm={{31{1'b0}},{1{1'b1}}}; // jal
		#5 alu_op={10{1'b1}};ls_op={5{1'b1}};j_op={5{1'b1}};b_op=5'b00101;pc_in={{25{1'b0}},7'b1101100};rs1={{30{1'b0}},2'b11};rs2={{31{1'b0}},1'b1};address_imm={{26{1'b0}},6'b001001}; // bltu
		#5 alu_op={10{1'b1}};ls_op={5{1'b1}};j_op={5{1'b1}};b_op=5'b00101;pc_in={{25{1'b0}},7'b1101100};rs2={{30{1'b0}},2'b11};rs1={{31{1'b0}},1'b1};address_imm={{26{1'b0}},6'b001001}; // bltu
		#5 $finish;
	end

	initial begin
		$dumpfile("ALU_RECV.vcd");
		$dumpvars(0,Test_ALU_RECV);
	end

endmodule