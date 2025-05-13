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