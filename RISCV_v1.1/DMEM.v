module DMEM(addr,dataW,dataR,MemRW,clk);

parameter DATA_LENGTH = 32;
parameter DMEM_ADDR_LENGTH = 32;
parameter MEM_LENGTH = DATA_LENGTH;
parameter MEM_DEPTH = 50;

input [DMEM_ADDR_LENGTH-1:0] addr;
input [DATA_LENGTH-1:0] dataW;
input clk, MemRW;
output reg [DATA_LENGTH-1:0] dataR;

reg [MEM_LENGTH-1:0]DMEM_content[MEM_DEPTH-1:0];

wire		[DMEM_ADDR_LENGTH-3:0]	pWord;
wire		[1:0]	pByte;

assign		pWord = addr[DMEM_ADDR_LENGTH-1:2];
assign		pByte = addr[1:0];

initial
begin
$readmemh("C:/Users/ngocdangkhoa102/Desktop/CPU/Memories/DMEM.txt",DMEM_content);
end

always @(negedge clk)
begin
	if(pByte == 2'b00)
	begin
		if(MemRW)
		begin
			DMEM_content[pWord] = dataW;
		end
		else
			dataR = DMEM_content[pWord];	 
	end
	else
			dataR = 32'h11111111; 
	
end

endmodule
