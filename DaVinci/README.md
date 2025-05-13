# DaVinci

	一个实现了RV32I标准的开源RISC-V CPU软核

Future:

	RV32GC/RV64GC
	14-Stage Pipeline
	6-Issues
	SMT2

Completed:

	RV32I 80%

Simulation Tools:

	iVerilog + GTKwave

Run:

	git clone https://github.com/TealerLinkGuo/DaVinci.git
	cd DaVinci
	iVerilog -o CPU.out Decode_INST.v ALU_RECV.v IMemory.v DMemory.v Regfile.v CPU.v Test_CPU.v
	vvp -n CPU.out
	gtkwave CPU.vcd

Last Update:

	2019/04/30 12:13