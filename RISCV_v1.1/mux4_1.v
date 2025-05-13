module mux4_1(in0,in1,in2,in3,y,sel);
parameter DATA_LENGTH = 32;

input [DATA_LENGTH-1:0] in0,in1,in2,in3;
input [1:0] sel;
output reg [DATA_LENGTH-1:0]y;

always @(in0 or in1 or in2 or in3 or sel)
begin
	case(sel)
		2'b00: y = in0;
		2'b01: y = in1;
		2'b10: y = in2; 
		2'b11: y = in3;
	endcase
end


endmodule 
