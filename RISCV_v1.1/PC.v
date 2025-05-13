module PC(pcIn,pcOut,clk);
parameter	PC_LENGTH = 32;

input [PC_LENGTH-1:0] pcIn;
input clk;
output reg [PC_LENGTH-1:0] pcOut;

initial
begin
	pcOut = 32'h0000_0000;
end

always @(posedge clk)
begin
	pcOut = pcIn;
end
  
endmodule 
