`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Arquitetura de Sistemas Digitais
// Laboratório 3
//
// ENTRADAS:-
// in: Entrada de 16 bits parametrizada. Esta porta é referente ao sinal a ser extendido pelo módulo.
//
// SAÍDAS:-
// out: Saída de 32 bits parametrizada. Esta saída possui o sinal de 32 bits extendido.

//
// Baseado no trabalho de Caskman. 
////////////////////////////////////////////////////////////////////////////////

module SignalExtension #(
    parameter BITS_SIZE = 32,
    parameter IN_SIZE = 16
    ) (out, in);

    output [BITS_SIZE - 1:0] out;
    
    input   [IN_SIZE - 1:0] in;

    assign out = { {BITS_SIZE - IN_SIZE{in[IN_SIZE - 1]}}, in };
endmodule