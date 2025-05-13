module ALUmux(
    input [31:0]rs2, imm,
    input alu_src,
    output reg [31:0] second_src
);
always@(*)
begin
    if(alu_src)
        second_src = imm;
    else
        second_src = rs2;
end
endmodule


module ALU(
    input u,a,mulh,shiftFromrs2,
    input [3:0]alu_op,
    input [4:0]shamt,
    input [31:0]src1, src2,
    output reg [31:0]alu_result,
    output reg Zero
    );

parameter 
    op_add = 1, op_sub = 2, op_and = 3, op_or  = 4,  op_xor = 5, op_mul = 6,
    op_slt = 7, op_sll = 8, op_srl = 9, 
    op_beq = 10, op_bne = 11, op_blt = 12, op_bge = 13;

wire [31:0]src_sub;

reg  [63:0]mul_result;
assign src_sub = src1 - src2;

always @(*) begin
    alu_result = 0;
    Zero = 0; 
    case (alu_op)
        4'd1: //op_add:1
                begin
                    alu_result = $signed(src1) + $signed(src2);
                    
                end
        4'd2: //op_sub:2
                begin
                    alu_result = $signed(src1) - $signed(src2);
                    
                end
        4'd3: //op_and:3
                begin
                    alu_result = src1 & src2;
                    
                end
        4'd4: //op_or:4
                begin
                    alu_result = src1 | src2;  
                end
        4'd5: //op_xor = 5, 
                begin
                    alu_result = src1 ^ src2;
                    
                end
        4'd6: //op_mul = 6,
                begin
                    if(u)begin
                        mul_result = $unsigned(src1) * $unsigned(src2);
                        alu_result = mul_result[63:32];
                    end
                    else begin
                        mul_result = $signed(src1) * $signed(src2);
                        if(mulh)
                            alu_result = mul_result[63:32];
                        else
                            alu_result = mul_result[31:0];
                    end  
                    //zero = 0;    
                end
        4'd7: //op_slt = 7, 
                begin
                    if(u)
                        alu_result = ($unsigned(src1) < $unsigned(src2))? 32'd1 : 32'd0;
                    else
                        alu_result = ($signed(src1) < $signed(src2))? 32'd1 : 32'd0;
                    //zero = 0;
                end
        4'd8: //op_sll = 8, 
                begin
                    if(shiftFromrs2)//sll
                        alu_result = src1 << $unsigned(src2[4:0]);  
                    else //slli
                        alu_result = src1 << $unsigned(shamt);  
                end
        4'd9: //op_srl = 9, 
                begin
                    if(shiftFromrs2)begin
                        if(a) //sra
                            alu_result = $signed(src1) >>> $unsigned(src2[4:0]); 
                        else //srl
                            alu_result = src1 >> $unsigned(src2[4:0]);
                    end
                    else begin
                        if(a) //srai
                            alu_result = $signed(src1) >>> shamt; 
                        else //srli
                            alu_result = src1 >> shamt;
                      
                    end
                    
                    
                end
        4'd10:  //op_beq = 10, 
                begin
                    Zero = (src_sub == 0) ? 1 : 0;
                end
        4'd11: //op_bne = 11, 
                begin
                    Zero = (src_sub == 0) ? 0 : 1;
                end
        4'd12: //op_blt = 12
                begin
                    if(u)
                        Zero = ($unsigned(src1) < $unsigned(src2))? 1 : 0;
                    else
                        Zero = ($signed(src1) < $signed(src2))? 1 : 0;
                end
        4'd13: //op_bge = 13;
                begin
                    if(u)
                        Zero = ($unsigned(src1) >= $unsigned(src2))? 1 : 0;
                    else
                        Zero = ($signed(src1) >= $signed(src2))? 1 : 0;
                end

        default:begin
            alu_result = 0;
            Zero = 0;
        end
        
    endcase
end

endmodule