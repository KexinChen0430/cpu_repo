gtkwave = /mnt/c/Program\ Files\ \(x86\)/iverilog/gtkwave2/bin/gtkwave.exe

flags += -Wall
flags += -g2001
flags += -D PROGRAM_FILE=\"../memory\"
flags += -D GTKW_FILE=\"../build/output.gtkwave\"

main:
	mkdir -p ../build
	iverilog $(flags) ../ram.v ../riscv.v ../test.v -o ../build/output
	vvp ../build/output
	$(gtkwave) -f ../build/output.gtkwave ../config/config.gtkw