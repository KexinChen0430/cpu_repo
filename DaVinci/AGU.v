/*
File Name   : AGU.v
Description : RISC-V RV32I 地址生成单元
Written By  : Tealer Guo
Data        : 2019/04/20
*/
module AGU(
	input _Rest,
	input PCWre, // 为1时pc更改
	output[31:0] address
);
	// 生成地址
	reg[31:0] address;
	always @(*)
	begin
		if(_Rest===1)
			address=0;
		else if(PCWre) begin
			address=address+4;
		end
	end
endmodule