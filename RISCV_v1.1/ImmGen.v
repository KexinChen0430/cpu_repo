module ImmGen(immIn,immOut,immSel);
parameter DATA_LENGTH = 32;
parameter INST_LENGTH = 32;
parameter OUTPUT_LENGTH = 14;
parameter OPCODE_LENGTH = 7;
parameter IMMIN_LENGTH = INST_LENGTH - OPCODE_LENGTH;

input [IMMIN_LENGTH-1:0] immIn;
input [2:0] immSel;
output reg [DATA_LENGTH-1:0] immOut;

initial
begin
end

always @(immIn or immSel)
begin
	case(immSel)
	//R type
		3'b000: immOut = {32{1'b0}};
	//I type
		3'b001: immOut = {{20{immIn[IMMIN_LENGTH-1]}}, immIn[IMMIN_LENGTH-1:IMMIN_LENGTH-12]};
	//B type
		3'b010: immOut = {{19{immIn[IMMIN_LENGTH-1]}}, immIn[IMMIN_LENGTH-1], immIn[0], immIn[IMMIN_LENGTH-2:IMMIN_LENGTH-7], immIn[4:1], 1'b0};
	//S type
		3'b011: immOut = {{20{immIn[IMMIN_LENGTH-1]}}, immIn[IMMIN_LENGTH-1:IMMIN_LENGTH-7], immIn[4:0]};
	//U type (lui)
		3'b100: immOut = {32{1'b0}};
	//U type (auipc)
		3'b101: immOut = {32{1'b0}};
	//J type (jalr)
		3'b110: immOut = {{11{immIn[IMMIN_LENGTH-1]}}, immIn[IMMIN_LENGTH-1], immIn[IMMIN_LENGTH-13:IMMIN_LENGTH-20], immIn[IMMIN_LENGTH-12],immIn[IMMIN_LENGTH-2:IMMIN_LENGTH-11], 1'b0};
	//J type (jal)
		3'b111: immOut = {{20{immIn[IMMIN_LENGTH-1]}}, immIn[IMMIN_LENGTH-1:IMMIN_LENGTH-12]};
	endcase
end
endmodule 

