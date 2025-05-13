
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

					6'b000101 : // BNE   Modify
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