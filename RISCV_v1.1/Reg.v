module Reg(addrA,addrB,addrD,dataD,dataA,dataB,RegWEn,clk);
parameter DATA_LENGTH = 32;
parameter REG_ADDR_LENGTH = 5;
parameter REGISTER_LENGTH = 32;
parameter MEM_DEPTH = 32; 

input [REG_ADDR_LENGTH - 1 : 0] addrA,addrB,addrD;
input [DATA_LENGTH - 1 : 0] dataD;
input clk,RegWEn;
output [DATA_LENGTH - 1 : 0] dataA,dataB;

reg	[REGISTER_LENGTH - 1:0]REG[0:MEM_DEPTH - 1];

initial
begin
$readmemh("C:/Users/ngocdangkhoa102/Desktop/CPU/Memories/REG.txt",REG);
end
assign	dataA = REG[addrA];
assign	dataB = REG[addrB];
always @(posedge clk)
begin

	if(RegWEn)
		begin
			if (addrD != 5'b00000)
				REG[addrD] = dataD;
		end
end

endmodule
