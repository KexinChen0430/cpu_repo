`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Arquitetura de Sistemas Digitais
// Laboratório 3
//
// ENTRADAS:-
// PCNext: Entrada de bits que representa o próximo valor do contador;
// Reset: Sinal de controle de reset;
// Clk: Sinal de clock.
//
// SAÍDAS:-
// PCResult: Saída de bits que representa o valor atual do contador.
//
//
// Baseado no trabalho de Caskman. 
////////////////////////////////////////////////////////////////////////////////

module ProgramCounter #(parameter BITS_SIZE = 32) (PCNext, PCResult, Reset, Clk);

	input       [BITS_SIZE - 1:0]  PCNext;
	input               Reset, Clk;

	output reg  [BITS_SIZE - 1:0]  PCResult;

	initial begin
	
		PCResult <= {BITS_SIZE{1'b0}}; // zera os BITS_SIZE espaços do reg de saída
	end

    always @(posedge Clk)
    begin
    	if (Reset == 1)
    	begin
    		PCResult <= {BITS_SIZE{1'b0}};
    	end
    	else
    	begin
			PCResult <= PCNext;
    	end
    end

endmodule