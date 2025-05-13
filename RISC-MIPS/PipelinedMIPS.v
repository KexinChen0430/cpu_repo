`include "Register_File.v"
`include "Data_Memory_File.v"
`include "Instruction_Memory_File.v"
`include "Mux.v"
`include "SignExtension.v"
`include "ALU.v"
`include "Control.v"
`include "HazardUnit.v"
`include "PipelineRegisterController.v"

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
										//	(hazard,flush,EX_Rd,MEM_Rd,ID_Rt,ID_Rs,EX_regWen,EX_memRead,MEM_regWen,branch,jump);
	HazardUnit 			HazUnit 			(hazard,flush,writeReg ,writeReg2,rtSel,rsSel,ControlWire2[3],ControlWire2[0],ControlWire3[1],branch_zero,jump);
								//			(nop,stall,flushIF,hazard,flush,dmemError,imemError,MEM_memRead,MEM_memWrite,Clk,Rst);
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
	