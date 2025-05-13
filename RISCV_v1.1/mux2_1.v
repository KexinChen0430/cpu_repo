module mux2_1(in0,in1,y,sel);
parameter DATA_LENGTH = 32;

input [DATA_LENGTH-1:0] in0,in1;
input sel;
output reg [DATA_LENGTH-1:0]y;

always @(in0 or in1 or sel)
begin
	case(sel)
		1'b0: y = in0;
		1'b1: y = in1;
	endcase
end


endmodule 
