/*
File Name   : IMemory.v
Description : RISC-V RV32I 指令存储器
Written By  : Tealer Guo
Data        : 2019/04/20
*/
module IMemory(
	input[31:0] address,
	output[31:0] instr
);
	// 从RAM读取指令到iMemorty未完成
	reg[31:0] instr1=32'b00000000001000001110010010110011; // or rs1:00001 rs2:00010 rd:01001
	reg[31:0] instr2=32'b01000000000100010000000110110011; // sub rs1:00010 rs2:00001 rd:00011
	reg[31:0] instr3=32'b00000000110000111010000010110011; // slt rs1:00111 rs2:01100 rd:00001

	reg[31:0] instr;
	// 根据AGU返回的地址取指令
	always @(*)
	begin
		if(address===0) begin
			instr=instr1;
		end
		else if(address===4) begin
			instr=instr2;
		end
		else if(address===8) begin
			instr=instr3;
		end
	end
endmodule