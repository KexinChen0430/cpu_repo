module InstructionMemoryFile(IMemError,Address,Data,Clk);
	output      [31:0] 	Data;
	output reg 			IMemError;		// Cache MISS Flag
	input 		[31:0]	Address;
	input 	    	  	Clk,Rst;

	reg        	[ 7:0] 	imembank [0:63];  //  8x64  64B memory

initial begin $readmemh("Instruction_Memory.txt",imembank); IMemError=1'b0; end // Multiple test cases for jump branch dependencies
//initial begin $readmemh("Instruction_Memory(old).txt",imembank); end // Basic Program


	// always @(posedge Clk) 
	// begin
	// 	if(~Rst) 
	// 		for (int i = 0; i <64; i++) 
	// 			begin
	// 				imembank[i]<= 32'd0;			/* Reset Memory */
	// 			end
	// end
	

	assign Data = {imembank[Address+3'b11],imembank[Address+2'b10],imembank[Address+2'b01],imembank[Address]} ;

endmodule
