`timescale 1ns/1ns
module Test_CPU;
	reg PCWre;
	reg Reset;

	CPU test_cpu(
		.PCWre(PCWre),
		.Reset(Reset)
	);

	initial
		begin
			#0 Reset=1;PCWre=0;
			#5 Reset=0;PCWre=1;
			#0 Reset=0;PCWre=0;
			#5 Reset=0;PCWre=1;
			#5 $finish;
		end

	initial
		begin
			$dumpfile("CPU.vcd");
			$dumpvars(0,Test_CPU);
		end
endmodule