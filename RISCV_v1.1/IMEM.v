/*
 ***@Author: 
 ***@Date:   Oct 16th, 2018
*/

/******** Instruction Memmory Block ********/
module IMEM(PC,inst);
parameter	INST_LENGTH = 32;
parameter	PC_LENGTH = 32;
parameter	MEM_LENGTH = 32;
parameter	MEM_DEPTH = 18;
output	reg	[INST_LENGTH-1:0]inst;
input		[PC_LENGTH-1:0]PC;

/********* Instruction Memmory *************/
reg		[MEM_LENGTH-1:0]IMEM[0:MEM_DEPTH-1];

wire		[17:0]pWord;
wire		[1:0]pByte;

assign		pWord = PC[19:2];
assign		pByte = PC[1:0];

initial begin
$readmemh("C:/Users/ngocdangkhoa102/Desktop/CPU/Memories/testIMEM.txt",IMEM);
end

always@(PC)
begin
	if (pByte == 2'b00)
		inst <= IMEM[pWord];
	else
		inst <= 'hz;
end

endmodule
