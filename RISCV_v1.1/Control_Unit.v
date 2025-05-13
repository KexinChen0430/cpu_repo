module Control_Unit(inst,BrEq,BrLt,BrUn,PCSel,immSel,ASel,BSel,ALUSel,MemRW,RegWEn,WBSel);
parameter DATA_LENGTH = 4;
parameter INST_LENGTH = 32;
parameter OUTPUT_LENGTH = 14;
parameter OPCODE_LENGTH = 7;


input [INST_LENGTH - 1:0] inst;
input BrEq,BrLt;

output reg [2:0] ALUSel, immSel;
output reg [1:0] WBSel;
output reg BrUn,PCSel,ASel,BSel,MemRW,RegWEn;

reg [OUTPUT_LENGTH-1:0] out;
reg [OPCODE_LENGTH-1:0] opcode;
reg [2:0] funct3; 

initial
begin 
end

always @(inst or BrEq or BrLt)
begin
opcode = inst[6:0];
funct3 = inst[14:12];

	case (opcode)
//R type
		7'b0110011:
		begin
			case(funct3)
			//add & sub
				3'b000:
				begin
					case(inst[30])
					//add
						1'b0: out = 14'b0_0_000_0_0_101_0_1_00;
					//sub
						1'b1: out = 14'b0_0_000_0_0_110_0_1_00;
					endcase
				end
			endcase
		end
		
		
//I type
	//kieu tinh toan
		7'b0010011:	
		begin
			case(funct3)
			//addi
				3'b000: out = 14'b0_0_001_0_1_101_0_1_00;
			//andi
				3'b111: out = 14'b0_0_001_0_1_000_0_1_00;
			endcase
		end
		
	//kieu load
		7'b0000011:
		begin
			case(funct3)
			//lw
				3'b010: out = 14'b0_0_001_0_1_101_0_1_01;
			endcase
		end
		
//B type
		7'b1100011:
		begin
			case(funct3)
			//beq
				3'b000:
				begin
					case(BrEq)
					//khong bang
						1'b0: out = 14'b0_0_010_1_1_101_0_0_00;
					// bang nhau 
						1'b1: out = 14'b0_1_010_1_1_101_0_0_00;
					endcase
				end
			//bne
				3'b001:
				begin
					case(BrEq)
					//khong bang
						1'b0: out = 14'b0_1_010_1_1_101_0_0_00;
					//bang nhau
						1'b1: out = 14'b0_0_010_1_1_101_0_0_00;
					endcase
				end
			//blt
				3'b100:
				begin
					case(BrLt)
					//lon hon
						1'b0: out = 14'b0_0_010_1_1_101_0_0_00;
					//nho hon
						1'b1: out = 14'b0_1_010_1_1_101_0_0_00;
					endcase
				end
			//bltu
				3'b110:
				begin
					case(BrLt)
					//lon hon
						1'b0: out = 14'b1_0_010_1_1_101_0_0_00;
					//nho hon
						1'b1: out = 14'b1_1_010_1_1_101_0_0_00;
					endcase
				end
			endcase
		end

//S type
		7'b0100011:
		begin
			case(funct3)
			//sw 
				3'b010: out = 14'b0_0_011_0_1_101_1_0_00;
			endcase
		end

//J type (jalr)
		7'b1100111:
		begin
			case(funct3)
			//jalr
				3'b000: out = 14'b0_1_111_0_1_101_0_1_10;
			endcase
		end
		
//J type (jal)
		7'b1101111: out = 14'b0_1_110_1_1_101_0_1_10;

	endcase
	
	{BrUn,PCSel,immSel,ASel,BSel,ALUSel,MemRW,RegWEn,WBSel} = out;
end 

endmodule 

