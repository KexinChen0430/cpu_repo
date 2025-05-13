/*
File Name   : Test_IMemory.v
Description : RISC-V RV32I 指令存储器 测试
Written By  : Tealer Guo
Data        : 2019/04/20
*/
`timescale 1ns/1ns
module IMemory_test;
	reg[31:0] address;
	wire[31:0] instr;

	IMemory imemory_test(
		.address(address),
		.instr(instr)
	);

	initial
		begin
			#0 address=0;
			#5 address=4;
			#5 address=8;
			#5 $finish;
		end

	initial
		begin
			$dumpfile("IMemory.vcd");
			$dumpvars(0,IMemory_test);
		end
endmodule