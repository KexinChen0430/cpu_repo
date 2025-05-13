module PipelinedMIPS_tb();
	reg Clk,Rst;
	PipelinedMIPS  MIPS_CPU(Clk,Rst);
initial 
	begin
			Clk=1'b1;
			Rst=1'b0;
			#1 Rst=1'b1;
			forever #1 Clk=~Clk;
	end
initial
	begin
		$dumpfile("Test.vcd");
		$dumpvars(0,PipelinedMIPS_tb);
		#70 Rst=1'b0; $finish;
	end
endmodule
module PipelinedMIPS(Clk,Rst);
input Clk,Rst;
// Pipeline registers
reg  [ 63:0] IF_ID_pipereg; 
reg  [119:0] ID_EX_pipereg;
reg  [ 72:0] EX_MEM_pipereg;
reg  [ 70:0] MEM_WB_pipereg;
reg  [ 31:0] PC_reg;

wire [ 31:0] Instruction,inc4_PC,PCout,DO,PCin;
wire [ 31:0] data1,data2,writeData,Extdata;
wire [ 31:0] ALUresult,B,ImOffset,Offset_add;
wire [ 31:0] JuOffset32,JA_BA;// Jumpaddress/Branch Address
wire [ 27:0] JuOffset28;
wire [  7:0] ControlWire1;
wire [  3:0] ControlWire2;
wire [  5:0] opCode,opCode_nop;
wire [  4:0] writeReg,writeReg2,writeReg3;
wire [  4:0] rsSel,rtSel,rdSel,stall;
wire [  3:0] ALUCnt;
wire [  1:0] ALUOp;
wire [  1:0] ControlWire3;
wire 	     ALUsrc,regWrite,memWrite,memtoreg,memRead,regDst,branch,zero,PCsrc,jump,zero_eqdet,branch_zero;
wire 		 MEM_memRead,MEM_memWrite;
wire 		 flush,flushIF;// flushIF is the output of PipeControl, flush is output of HazUnit 
wire 		 nop,iMemError,dMemError,hazard;


assign memError = dMemError;	// Signal is high when cache miss occurs in ,Data Memory
										
	HazardUnit 			HazUnit 			(hazard,flush,writeReg ,writeReg2,rtSel,rsSel,ControlWire2[3],ControlWire2[0],ControlWire3[1],branch_zero,jump);
	pipeRegControl 		pipRegCntrl 		(nop,stall,flushIF,hazard,flush,dMemError,iMemError,MEM_memRead,MEM_memWrite,Clk,Rst); // Combinational as of now
	
always@(posedge Rst) 					
	begin 
		PC_reg= 32'd0;// At reset set PC to Address 32'd0 
		IF_ID_pipereg <= {6'd63,26'd0};//NOP
		 ID_EX_pipereg <={6'd63,180'd0}; // NOP
		 EX_MEM_pipereg<=108'd0;
		 MEM_WB_pipereg<= 71'd0;
  	end

