`timescale 1ns / 1ps

// Sem clock, já que é atrelado ao PC (que tem clk)
////////////////////////////////////////////////////////////////////////////////
// Arquitetura de Sistemas Digitais
// Laboratório 3
//
// ENTRADAS:-
// Address: Endereço de 32 bits usado para acessar a memória de Instrucao;
//
// SAÍDAS:-
// Instruction: Saída de 32 bits com a informação passada no endereço Address na memória de Instrucao.
//
// Baseado no trabalho de Caskman. Vale ressaltar que "code.mem" contém as 
// instruções desejadas para o trabalho em hexadecimal, as quais são lidas por
// $readmemh e guardadas em mem (variável interna).
////////////////////////////////////////////////////////////////////////////////

module InstructionMemory #(
    parameter BITS_SIZE = 32,
    parameter MEMORY_SIZE = 256
    ) (Address, Instruction); 

    input       [BITS_SIZE - 1:0]  Address;        // Input Address 
    output   [BITS_SIZE - 1:0]  Instruction;    // Instrucao de saida
    
    reg [BITS_SIZE - 1:0] mem[0:MEMORY_SIZE - 1]; // BITS_SIZE*BITS_SIZE - 1 (1024, no caso de 32 bits) palavras de BITS_SIZE bits

	initial
	begin
		$readmemh("code.mem",mem);
	end

	assign Instruction = mem[Address];	
	

endmodule