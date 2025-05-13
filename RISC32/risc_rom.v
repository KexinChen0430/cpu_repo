`timescale 1ns / 1ps

//
// This file is part of the RISC32 project
//
// Github: https://github.com/mseminatore/Risc32
//
// Copyright (c) 2018 Mark Seminatore
//
// Refer to the included LICENSE file for usage rights and restrictions
//

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:53:46 01/25/2011 
// Design Name: 
// Module Name:    risc_rom 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module risc_rom
	(
//		input wire clk,
		input wire [ 31 : 0 ] address,
		output reg [ 31 : 0 ] data
    );

	// include common decls for opcodes and registers
	`include "d:\xilinx\designs\risc32\opcodes.vh"
	
	//
//	reg [ 31 : 0 ] addr_reg;
	
//	always @(posedge clk)
//		addr_reg = address;

// Type -31-                                 format (bits)                                 -0- 
// R opcode (6) rs (5) rt (5) rd (5) shamt (5) funct (6) 
// I opcode (6) rs (5) rt (5) immediate (16) 
// J opcode (6) address (26) 
		
	always @*
		case (address)
			8'h00000000: data = {OP_LDI, R0, R3, 16'b1111111111111111 };				// LD R3, 1
			8'h00000004: data = {OP_LDI, R0, R1, 16'b0000000000000010 };				// LD R1, 2
			8'h00000008: data = {OP_LDI, R0, R2, 16'b0000000000000011 };				// LD R2, 3
			8'h0000000C: data = {OP_ADD, R1, R2, R3, 11'b0};							// add R3, R1, R2
			8'h00000010: data = {OP_SUB, R2, R1, R3, 11'b0};							// sub R3, R2, R1
			8'h00000014: data = {OP_GOTO, 26'b11111111111111111111111010};				// goto 0 (-6)
			default: data = 32'b0;
		endcase
endmodule
