/*
File Name   : Test_AGU.v
Description : RISC-V RV32I 地址生成单元 测试
Written By  : Tealer Guo
Data        : 2019/04/20
*/
`timescale 1ns/1ns
module AGU_test;
	reg _Rest;
	reg PCWre;
	wire[31:0] address;

	AGU ieu_test(
		._Rest(_Rest),
		.PCWre(PCWre),
		.address(address)
	);

	initial
		begin
			#0 _Rest=1;PCWre=0;
			#5 _Rest=0;PCWre=1;
			#5 _Rest=0;PCWre=0;
			#5 _Rest=0;PCWre=1;
			#5 _Rest=0;PCWre=0;
			#5 _Rest=0;PCWre=1;
			#5 _Rest=0;PCWre=0;
			#5 _Rest=0;PCWre=1;
			#5 _Rest=0;PCWre=0;
			#5 _Rest=0;PCWre=1;
			#5 $finish;
		end
	initial
		begin
			$dumpfile("AGU.vcd");
			$dumpvars(0,AGU_test);
		end
endmodule