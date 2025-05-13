module CU(
    input [6:0]opcode,
    input [2:0]funct3,
    input [6:0]funct7,
    input a_in, //instr[30]
    output reg branch,
    output reg mem_r,
    output reg mem2reg,
    output reg [2:0]imm_type,
    output reg [1:0]JUtype,
    output reg [3:0]alu_op, 
    output reg mem_w,
    output reg alu_src,
    output reg rs1_able, rs2_able, rd_able,
    output reg reg_w,
    output reg u,a_out, mulh, isJorU,shiftFromrs2//,jalr//, plus_imm, 
    // u:unsigned; a_out:arithmetic->instr[30]
    //plus_imm: for jal; isJorU for writting rd
    //jalr: used in PC.v; mulh: used in ALU.v
);

parameter 
    op_add = 1, op_sub = 2, op_and = 3, op_or  = 4,  op_xor = 5, op_mul = 6,
    op_slt = 7, op_sll = 8, op_srl = 9, 
    op_beq = 10, op_bne = 11, op_blt = 12, op_bge = 13,
    is_jalr = 0, is_jal = 1, is_auipc = 2, is_lui = 3; 

initial begin
	mem_r = 0;
end
    
always @(*) begin
    branch = 0; mem_r = 0; mem2reg = 0; alu_op = 4'b0000; imm_type = 3'b000;
    mem_w = 0; alu_src = 0; reg_w = 0; 
    rs1_able = 0; rs2_able = 0; rd_able = 0; u = 0; a_out = a_in; //plus_imm = 0; jalr = 0;
    mulh = 0; isJorU = 0; JUtype = 2'b00; shiftFromrs2=0;//jalr = 0;
    case(opcode)
        7'b011_0011: // R-type
        begin
            reg_w = 1; rs1_able = 1; rs2_able = 1; rd_able = 1; alu_src = 0;
            case(funct7)
                7'b000_0000:
                begin
                    case (funct3)
                        3'b000: alu_op = op_add; //add
                        3'b001: begin //sll
                            shiftFromrs2=1;
                            alu_op = op_sll;
                        end 
                        3'b010: alu_op = op_slt; //slt
                        3'b011: begin//sltu (slt:7slt)
                            alu_op = op_slt;
                            u = 1;
                        end
                        3'b100: alu_op = op_xor; //xor
                        3'b101:begin //srl
                            alu_op = op_srl; 
                            shiftFromrs2 = 1;
                        end 
                        3'b110: alu_op = op_or; //or
                        3'b111: alu_op = op_and; //and
                        default: alu_op = 4'b0000;
                    endcase
                end

                7'b010_0000:
                begin
                    case(funct3)
                        3'b000: alu_op = op_sub; //sub:2sub
                        3'b101:begin//sra (-->srl:9)
                            alu_op = op_srl; 
                            shiftFromrs2 = 1;
                        end 
                        default: alu_op = 4'b0000;
                    endcase
                end

                7'b000_0001:
                begin
                    alu_op = op_mul; //mul:6
                    case (funct3)
                        //3'b000://mul
                        3'b001: mulh = 1;//mulh
                        3'b011: u = 1;//mulhu
                        default: alu_op = alu_op;
                    endcase
                end                
            endcase
        end

        7'b00000_11: // I-type --> load from mem
        begin
            mem_r = 1; mem2reg = 1; reg_w = 1; rs1_able = 1; rs2_able = 0; rd_able = 1;
            alu_src = 1; imm_type = 3'b001; alu_op = op_add; //add
        end

        7'b001_0011: //I-type -int
        begin    
            alu_src = 1; reg_w = 1; rs1_able = 1; rs2_able = 0; rd_able = 1; imm_type = 3'b001;
            case (funct3)
                3'b000:alu_op = op_add;//addi 1add
                3'b010:alu_op = op_slt;//slti slt7
                3'b011:begin//sltiu
                    alu_op = op_slt;
                    u = 1;
                end
                3'b100:alu_op = op_xor; //xori
                3'b110:alu_op = op_or;  //ori
                3'b111:alu_op = op_and; //andi
                3'b001:begin //slli
                    alu_op = op_sll; 
                    imm_type = 3'b010;
                end 
                3'b101:begin
                    imm_type = 3'b010;
                    case (funct7)
                        7'b000_0000:alu_op = op_srl;//srli
                        7'b01_00000:begin //srai
                            alu_op = op_srl;
                            //a = 1;
                        end
                        default: alu_op = alu_op;
                    endcase
                end

                default: alu_op = alu_op;
            endcase
        end

        7'b1100_111:begin //JALR (I-type)
            rs1_able = 1; rs2_able = 0; rd_able = 1; //jalr = 1;
            isJorU = 1; imm_type = 3'b001; reg_w = 1; JUtype = is_jalr;
            //alu_op = op_add; alu_src = 1; 
        end

        7'b01_00011: // S-type
        begin
            alu_op = op_add; mem_w = 1; alu_src = 1; imm_type = 3'b011;
            rs1_able = 1; rs2_able = 1; rd_able = 0; 
        end

        7'b11_00011:// B-type
        begin
            branch = 1; rs1_able = 1; rs2_able = 1; rd_able = 0; imm_type = 3'b100;
            case (funct3)
                3'b000:alu_op = op_beq; //beq
                3'b001:alu_op = op_bne; //bne
                3'b100:alu_op = op_blt; //blt
                3'b101:alu_op = op_bge; //bge
                3'b110://bltu
                        begin
                            alu_op = op_blt;
                            u = 1;
                        end
                3'b111://bgeu
                        begin
                            alu_op = op_bge;
                            u = 1;
                        end
                default: alu_op = alu_op;
            endcase  
        end

        7'b001_0111: //AUIPC
        begin 
            isJorU = 1; reg_w = 1; rd_able = 1; imm_type = 3'b101; JUtype = is_auipc;
        end

        7'b011_0111:// LUI
        begin 
            isJorU = 1; reg_w = 1; rd_able = 1; imm_type = 3'b101; JUtype = is_lui;
        end

        7'b110_1111:// JAL 
        begin
            reg_w = 1; rd_able = 1; isJorU = 1; imm_type = 3'b110; JUtype = is_jal; //plus_imm = 1;
        end
    endcase
end

endmodule