/*
File Name   : Test_DMemory.v
Description : RISC-V RV32I 数据存储器 测试
Written By  : Tealer Guo
Data        : 2019/04/21
*/
`timescale 1ns/1ns
module DMemory_test;
	reg Delete; // 1为删除
	reg State; // 0为写入，1为读取
	reg[31:0] data_w;
	reg[4:0] address;
	wire[31:0] data_r;
	// 实例化
	DMemory dmemory_test(
		.Delete(Delete),
		.State(State),
		.data_w(data_w),
		.address(address),
		.data_r(data_r)
	);
	// 测试循环
	initial
		begin
			#0 Delete=0;State=0;address=5'b00010;data_w=32'b11110000000000000000000000001111;
			#5 Delete=0;State=1;address=5'b00010;
			#5 Delete=1;address=5'b00010;
			#5 Delete=0;State=1;address=5'b00010;
			#5 $finish;
		end

	initial
		begin
			$dumpfile("DMemory.vcd");
			$dumpvars(0,DMemory_test);
		end
endmodule