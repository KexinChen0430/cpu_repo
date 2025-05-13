/*
File Name   : DMemory.v
Description : RISC-V RV32I 数据存储器
Written By  : Tealer Guo
Data        : 2019/04/21
*/
module DMemory(
	input Delete, // 1为删除
	input State, // 0为写入，1为读取
	input[31:0] data_w, // 要写入的数据
	input[4:0] address, // 目标地址
	output[31:0] data_r // 读取的数据
);
	reg[31:0] data_in[31:0];
	reg[31:0] data_r;
	// 写入
	always @(*)
	begin
		if(State===0&&Delete!=1&&address!=0)
			data_in[address]=data_w;
	end
	// 读取
	always @(*)
	begin
		if(State===1&&Delete!=1)
			data_r=data_in[address];
	end
	// 删除
	always @(*)
	begin
		if(Delete===1)
			data_in[address]=0;
	end
endmodule