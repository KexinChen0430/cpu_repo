module	RISCV_tb();
reg clk;
main u1(clk);

initial
begin
clk = 1'b0;
#10
forever #10 clk = ~clk;
end

endmodule
