module BrCompare(num1,num2,BrUn,BrEq,BrLt);
parameter DATA_LENGTH = 32;
input [DATA_LENGTH - 1:0] num1, num2;
input BrUn;
output reg BrEq,BrLt;

always @(num1 or num2 or BrUn)
begin
	case (BrUn)
		1'b0:
		begin
			if ($signed(num1) == $signed(num2))
				{BrEq,BrLt} = 2'b10;
			else if ($signed(num1) > $signed(num2)) 
				{BrEq,BrLt} = 2'b00;
			else
				{BrEq,BrLt} = 2'b01;
		end
		
		1'b1:
		begin
			if (num1 == num2)
				{BrEq,BrLt} = 2'b10;
			else if (num1 > num2) 
				{BrEq,BrLt} = 2'b00;
			else
				{BrEq,BrLt} = 2'b01;
		end
	endcase
end 

endmodule 
