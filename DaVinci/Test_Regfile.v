/*
File Name   : Test_Regfile.v
Description : RISC-V RV32I 寄存器堆 测试
Written By  : Tealer Guo
Data        : 2019/04/20
*/
`timescale 1ns/1ns
module Regfile_test;
	reg State; // 1为读取,0为写入
	reg[4:0] reg_address;
	reg[31:0] reg_data_w;
	wire[31:0] reg_data;
	// 实例化
	Regfile regfile_test(
		.State(State),
		.address(reg_address),
		.data_w(reg_data_w),
		.data(reg_data)
	);
	// 测试循环
	initial
		begin
			#0 State=1;reg_address=00000;
			#5 State=0;reg_address=00001;reg_data_w=32'b11110000000000000000000000001111;
			#5 State=1;reg_address=00001;
			#5 State=0;reg_address=00000;reg_data_w=32'b11111111111111111111111111111111;
			#5 State=1;reg_address=00000;
			#5 $finish;
		end

	initial
		begin
			$dumpfile("Regfile.vcd");
			$dumpvars(0,Regfile_test);
		end
endmodule