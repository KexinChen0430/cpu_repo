/*
File Name   : Test_Decoder.v
Description : RISC-V RV32I 译码器 测试
Written By  : Tealer Guo
Data        : 2019/04/14
*/

`timescale 1ns/1ns
module decode_test;
	reg[31:0] instr;

	wire[6:0] type_code;
	wire[9:0] alu_op;
	wire[4:0] rs1;
	wire[4:0] rs2;
	wire[4:0] rd;

	decoder dec_test(
		.instr(instr),
		.type_code(type_code),
		.alu_op(alu_op),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd)
	);
	
	initial
		begin
			#0 instr=32'b01000000000100010000000110110011; // sub
			#5 instr=32'b00000000001000001110010010110011; // or
			#5 instr=32'b00000000110000111010000010110011; // slt
			#5 $finish;
		end

	initial
		begin
			$dumpfile("Decoder.vcd");
			$dumpvars(0,decode_test);
		end
endmodule