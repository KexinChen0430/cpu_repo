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
	//  Hazards :   TYPE 1    EXECUTION HAZARDS
	//		EX/MEM.REGISTER RD = =  ID/EX.REGISTER RS
	//		EX/MEM.REGISTER RD = =  ID/EX.REGISTER RT
	//  Hazards :   TYPE 2    MEMORY HAZARDS
	//		MEM/WB.REGISTER RD = =  ID/EX.REGISTER RS
	//		MEM/WB.REGISTER RD = =  ID/EX.REGISTER RT
						// 1= Stall 0= Not stall
						// Nop = 1 controls deasserted , Control encoding = 6'd63 = 6'b111111
	//
// if writing destination for one instruction after execution is same as reading source of consequent instruction. 
// Also checking if the regiter write control is active or not.
// Hazard occurs only if execution writes to register.