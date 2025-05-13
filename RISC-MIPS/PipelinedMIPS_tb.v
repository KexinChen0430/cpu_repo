`include "PipelinedMIPS.v"

module PipelinedMIPS_tb();

	reg Clk,Rst;

	PipelinedMIPS  MIPS_CPU(Clk,Rst);

initial 
	begin
			Clk=1'b1;
			Rst=1'b0;
			#1 Rst=1'b1;

			forever #1 Clk=~Clk;
	end

initial
	begin
		$dumpfile("Test.vcd");
		$dumpvars(0,PipelinedMIPS_tb);
		
		
		#70 Rst=1'b0; $finish;

	end
endmodule