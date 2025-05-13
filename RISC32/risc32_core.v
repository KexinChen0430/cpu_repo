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
// Create Date:    10:35:45 01/24/2011 
// Design Name: 
// Module Name:    risc32_core 
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

module risc32_core(
		input wire clk, reset,					// standard signals
		input wire interrupt,					// external interrupt input
		output wire interrupt_ack,				// external interrupt acknowledge output
		output wire [ 31 : 0 ] address,		// external address line
		input wire [ 31 : 0 ] instruction,	// instruction data input
		input wire [ 7 : 0 ] inport,			// input port to the processor
		output wire [ 31 : 0 ] outport,		// output port from the processor
		output reg halt							// Processor panic/halted due to fatal error
    );

	`include "d:\xilinx\designs\risc32\opcodes.vh"

	// Define config constants
	localparam WORD_SIZE		= 32;						// native processor word size in bits
	localparam GPR_COUNT 	= 32;						// number of GPR registers
	localparam RAM_SIZE		= 10;						// 2^n bytes of SRAM, 1 Kbytes
	localparam FLASH_SIZE	= 10;						// 2^n bytes of instruction memory, 1 Kbytes

	localparam TRUE			= 1'b1;
	localparam FALSE			= 1'b0;
	
	// Define the cycle states of our cpu, i.e. the Control Unit states
	localparam state_fetch 		= 3'b000;			// fetch next instruction from memory
	localparam state_decode 	= 3'b001;			// decode instruction into opcode and operands
	localparam state_execute	= 3'b010;			// execute the instruction inside the ALU
	localparam state_mem			= 3'b011;			// perform memory accesses (LD/ST)
	localparam state_store 		= 3'b100;			// store the result back to memory
	localparam state_wait		= 3'b101;			// no store
	localparam state_unused1 	= 3'b110;			// reserved
	localparam state_unused2	= 3'b111;			// reserved
	
	// initial state of status register flags
	localparam MSR_INIT = 0;
	localparam RESET_VECTOR = 0;
	
	//
	// Control Unit registers
	//

   // The control unit sequencer cycles through fetching the next instruction
   // from memory, decoding the instruction into the opcode and operands and
   // executing the opcode in the ALU.
	reg [ 2:0 ] current_state;
	reg [ 2:0 ] next_state;
	
	// Define STATUS bits
	localparam C 	= 0;
	localparam DC 	= 1;
	localparam Z 	= 2;
	localparam PD	= 3;
	localparam TO	= 4;
	localparam RP0	= 5;
	localparam RP1	= 6;
	localparam IRP	= 7;
	
	//====================================
	// Internal Processor Registers
	//====================================

	// the Machine Status Register contains the current condition codes
	reg [ WORD_SIZE - 1 : 0 ] MSR;
	
	// instruction register
	reg [ WORD_SIZE - 1 : 0 ] IR;

	// 6 bits of opcode
	reg [ 5 : 0 ] OPCODE;
	
	// 5 bits of destination register
	reg [ 4 : 0 ] Rs, Rt, Rd;

	// A and B operand registers
	reg [ WORD_SIZE - 1 : 0 ] A;
	reg [ WORD_SIZE - 1 : 0 ] B;

	//
	reg [ WORD_SIZE - 1 : 0 ] ALUOutput;
	
	// 26-bit address
	reg [ 25 : 0 ] Addr;
	
	// sign-extended 16-bit immediate value
	reg [ WORD_SIZE - 1 : 0 ] IMM;

	//====================
	// Pipeline registers
	//====================
	reg [ WORD_SIZE - 1 : 0 ] NPC;	// next program counter
	reg [ WORD_SIZE - 1 : 0 ] LMD;	// load memory data
	
	
	//======================
	// Define memory spaces
	//======================
	
	// Instruction Memory
	reg [ WORD_SIZE - 1 : 0 ] FLASH[ 2 ** FLASH_SIZE - 1 : 0 ];
	
	// The processor has a set of General Purpose Registers
	reg [ WORD_SIZE - 1 : 0 ] GPR[ GPR_COUNT - 1 : 0 ];
	
	// Processor RAM
	reg [ WORD_SIZE - 1 : 0 ] SRAM [ 2 ** RAM_SIZE - 1 : 0 ];
	
	//================================================================
	// At each clock cycle we sequence the Control Unit.  Or if reset
	// is asserted we keep the cpu in reset.
	//================================================================
	always @ (posedge clk, posedge reset)
	begin
		if (reset)
			begin
				// reset internal processor states
				current_state <= state_fetch;

				// execution begins at the reset vector
				GPR[PC] 	= RESET_VECTOR;
				GPR[SP] 	= 0;
				GPR[LR]	= 0;
				GPR[0]	= 0;	// ensure R0 contains 0
				MSR 		<= MSR_INIT;

				halt 		<= FALSE;
			end
		else
			begin	
				
				//==========================================
				// Sequence our Control Unit
				//==========================================
				case( current_state )
					
					//
					// fetch instruction from instruction memory
					//
					state_fetch: 
					begin
						// Fetch the current instruction
						IR = instruction;
//						IR <= FLASH[ GPR[ PC ] ];
						
						// increment program counter to point to next instruction
						NPC = GPR [ PC ] + 4;
						
						next_state = state_decode;
					end

					//
					// decode instruction opcode and operatnds
					//
					state_decode:
					begin
						// Type -31-                                 format (bits)                                 -0- 
						// R opcode (6) rs (5) rt (5) rd (5) shamt (5) funct (6) 
						// I opcode (6) rs (5) rt (5) immediate (16) 
						// J opcode (6) address (26) 

						//
						//
						// decode the instruction
						OPCODE 	<= IR[ 31 : 26 ];				// 6 bits of opcode
						Rs			<= IR[ 25 : 21 ];				// 5 bits of Rs operand register 25:21
						Rt			<= IR[ 20: 16 ];				// 5 bits of Rt operand register 20:16
						Rd	 		<= IR[ 15 : 11 ];				// 5 bits of Rd destination register 15:11
						A			<= GPR[ IR[ 25 : 21 ] ];	// 5 bits of Rs operand register 25:21
						B			<= GPR[ IR[ 20: 16 ] ];		// 5 bits of Rt operand register 20:16
						Addr		<= IR[ 25 : 0 ];				// 26-bit address
	
						// sign extend the immediate value to 32 bits
						IMM 		<= { {16{IR[15]}}, IR[ 15 : 0 ] };				// 16 bits of offset/imm data
						
						next_state = state_execute;
					end
					
					//
					// perform ALU operations
					//
					state_execute:
					begin
						case(OPCODE)
							OP_NOP:
							begin
								// do nothing!
							end
							
							OP_ADD:
							begin
								{MSR[C], ALUOutput} = A + B;
								MSR[Z] = ALUOutput == 0 ? TRUE : FALSE;
							end
							
							OP_SUB:
							begin
								{MSR[C], ALUOutput} = A - B;
								MSR[Z] = ALUOutput == 0 ? TRUE : FALSE;
							end

							OP_LD:
							begin
								// calculate effective address
								ALUOutput = A + IMM;
							end
							
							OP_LDI:
							begin
								ALUOutput = IMM;
							end
							
							OP_ST:
							begin
								ALUOutput = Rd;
							end
							
							OP_GOTO:
							begin
								ALUOutput = NPC + (IMM << 2);
							end
							
							OP_CALL:
							begin
							end
							
							OP_RET:
							begin
							end
							
							default:
							begin
								halt <= TRUE;
							end
							
						endcase
						
						next_state = state_mem;
					end
					
					//
					// perform memory accesses
					//
					state_mem:
					begin
						// update the program counter
						GPR[PC] = NPC;

						case(OPCODE)
							OP_LD:
							begin
								LMD = SRAM[ALUOutput];
							end
							
							OP_ST:
							begin
								SRAM[ALUOutput] = B;
							end
							
							OP_GOTO:
							begin
								GPR[PC] = ALUOutput;
							end
							
						endcase

						next_state = state_store;
					end
					
					//
					// write-back 
					//
					state_store:
					begin
						case(OPCODE)
							
							OP_MTSR:
							begin
								MSR = B;
							end
							
							OP_MFSR:
							begin
								GPR[Rt] = MSR;
							end
							
							OP_ADD,
							OP_SUB:
							begin
								GPR[Rd] = ALUOutput;
							end
							
							OP_LD:
							begin
								GPR[Rt] = LMD;
							end

							OP_LDI:
							begin
								GPR[Rt] = ALUOutput;
							end
							
						endcase
							
						next_state = state_fetch;
					end
					
					//
					// 
					//
					state_wait:
					begin
						next_state = state_fetch;
					end
					
					//
					// invalid state!
					//
					default: 
					begin 
						halt <= TRUE;
					end
				endcase

			// move the control unit to the next state
			current_state <= next_state;
			end
	end
	
	// outputs
	assign address = GPR[PC];			// output the current PC
	assign outport = GPR[3];			// output R3 contents
	assign interrupt_ack = FALSE;
	
endmodule
