`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Arquitetura de Sistemas Digitais
// Laboratório 3
//
// ENTRADAS:-
// Address: Endereço de 32 bits usado para acessar a memória;
// WriteData: Valor de 32 bits, usado para escrever na memória;
// Clk: Clock para sincronização;
// MemWrite: Sinal de controle, só há escrita quando alto.
// MemRead: Sinal de controle, só há leitura quando alto.
//
// SAÍDAS:-
// ReadData: Saída de 32 bits com a informação passada no endereço Address.
//
// Baseado no trabalho de archisman-dey
////////////////////////////////////////////////////////////////////////////////

module DataMemory #(
	parameter BITS_SIZE = 32,
	parameter MEMORY_SIZE = 256
	) (Address, WriteData, Clk, MemWrite, MemRead, ReadData);

    input [BITS_SIZE - 1:0] Address; 	// Endereço de acesso 
    input [BITS_SIZE - 1:0] WriteData; // Data de 32 bits a ser escrita na memoria
    input Clk;
    input MemWrite; 	
    input MemRead; 		

    output reg[BITS_SIZE - 1:0] ReadData; // Saída da leitura

    reg 	[BITS_SIZE - 1:0] 	Memory[0:MEMORY_SIZE - 1];
      
   		always 	@(posedge Clk)		   //Memory write
   		begin
   		
			if (MemWrite==1) begin

   				Memory[Address] = WriteData;
			end
   		end
   		
   		always @(posedge Clk) //Address or MemRead
   		begin	
   			if	(MemRead == 1) begin
				
				ReadData = Memory[Address];
			end				
   		end 
   		
endmodule