always @(posedge Clk)
 	begin
 		if(stall[0]==1'b0)                   // Check for PC Stall
			PC_reg	<= PCin ;				// Update PC at Clock 1
		else
			PC_reg	<= PC_reg;				// Incase of a Stall do not update PC
end

//----------------------------------Instruction---Fetch--------------------------------------------------------------------------------------------------------

assign PCout=PC_reg;						// Wire connected to PC output

	Mux 					PCSelect 			(PCin,inc4_PC,JA_BA,PCsrc);// mux for PC value <= PC+4 or Branch/Jump Address
	InstructionMemoryFile 	InstructionMemory 	(iMemError,PC_reg,Instruction,Clk);	// 64 x 8 Bit Instruction Memory
	Add 			  		PCAddressIncrement	(inc4_PC,PCout,32'd4);		// Adder for PC + 4

always@(posedge Clk)
	begin 
		if(stall[1]==1'b0)					// Normal Pipeline
		 begin
			IF_ID_pipereg[31: 0] <= Instruction;		// Update Instruction to  IF_ID
			IF_ID_pipereg[63:32] <= inc4_PC;			// Updatw PC+4 address to IF_ID
		 end
	 	else
	 		IF_ID_pipereg	<= IF_ID_pipereg;

	 	if(flushIF==1'b1)
		 		IF_ID_pipereg 	<= {6'd63,26'd0};
	end

//----------------------------------Instruction---Decode---------------------------------------------------------------------------------------------------

assign rsSel  	 = IF_ID_pipereg[25:21];   //  Instruction's Rs Field
assign rtSel  	 = IF_ID_pipereg[20:16];	//	Instruction's Rt Field
assign rdSel  	 = IF_ID_pipereg[15:11];	//	Instruction's Rd Field
assign opCode 	 = IF_ID_pipereg[31:26];	//  OpCode for the Instruction first 6 bits
assign writeReg3 = MEM_WB_pipereg[68:64];   //  Destination register to be written in WB stage
assign JuOffset32={IF_ID_pipereg[63:60],JuOffset28};	// {PC+4[31:28], 28 bit shiftet jump address} Concatanates to 32 Bits Jump Address
assign PCsrc 	 =((branch && (zero_eqdet^IF_ID_pipereg[26])) || jump);  // Control signals branch,zero,jump are generated in ID stage sent to IF
assign ControlWire1	={ALUsrc,regWrite,memWrite,ALUOp,memtoreg,memRead,regDst};  // Control Signals Bundled together.
assign zero_eqdet= ~(|(data1^data2));
assign branch_zero= (branch&&(zero_eqdet^IF_ID_pipereg[26]));// Check for BNE/BEQ
// Detects if data in Rs and Rt is equal or not, Zero==1 if both data are equal 
	RegisterFile		Registers 			(data1,data2,rsSel,rtSel,writeReg3,writeData,Clk,Rst,MEM_WB_pipereg[70]);
// Register File has 32 GPRs, data1&2 are 32 bit data of selected registers,writeData is RD reg data,MEM_WB_pipereg[70] is the RegWrite Signal
	SignExt 			SignExtend 			(Extdata,IF_ID_pipereg[15:0]);
// Sign Extends Immediate value to 32 bits
	Shft2Jump 			Shiftby2Jump		(JuOffset28,IF_ID_pipereg[25:0]);
// Left Shifts 26 bit input by 2 bits making 28 bit output i.e. JuOffset28

	Shft2 				Shiftby2 			(ImOffset,Extdata); 
// Left Shifts Immediate sign extended data by 2 bits for offset address 
	Add  				ImmAddressAdder		(Offset_add,IF_ID_pipereg[63:32],ImOffset);
// Dedicated adder for adding the Offset and PC+4 for Immediate Address for Branching
	Mux 				JumpAddressSel 		(JA_BA,JuOffset32,Offset_add,branch);
// Decides to either Jump or Branch if Jump =1 Jump, If Jump=0,Branch=1,Check Zero if Z=1 Branch else No branching.
	Control 			CUnit 				(opCode_nop ,ALUsrc,regWrite,memWrite,ALUOp,memtoreg,memRead,regDst,branch,jump);			//Control decodes all the control signals
// opcode_nop is either 6 bit opcode or 6 bit Nop (6'd63)
	Mux6 				NOPinsert 			(opCode_nop,opCode,6'b111111,nop); 
// If nop == 1 means Insert NOP bubble in the EX stage

always@(posedge Clk)
	begin 
		if(stall[2]==1'b0)		//Normal Pipeline	
		 begin
			ID_EX_pipereg[ 31:  0] <= data1;			// Rs 32 bit data
			ID_EX_pipereg[ 63: 32] <= data2;			// Rt 32 bit data
			ID_EX_pipereg[ 95: 64] <= Extdata;			//Immediate Sign extended value
			ID_EX_pipereg[105: 96] <= {rtSel,rdSel};	// Rt and Rd for writeback stage
			ID_EX_pipereg[113:106] <= ControlWire1;		// Control wire1= {ALUsrc,regwrite,memwrite,ALUop1,ALUop0,memtoreg,memread,regdst}
			ID_EX_pipereg[119:114] <= opCode_nop;		// Instruction Opcode for Immediate Instructions (ADDI,SLTI)

		 end
		else// Stall the pipeline register and create a bubble for the Execution Stage
			if(nop==1'b1)
		 		ID_EX_pipereg			<=  {opCode_nop,ControlWire1,5'd0,5'd0,32'd0,32'd0,32'd0}; 
		 	else
		 		ID_EX_pipereg	<= ID_EX_pipereg;
				
	end

//----------------------------------EXECUTION STAGE-----------------------------------------------------------------------------------------------------------
				
assign ControlWire2={ID_EX_pipereg[112:111],ID_EX_pipereg[108:107]};//	{-,regwrite,memwrite,-,-,memtoreg,memread,-}

	ALU 			ALU0 					(Zero,ALUresult,ID_EX_pipereg[31:0],B,ALUCnt);		
//  Zero Flag is not used due to EQDT, ID_EX_pipereg[31:0] = RsData
	ALUControl 		ALU1 					(ALUCnt,ID_EX_pipereg[110:109],ID_EX_pipereg[69:64],ID_EX_pipereg[119:114]);
// 										(ALUCnt, 2 bit AluOp, 6 bit Funct, 6 bit ImmOpcode)
	Mux 			InputSelectALU 			(B,ID_EX_pipereg[63:32],ID_EX_pipereg[95:64],ID_EX_pipereg[113]); 	
// Mux for selecting the ALU input , B connects to ALU input,Rt data,Ext Data, [113] is AluSrc control wire
	Mux5 			RdRtSelRF 				(writeReg,ID_EX_pipereg[105:101],ID_EX_pipereg[100:96],ID_EX_pipereg[106]); 
// 5 bit Mux for selecting writeback stage's destination Rt or Rd , Reg Dst signal is [106]

always@(posedge Clk)
	begin
		if(stall[3]==1'b0)
		 begin
			EX_MEM_pipereg[ 31:  0] <= ALUresult;	// Alu output/Memory Address
			EX_MEM_pipereg[ 63: 32] <= ID_EX_pipereg[63:32]; // Rt.Data from Register File
			EX_MEM_pipereg[ 67: 64] <= ControlWire2;// Control wire2 = {regwrite,memwrite,memtoreg,memread}
			EX_MEM_pipereg[ 72: 68] <= writeReg;	// Register to be selected in writeback stage either rs or rt
		 end
		else
				EX_MEM_pipereg			<=EX_MEM_pipereg;
	end

//----------------------------------MEMORY STAGE-----------------------------------------------------------------------------------------------------------

assign MEM_memRead  = EX_MEM_pipereg[64];
assign MEM_memWrite = EX_MEM_pipereg[66];
assign ControlWire3 = {EX_MEM_pipereg[67],EX_MEM_pipereg[65]}; // regWrite, memtoreg
assign writeReg2    =  EX_MEM_pipereg[72:68];

	DataMemoryFile 			DataMemory 		(dMemError,DO,EX_MEM_pipereg[31:0],EX_MEM_pipereg[63:32],MEM_memWrite,MEM_memRead,Clk,Rst);
									//(ReadData,Address,WriteData,memWrite[66],memRead[64],Clk,Rst);

always@(posedge Clk)		// Writeback is done at Negedge
	begin
		if(stall[4]==1'b0)
		 begin
			MEM_WB_pipereg[ 31:  0]  <= DO;						// Memory read Data
			MEM_WB_pipereg[ 63: 32]  <= EX_MEM_pipereg[ 31: 0];	// ALU output
			MEM_WB_pipereg[ 68: 64]  <= writeReg2;  // Writeback register Select 
			MEM_WB_pipereg[ 70: 69]  <= ControlWire3;			// regWrite, memtoreg
		end
		else
			MEM_WB_pipereg		<= MEM_WB_pipereg;
	end
//----------------------------------WRITEBACK STAGE--------------------------------------------------------------------------------------------------------------------

	Mux 					MemorySelMux 			(writeData,MEM_WB_pipereg[31:0],MEM_WB_pipereg[63:32],MEM_WB_pipereg[69]);
// Mux for selecting writeback data 				(rd data  ,Memory Data 		   ,ALU Out ,			,	memtoreg)

endmodule

module pipeRegControl(nop,stall,flushIF,hazard,flush,dmemError,imemError,MEM_memRead,MEM_memWrite,Clk,Rst);
	
	output 	reg 	[4:0] 	stall;			// To stall different registers{WB,MEM,EX,ID,IF,PC}
	output 	reg 			nop;			// To introduce NOP bubble in pipeline
	output 					flushIF;		// To flush IF_ID_Pipereg

	input 					hazard,jump,branch,MEM_memWrite,MEM_memRead,dmemError,imemError;
	input					flush;		// Input from Hazard Unit
	input 					Clk,Rst;

	reg 			[1:0] 	State,nextState;
	wire 			[1:0]	hazType;
	wire 					dmemHaz,memHaz;

parameter normal  	= 2'b00;
parameter stall_1  	= 2'b01;
parameter stall_2	= 2'b10;

assign flushIF	= flush;
assign dmemHaz  = (dmemError && (MEM_memWrite||MEM_memRead)); // Checks if memory is accessed in Cache Miss
assign memHaz   = (dmemHaz || imemError ); // Instruction memory always gets accessed.
assign hazType  = {memHaz,((~memHaz)&&hazard)};
// Next state logic

always@(negedge Clk)
begin
	State <= {memHaz,((~memHaz)&&hazard)};
end

// Output Logic
always@(*)
	begin 
 	 case (State)	// State Decoder for the present state, gets updated at falling edge of clock
		normal:	// No Hazard EVERYTHING 	NORMAL
			begin
				nop 		<= 1'b0;
				stall[0]	<= 1'b0; 	//PC
	 			stall[1]	<= 1'b0;	//IF_ID
	 			stall[2]	<= 1'b0;	//ID_EX
	 			stall[3]	<= 1'b0;	//EX_MEM
	 			stall[4]	<= 1'b0;	//MEM_WB
			end
		stall_1:	// Stall IF and ID stages , insert bubble .STALL SOME, HAZARD HAS OCCURED
			begin
				nop 		<= 1'b1;
				stall[0]	<= 1'b1; 	//PC
	 			stall[1]	<= 1'b1;	//IF_ID
	 			stall[2]	<= 1'b0;	//ID_EX
	 			stall[3]	<= 1'b0;	//EX_MEM
	 			stall[4]	<= 1'b0;	//MEM_WB
	 		end
		stall_2:	// Stall IF,ID,EX,MEM ,WB, no bubble. STALL ALL, CACHE has MISSED
			begin
				nop 		<= 1'b0;
				stall[0]	<= 1'b1; 	//PC
	 			stall[1]	<= 1'b1;	//IF_ID
	 			stall[2]	<= 1'b1;	//ID_EX
	 			stall[3]	<= 1'b1;	//EX_MEM
	 			stall[4]	<= 1'b1;	//MEM_WB
	 		end
		default : // Normal
			begin
				nop 		<= 1'b0;
				stall[0]	<= 1'b0; 	//PC
	 			stall[1]	<= 1'b0;	//IF_ID
	 			stall[2]	<= 1'b0;	//ID_EX
	 			stall[3]	<= 1'b0;	//EX_MEM
	 			stall[4]	<= 1'b0;	//MEM_WB
			end
		endcase
	end
endmodule


// Main Controller
module Control(Instruction,ALUsrc,RegWrite,MemWrite,ALUOp,MemtoReg,MemRead,RegDst,Branch,Jump);

output 	reg ALUsrc,RegWrite,MemWrite,MemtoReg,MemRead,RegDst,Branch,Jump;
output [1:0] ALUOp;
input  [5:0] Instruction;

reg ALUOp1,ALUOp0;

assign ALUOp= {ALUOp1,ALUOp0};
	
	always@(Instruction)
	begin
		case(Instruction)
			6'b111111 :     // NOP
				begin
					RegDst 		<= 1'b1;
					ALUsrc 		<= 1'b0;
					MemtoReg	<= 1'b0;
					RegWrite 	<= 1'b0;
					MemRead 	<= 1'b0;
					MemWrite	<= 1'b0;
					Branch		<= 1'b0;
					Jump 		<= 1'b0;
					ALUOp1		<= 1'b1;
					ALUOp0		<= 1'b0;							
				end

			6'b000000 : 	// R  type  
				begin
					RegDst 		<= 1'b1;	
					ALUsrc 		<= 1'b0;
					MemtoReg	<= 1'b1;
					RegWrite 	<= 1'b1;
					MemRead 	<= 1'b0;
					MemWrite	<= 1'b0;
					Branch		<= 1'b0;
					Jump 		<= 1'b0;
					ALUOp1		<= 1'b1;
					ALUOp0		<= 1'b0;							
				end


			6'b001000 : 	// ADD Immediate 
				begin
					RegDst 		<= 1'b1;								
					ALUsrc 		<= 1'b1;
					MemtoReg	<= 1'b1;
					RegWrite 	<= 1'b1;
					MemRead 	<= 1'b0;
					MemWrite	<= 1'b0;
					Branch		<= 1'b0;
					Jump 		<= 1'b0;
					ALUOp1		<= 1'b1;
					ALUOp0		<= 1'b1;							
				end


			6'b001100 : 	// AND Immediate
				begin												
					RegDst 		<= 1'b1;
					ALUsrc 		<= 1'b1;
					MemtoReg	<= 1'b1;
					RegWrite 	<= 1'b1;
					MemRead 	<= 1'b0;
					MemWrite	<= 1'b0;
					Jump 		<= 1'b0;
					Branch		<= 1'b0;
					ALUOp1		<= 1'b1;
					ALUOp0		<= 1'b1;							
				end


			6'b001101 : 	// OR Immediate
				begin												
							RegDst 		<= 1'b1;
							ALUsrc 		<= 1'b1;
							MemtoReg	<= 1'b1;
							RegWrite 	<= 1'b1;
							MemRead 	<= 1'b0;
							MemWrite	<= 1'b0;
							Branch		<= 1'b0;
							Jump 		<= 1'b0;
							ALUOp1		<= 1'b1;
							ALUOp0		<= 1'b1;							
						end

						6'b000010 : 	// JUMP
						begin									
							RegDst 		<= 1'bx;
							ALUsrc 		<= 1'bx;
							MemtoReg	<= 1'bx;
							RegWrite 	<= 1'b0;
							MemRead 	<= 1'b0;
							MemWrite	<= 1'b0;
							Branch		<= 1'b0;
							Jump 		<= 1'b1;
							ALUOp1		<= 1'bx;
							ALUOp0		<= 1'bx;							
						end

						6'b001011 : 	// SLTI
						begin													
							RegDst 		<= 1'b1;
							ALUsrc 		<= 1'b1;
							MemtoReg	<= 1'b1;
							RegWrite 	<= 1'b1;
							MemRead 	<= 1'b0;
							MemWrite	<= 1'b0;
							Branch		<= 1'b0;
							Jump 		<= 1'b0;
							ALUOp1		<= 1'b1;
							ALUOp0		<= 1'b1;							
						end


						6'b100011 :	// LW
						begin
							RegDst 		<= 1'b0;
							ALUsrc 		<= 1'b1;
							MemtoReg	<= 1'b0;
							RegWrite 	<= 1'b1;
							MemRead 	<= 1'b1;
							MemWrite	<= 1'b0;
							Branch		<= 1'b0;
							Jump 		<= 1'b0;
							ALUOp1		<= 1'b0;
							ALUOp0		<= 1'b0;							
						end
						6'b101011 : // SW
						begin
							RegDst 		<= 1'bx;
							ALUsrc 		<= 1'b1;
							MemtoReg	<= 1'bx;
							RegWrite 	<= 1'b0;
							MemRead 	<= 1'b0;
							MemWrite	<= 1'b1;
							Branch		<= 1'b0;
							Jump 		<= 1'b0;
							ALUOp1		<= 1'b0;
							ALUOp0		<= 1'b0;
						end
					6'b000100 : // BEQ
						begin
							RegDst 		<= 1'bx;
							ALUsrc 		<= 1'b0;
							MemtoReg	<= 1'bx;
							RegWrite 	<= 1'b0;
							MemRead 	<= 1'b0;
							MemWrite	<= 1'b0;
							Branch		<= 1'b1;
							Jump 		<= 1'b0;
							ALUOp1		<= 1'b0;
							ALUOp0		<= 1'b1;
						end

					6'b000100 : // BNE   Modify
						begin
							RegDst 		<= 1'bx;
							ALUsrc 		<= 1'b0;
							MemtoReg	<= 1'bx;
							RegWrite 	<= 1'b0;
							MemRead 	<= 1'b0;
							MemWrite	<= 1'b0;
							Branch		<= 1'b1;
							Jump 		<= 1'b0;
							ALUOp1		<= 1'b0;
							ALUOp0		<= 1'b1;
						end
			default:
						begin
							RegDst 		<= 1'bx;
							ALUsrc 		<= 1'bx;
							MemtoReg	<= 1'bx;
							RegWrite 	<= 1'bx;
							MemRead 	<= 1'bx;
							MemWrite	<= 1'bx;
							Branch		<= 1'bx;
							Jump 		<= 1'bx;
							ALUOp1		<= 1'bx;
							ALUOp0		<= 1'bx;
						end
		endcase		
	end			
endmodule

// ALU Controller
module ALUControl(ALUCnt,AluOp,Funct,Imm);		// Takes in Instructions Funct field of 6 bits along with 2 bits of Alu Op decoded by Main Control
output reg 	[3:0] ALUCnt;
input  		[5:0] Funct,Imm;
input  		[1:0] AluOp;

	always@(AluOp,Funct)
		begin
		case(AluOp)
			2'b00 : // LW or SW either ways ALU performs add
				ALUCnt = 4'b0010;

			2'b01 : // BEQ Alu performs Subtraction
				ALUCnt = 4'b0110;

			2'b10 : // R-Type Funct defines ALU mode
				begin
					case(Funct)
						6'b000000 :  // SLL
							ALUCnt = 4'b1101;
						6'b100000 :	// ADD 
							ALUCnt = 4'b0010;
						6'b100010 : // SUB
							ALUCnt = 4'b0110;
						6'b100100 : // AND
							ALUCnt = 4'b0000;
						6'b100101 : // OR
							ALUCnt = 4'b0001;
						6'b101010 : // SLT
							ALUCnt = 4'b0111;
						default: 
							ALUCnt = 4'bZZZZ;
					endcase
				end
			endcase
		end
endmodule

module HazardUnit(hazard,flush,EX_Rd,MEM_Rd,ID_Rt,ID_Rs,EX_regWen,EX_memRead,MEM_regWen,branch,jump);

	output	reg			hazard;
	output  reg 		flush;
	input 		[4:0] 	EX_Rd,MEM_Rd,ID_Rs,ID_Rt;
	input       		EX_regWen,MEM_regWen,EX_memRead;
	input				branch,jump;


//CONTROL HAZARDS
always@(jump,branch)
	begin
		case(jump||branch)
			1'b0: flush <=1'b0;
			1'b1: flush <=1'b1;
			default: flush <=1'b0;
		endcase
	end

//assign flush 	= (jump||branch)?1'b1:1'b0;		// Flush the IF stage if branching/jumping

// DATA HAZARDS
always@(*)
	begin	
		if(EX_regWen && ((EX_Rd != 5'd0)))			// Hazard for dependency in ID and EX stage	
		begin
			if((EX_Rd==ID_Rs)||(EX_Rd==ID_Rt))
				begin 
					hazard <= 1'b1;
				end
		end
		else if(MEM_regWen && ((MEM_Rd != 5'd0)))	// Hazard for dependency in ID and MEM stage
		begin	
			if((MEM_Rd==ID_Rs)||(MEM_Rd==ID_Rt))
				begin
					hazard <= 1'b1;
				end
		end

		else if(EX_memRead && ((EX_Rd != 5'd0)))	// Load after a Store
		begin
			if((EX_Rd==ID_Rs)||(EX_Rd==ID_Rt))
				begin
					hazard <= 1'b1;
				end
		end
		else
				begin
					hazard <= 1'b0;
				end

	end  
endmodule

module ALU(Zero,ALUresult,A,B,AluOp);
output			Zero;
output	reg	[31:0]	ALUresult; 
input  		[31:0]	A,B;
input 		[ 3:0]	AluOp;

assign Zero = (ALUresult==0);

always@(AluOp,A,B)
	begin
		case (AluOp)
			4'b0000 : ALUresult<= A&B;   	 	//AND
			4'b0001 : ALUresult<= A|B;		//OR
			4'b0010 : ALUresult<= A+B;			//ADD
			4'b0110 : ALUresult<= A-B;		//SUB
			4'b0111 : ALUresult<= (A<B)?1:0;	// SLT
			4'b1100 : ALUresult<= ~(A|B);	//NOR

			4'b1101 : ALUresult<= A<<B; 	//sll
			4'b1110 : ALUresult<= A>>B;			//srl
			4'b1000 : ALUresult<= A>>>B;	//sra

			default : ALUresult <=0;
		endcase
	end
endmodule

module Add(Result,A,B);
	output  reg [31:0] Result;
	input 		[31:0] A,B;

	initial begin Result=32'd0; end

always @(A,B)
begin
	Result=A+B;
end
endmodule

module DataMemoryFile(DMemError,ReadData,Address,WriteData,memWrite,memRead,Clk,Rst);

	output      [31:0] 	ReadData;
	output reg 		   	DMemError;	// Cache MISS

	input 		[31:0] 	Address;
	input 		[31:0] 	WriteData;
	input 	    	 	Clk,memWrite,memRead,Rst;

	reg        [7:0] dataMem [0:63];  //8x64 Bits = 64 Byte memory

	wire 		[31:0] ReadData1;

	initial begin $readmemh("Data_Memory.txt",dataMem);  DMemError=1'b0; end
	initial begin #7 DMemError=1'b1;#8 DMemError=1'b0; end // introduces a cache miss

	assign ReadData  =(DMemError)?32'hBAD0DADA:ReadData1;
	
	assign ReadData1 =(memRead)?{dataMem[Address+2'b11],dataMem[Address+2'b10],dataMem[Address+2'b01],dataMem[Address]}:32'hZZZZZZZZ;
				// Scoops 4 8 bit memory locations at a time in Little Endian
	always @(posedge Clk) 
	begin
		if(memWrite)
			{dataMem[Address+2'b11],dataMem[Address+2'b10],dataMem[Address+2'b01],dataMem[Address]} <= WriteData;// Writes 4 bytes
	end
endmodule

module RegisterFile(data1,data2,read1,read2,writeReg,writeData,Clk,Rst,regWen);
	output      [31:0] data1,data2;
	input 		[31:0] writeData;
	input      	[ 4:0] read1,read2,writeReg;
	input 	    	  Clk,regWen,Rst;

	reg       	 [31:0] registerbank [0:31];

	always @(posedge Clk) 
	begin
		if(~Rst) 
			begin
			 	$readmemh("Register_File.txt",registerbank);
			 end
	end
	

	assign data1 = registerbank[read1] ;
	assign data2 = registerbank[read2];

	always @(negedge Clk) 
	begin
			registerbank[0] <= 32'd0;
		if(regWen)
			registerbank[writeReg] <= writeData;
	end
endmodule

module InstructionMemoryFile(IMemError,Address,Data,Clk);
	output      [31:0] 	Data;
	output reg 			IMemError;		// Cache MISS Flag
	input 		[31:0]	Address;
	input 	    	  	Clk,Rst;

	reg        	[ 7:0] 	imembank [0:63];  //  8x64  64B memory

initial begin $readmemh("Instruction_Memory.txt",imembank); IMemError=1'b0; end // Multiple test cases for jump branch dependencies
//initial begin $readmemh("Instruction_Memory(old).txt",imembank); end // Basic Program

	assign Data = {imembank[Address+3'b11],imembank[Address+2'b10],imembank[Address+2'b01],imembank[Address]} ;

endmodule

module Mux(Out,I0,I1,Sel);

output [31:0] Out;
input  [31:0] I0,I1;
input  Sel;

assign Out=(~Sel)?I0:I1;

endmodule

module Mux5(Out,I0,I1,Sel);

output [4:0] Out;
input  [4:0] I0,I1;
input  Sel;

assign Out=(~Sel)?I0:I1;

endmodule

module Mux6(Out,I0,I1,Sel);

output [5:0] Out;
input  [5:0] I0,I1;
input  Sel;

assign Out=(~Sel)?I0:I1;

endmodule

module SignExt(Out,In);

output [31:0] Out;
input  [15:0] In;

assign Out=In[15]?{16'hFFFF,In}:{16'h0000,In};

endmodule

module Shft2(Out,In);

output [31:0] Out;
input  [31:0] In;

assign Out={In[29:0],2'b00};

endmodule

module Shft2Jump(Out,In);

output [27:0] Out;
input  [25:0] In;

assign Out={In[25:0],2'b00};

endmodule