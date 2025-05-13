module add4(in,out);
parameter	PC_LENGTH = 32;

input [PC_LENGTH-1:0] in;
output [PC_LENGTH-1:0] out;

assign out = in + 4;
  
endmodule 