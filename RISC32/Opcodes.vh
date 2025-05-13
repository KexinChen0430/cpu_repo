//
// This file is part of the RISC32 project
//
// Github: https://github.com/mseminatore/Risc32
//
// Copyright (c) 2018 Mark Seminatore
//
// Refer to the included LICENSE file for usage rights and restrictions
//

//=====================
// Instruction opcodes
//=====================
localparam OP_NOP 	= 6'b000000;
localparam OP_LDI	= 6'b000001;
localparam OP_LD 	= 6'b000010;
localparam OP_ST	= 6'b000011;
localparam OP_ADD 	= 6'b000100;
localparam OP_SUB 	= 6'b000101;
localparam OP_GOTO	= 6'b000110;
localparam OP_CALL	= 6'b000111;
localparam OP_RET	= 6'b001000;

localparam OP_PUSH	= 6'b110000;
localparam OP_POP	= 6'b110001;

localparam OP_MTSR	= 6'b100000;
localparam OP_MFSR	= 6'b100001;

//=======================
// Register declarations
//=======================
localparam R0 	= 5'b00000;
localparam R1 	= 5'b00001;
localparam R2 	= 5'b00010;
localparam R3 	= 5'b00011;
localparam R4 	= 5'b00100;
localparam R5 	= 5'b00101;
localparam R6 	= 5'b00110;
localparam R7 	= 5'b00111;
localparam R8 	= 5'b01000;
localparam R9 	= 5'b01000;
localparam R10  = 5'b01001;
localparam R11  = 5'b01010;
localparam R12  = 5'b01011;
localparam R13  = 5'b01100;
localparam R14  = 5'b01101;
localparam R15  = 5'b01010;
localparam R16  = 5'b01011;

//================================
// Define special GPR assignments
//================================
localparam LR	= 5'b11101;		// 29
localparam PC	= 5'b11110;		// 30
localparam SP	= 5'b11111;		// 31
