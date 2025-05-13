/*
File Name   : Test_Decoder_INST.v
Description : RISC-V RV32I 译码器 测试
Written By  : Tealer Guo
Data        : 2019/04/29
*/
`timescale 1ns/1ns
module Test_Decoder_INST;
	// reg clk;
	reg[31:0] inst;

	wire[9:0] alu_op;
	wire[4:0] rs1;
	wire[4:0] rs2;
	wire[4:0] rd;
	wire[31:0] address_imm;
	wire[4:0] ls_op;
	wire[4:0] j_op;
	wire[4:0] b_op;

	Decode_INST test_decode_inst(
		// .clk(clk),
		.inst(inst),
		.alu_op(alu_op),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.address_imm(address_imm),
		.ls_op(ls_op),
		.j_op(j_op),
		.b_op(b_op)
		);

	initial begin
		// clk预留
		// #0 clk=0;inst=32'b01000000000100010000000110110011; // sub
		// #5 clk=1;
		// #5 clk=0;inst=32'b00000000001000001110010010110011; // or
		// #5 clk=1;
		// #5 clk=0;inst=32'b00000000110000111010000010110011; // slt
		// #5 clk=1;
		// #5 clk=0;inst=32'b10000111011000001100110010010011; // ori
		// #5 clk=1;
		// #5 clk=0;inst=32'b00101010110100011000111100000011; // lb
		// #5 clk=1;
		// #5 clk=0;inst=32'b00010101110011100000000011100111; // jalr
		// #5 clk=1;
		// #5 clk=0;inst=32'b00010101110100010110000101101111; // jal
		// #5 clk=1;
		// #5 clk=0;inst=32'b10111111010001011111110010110111; // lui
		// #5 clk=1;
		// #5 clk=0;inst=32'b11101110111001001010111100010111; // auipc
		// #5 clk=1;
		// #5 clk=0;inst=32'b11100101100111000001000110100011; // sh
		// #5 clk=1;
		// #5 clk=0;inst=32'b11101010000111010110000101100011; // bltu
		// #5 clk=1;
		// #10 $finish;
		#0 inst=32'b01000000000100010000000110110011; // sub
		#5 inst=32'b00000000001000001110010010110011; // or
		#5 inst=32'b00000000110000111010000010110011; // slt
		#5 inst=32'b10000111011000001100110010010011; // ori
		#5 inst=32'b00101010110100011000111100000011; // lb
		#5 inst=32'b00010101110011100000000011100111; // jalr
		#5 inst=32'b00010101110100010110000101101111; // jal
		#5 inst=32'b10111111010001011111110010110111; // lui
		#5 inst=32'b11101110111001001010111100010111; // auipc
		#5 inst=32'b11100101100111000001000110100011; // sh
		#5 inst=32'b11101010000111010110000101100011; // bltu
		#5 $finish; 
	end

	initial begin
		$dumpfile("Decode_INST.vcd");
		$dumpvars(0,Test_Decoder_INST);
	end

endmodule