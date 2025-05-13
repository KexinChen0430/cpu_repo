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

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:24:53 01/25/2011
// Design Name:   risc32_core
// Module Name:   D:/Xilinx/Designs/Risc32/risc32_test.v
// Project Name:  Risc32
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: risc32_core
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module risc32_test;

	// Inputs
	reg clk;
	reg reset;
	reg interrupt;
	wire interrupt_ack;
	reg [7:0] inport;
	wire [ 31 : 0 ] instruction;

	// Outputs
	wire [31:0] outport;
	wire halt;
	wire [ 31 : 0 ] address;
	
	// decls
	localparam T = 20;	// time period for clock, 20ns = 50 Mhz

	// Instantiate the Unit Under Test (UUT)
	risc32_core uut (
		.clk(clk), 
		.reset(reset), 
		.interrupt(interrupt),
		.interrupt_ack(interrupt_ack),
		.address(address),
		.instruction(instruction),
		.inport(inport), 
		.outport(outport), 
		.halt(halt)
	);

	// instruction ROM
//	risc_rom rom(.clk(clk), .address(address), .data(instruction));
	risc_rom rom(.address(address), .data(instruction));
	
	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 1;
		interrupt = 0;
		inport = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		reset = 0;

		#3000;
		reset = 1;
		$stop;
	end
  
	// Clock signal
	always
	begin
		clk = 1'b1;
		#(T/2);
		
		clk = 1'b0;
		#(T/2);
	end
	
endmodule

