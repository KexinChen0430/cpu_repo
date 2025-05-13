/*
File Name   : Decode_INST.v
Description : RISC-V RV32I 译码器
Written By  : Tealer Guo
Data        : 2019/04/29
*/
module Decode_INST(
		// input clk,
		input [31:0] inst,

		output reg[9:0] alu_op,
		output reg[4:0] rs1,
		output reg[4:0] rs2,
		output reg[4:0] rd,
		output reg[31:0] address_imm,
		output reg[4:0] ls_op,
		output reg[4:0] j_op,
		output reg[4:0] b_op
	);
	
	// clk预留
	reg[31:0] immr;

	always @* begin
		address_imm<=immr;
	end
	// always @(posedge clk) begin
	// 	address_imm<=immr;
	// end

	always @* begin
		case(inst[6:0])
			// R-type decoder
			7'b0110011:begin
			rs1=inst[19:15];
			rs2=inst[24:20];
			rd=inst[11:7];
			b_op={5{1'b1}};
			ls_op={5{1'b1}};
			j_op={5{1'b1}};
			immr={32{1'b0}};
				case(inst[31:25])
					7'b0000000:begin
						case(inst[14:12])
							3'b000:begin // add
								alu_op=10'b0000000001;
							end
							3'b001:begin // sll
								alu_op=10'b0000000011;
							end
							3'b010:begin // slt
								alu_op=10'b0000000101;
							end
							3'b011:begin // sltu
								alu_op=10'b0000000110;
							end
							3'b100:begin // xor
								alu_op=10'b0000000111;
							end
							3'b101:begin // srl
								alu_op=10'b0000001000;
							end
							3'b110:begin // or
								alu_op=10'b0000001010;
							end
							3'b111:begin // and
								alu_op=10'b0000001011;
							end
						endcase
					end
					7'b0100000:begin
						case(inst[14:12])
							3'b000:begin // sub
								alu_op=10'b0000000010;
							end
							3'b101:begin // sra
								alu_op=10'b0000001001;
							end
						endcase
					end
				endcase
			end
			// I-type decoder
			7'b0010011:begin
				rs1=inst[19:15];
				rs2={5{1'b0}};
				rd=inst[11:7];
				b_op={5{1'b1}};
				ls_op={5{1'b1}};
				j_op={5{1'b1}};
				case(inst[14:12])
					3'b000:begin // addi
						alu_op=10'b1000000001;
						immr={{20{inst[31]}},inst[31:20]};
					end
					3'b010:begin // slti
						alu_op=10'b1000000101;
						immr={{20{inst[31]}},inst[31:20]};
					end
					3'b011:begin // sltiu
						alu_op=10'b1000000110;
						immr={{20{inst[31]}},inst[31:20]};
					end
					3'b100:begin // xori
						alu_op=10'b1000000111;
						immr={{20{inst[31]}},inst[31:20]};
					end
					3'b110:begin // ori
						alu_op=10'b1000001010;
						immr={{20{inst[31]}},inst[31:20]};
					end
					3'b111:begin // andi
						alu_op=10'b1000001011;
						immr={{20{inst[31]}},inst[31:20]};
					end
				endcase
				// RV64I预留
				// slli,srli,srai高位处理
				case(inst[31:25])
					7'b0000000:begin
						case(inst[14:12])
							3'b001:begin // slli
								if(inst[24]==1'b0) begin
									alu_op=10'b1000000011;
									immr=inst[24:20];
								end
							end
							3'b001:begin // srli
								if(inst[24]==1'b0) begin
									alu_op=10'b1000001000;
									immr=inst[24:20];
								end
							end
							3'b101:begin // srai
								if(inst[24]==1'b0) begin
									alu_op=10'b1000001001;
									immr=inst[24:20];
								end
							end
						endcase
					end
				endcase
			end
			// I-type decoder
			// load
			7'b0000011:begin
				rs1=inst[19:15];
				rd=inst[11:7];
				rs2=inst[24:20];
				alu_op={10{1'b1}};
				ls_op={5{1'b1}};
				j_op={5{1'b1}};
				case(inst[14:12])
					3'b000:begin // lb
						immr={{20{inst[31]}},inst[31:20]};
						ls_op=5'b00001;
					end
					3'b001:begin // lh
						immr={{20{inst[31]}},inst[31:20]};
						ls_op=5'b00010;
					end
					3'b010:begin // lw
						immr={{20{inst[31]}},inst[31:20]};
						ls_op=5'b00011;
					end
					3'b100:begin // lbu
						immr={{20{1'b0}},inst[31:20]};
						ls_op=5'b00001;
					end
					3'b101:begin // lhu
						immr={{20{1'b0}},inst[31:20]};
						ls_op=5'b00010;
					end
				endcase
			end
			// I-type decoder
			7'b1100111:begin
				rs1=inst[19:15];
				rs2={5{1'b0}};
				rd=inst[11:7];
				alu_op={10{1'b1}};
				b_op={5{1'b1}};
				ls_op={5{1'b1}};
				// RV64I预留
				case(inst[14:12])
					3'b000:begin // jalr
						immr={{20{inst[31]}},inst[31:20]};
						j_op=5'b00001;
					end
				endcase
			end
			// I-type fence
			7'b0001111:begin
				// NULL
			end
			// I-type e/csr
			7'b1110011:begin
				// NULL
			end
			// J-type decoder
			7'b1101111:begin
				rs1={5{1'b0}};
				rs2={5{1'b0}};
				rd=inst[11:7];
				alu_op={10{1'b1}};
				b_op={5{1'b1}};
				ls_op={5{1'b1}};
				// jal
				immr={{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
				j_op=5'b00010;
			end
			// U-type decoder
			7'b0110111:begin
				rs1={5{1'b0}};
				rs2={5{1'b0}};
				rd=inst[11:7];
				alu_op={10{1'b1}};
				j_op={5{1'b1}};
				b_op={5{1'b1}};
				//lui
				immr={{12{inst[31]}},inst[31:12]};
				ls_op=5'b00100;
			end
			// U-type decoder
			7'b0010111:begin
				rs1={5{1'b0}};
				rs2={5{1'b0}};
				rd=inst[11:7];
				alu_op={10{1'b1}};
				j_op={5{1'b1}};
				b_op={5{1'b1}};
				// auipc
				immr={{12{inst[31]}},inst[31:12]};
				ls_op=5'b00101;
			end
			// S-type decoder
			// store
			7'b0100011:begin
				rs1=inst[19:15];
				rs2=inst[24:20];
				rd=inst[11:7];
				alu_op={10{1'b1}};
				j_op={5{1'b1}};
				b_op={5{1'b1}};
				case(inst[14:12])
					3'b000:begin // sb
						immr={{20{inst[31]}},inst[31:25],inst[11:7]};
						ls_op=5'b00110;
					end
					3'b001:begin // sh
						immr={{20{inst[31]}},inst[31:25],inst[11:7]};
						ls_op=5'b00111;
					end
					3'b010:begin // sw
						immr={{20{inst[31]}},inst[31:25],inst[11:7]};
						ls_op=5'b01000;
					end
				endcase
			end
			// B-type decoder
			7'b1100011:begin
				rs1=inst[19:15];
				rs2=inst[24:20];
				rd={5{1'b0}};
				alu_op={10{1'b1}};
				ls_op={5{1'b1}};
				j_op={5{1'b1}};
				case(inst[14:12])
					3'b000:begin // beq
						immr={{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
						b_op=5'b00001;
					end
					3'b001:begin // bne
						immr={{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
						b_op=5'b00010;
					end
					3'b100:begin // blt
						immr={{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
						b_op=5'b00011;
					end
					3'b101:begin // bge
						immr={{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
						b_op=5'b00100;
					end
					3'b110:begin // bltu
						immr={{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
						b_op=5'b00101;
					end
					3'b111:begin // bgeu
						immr={{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
						b_op=5'b00111;
					end
				endcase
			end
		endcase
	end

endmodule