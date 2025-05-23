`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Arquitetura de Sistemas Digitais
// Laboratório 3
//
// ENTRADAS:-
// BITS_SIZE: Tamanho do registrador em bits (parametrizado como 32 bits);
// SHIFT_AMOUNT: Quantidade de bits a serem deslocados para a esquerda (parametrizado como 2 bits);
// data_in: Entrada de dados com BITS_SIZE bits.
//
// SAÍDAS:-
// data_out: Saída de dados com BITS_SIZE bits, representando o resultado do deslocamento
// à esquerda ou à direita.
//
////////////////////////////////////////////////////////////////////////////////

module Shift2LRegister #(
  parameter BITS_SIZE = 32, // TAMANHO DA ENTRADA E SAIDA
  parameter SHIFT_AMOUNT = 2, // Quanto deslocar
  parameter SHIFT_DIR = 1 // 0, deslocamento para esquerda; 1, deslocamento para direita
) (
  input [BITS_SIZE - 1:0] data_in,
  output reg [BITS_SIZE - 1:0] data_out
);

  always @* begin
    case (SHIFT_DIR)
      0: data_out = data_in << SHIFT_AMOUNT; // data_in deslocado 2 para a esquerda
      1: data_out = data_in >> SHIFT_AMOUNT; // data_in deslocado 2 para a direita
    endcase
  end

endmodule
