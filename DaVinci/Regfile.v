/*
File Name   : Regfile.v
Description : RISC-V RV32I 寄存器堆
Written By  : Tealer Guo
Data        : 2019/04/20
*/
module Regfile(
	input _Reset,
	input State, // 0为写入，1为读取
	input[4:0] address_1, // 目标地址
	input[4:0] address_2,
	input[31:0] data_w, // 要写入的数据
	output[31:0] data_1, // 读出的数据
	output[31:0] data_2
);
	// 32个32-bit寄存器
	reg[31:0] register[31:0];
	reg[31:0] data_1,data_2;
	// 初始化
	// integer i;
	// always @(*)
	// begin
	// 	if(_Reset===1)
	// 		begin
	// 			for(i=0;i<32;i=i+1)
	// 				register[i]<=0;
	// 		end
	// end
	initial
		begin
			register[0]=0;
		end
	//--------------------------------------------------------------
	//测试用
	initial
		begin
			register[1]=32'b00000000001000001110010010110011;
			register[2]=32'b00000000000100010000000110110011;
			register[7]=32'b00000000001010111101101010111111;
			register[12]=32'b00000000000000000111111010101011;
		end
	//----------------------------------------------------------------
	// 读取
	always @(*)
	begin
		if(State===1)
			data_1=register[address_1];
			data_2=register[address_2];
	end
	// 写入
	always @(*)
	begin
		// 防止写入0寄存器
		if(State===0&&address_1!=0)
			register[address_1]=data_w;
	end
endmodule