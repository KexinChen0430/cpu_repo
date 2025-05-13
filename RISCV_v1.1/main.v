module main(clk);
parameter	PC_LENGTH = 32;
parameter	INST_LENGTH = 32;
parameter 	DATA_LENGTH = 32;
parameter 	REG_ADDR_LENGTH = 5; 
parameter 	IMMIN_LENGTH = INST_LENGTH - 7;
parameter 	DMEM_ADDR_LENGTH = 32;

input clk;

////
//ngo ra
///
//PC
wire [PC_LENGTH-1:0] pcOut;
//add4
wire [PC_LENGTH-1:0] pc_plus_4;
//IMEM
wire [INST_LENGTH-1:0] inst;
//Control Unit
wire [2:0] ALUSel, immSel;
wire [1:0] WBSel;
wire BrUn,PCSel,ASel,BSel,MemRW,RegWEn;
//Reg
wire [REG_ADDR_LENGTH - 1 : 0] addrA,addrB,addrD;
wire [DATA_LENGTH - 1 : 0] dataA,dataB;
//BrCompare
wire BrEq,BrLt;
//ImmGen
wire [IMMIN_LENGTH-1:0] immIn;
wire [DATA_LENGTH-1:0] immOut;
//muxA
wire [DATA_LENGTH-1:0] alumux1_out;
//muxB
wire [DATA_LENGTH-1:0] alumux2_out;
//ALU
wire [DATA_LENGTH-1:0] aluout;
wire Cout;
//DMEM
wire [DATA_LENGTH-1:0] dataR;
//muxDMEM
wire [DATA_LENGTH - 1 : 0] wb;
//muxPC
//wire [PC_LENGTH-1:0] pcIn; 


////
//day noi
////
//PC
wire [PC_LENGTH-1:0] pcIn;
//add4

//IMEM

//Control Unit

//Reg
wire [DATA_LENGTH - 1 : 0] dataD;
//BrCompare

//ImmGen

//muxA

//muxB

//ALU
wire M,S0,S1,Cin;
//DMEM

//muxDMEM
wire [DATA_LENGTH-1:0] in3;

////
//ghep khoi
////
//PC
PC u1(pcIn,pcOut,clk);
//add4
add4 u2(pcOut,pc_plus_4);
//IMEM
IMEM u3(pcOut,inst);
//Control Unit
Control_Unit u4(inst,BrEq,BrLt,BrUn,PCSel,immSel,ASel,BSel,ALUSel,MemRW,RegWEn,WBSel);
//Reg
assign addrA = inst[19:15];
assign addrB = inst[24:20];
assign addrD = inst[11:7];
assign dataD = wb;
Reg u5(addrA,addrB,addrD,dataD,dataA,dataB,RegWEn,clk);
//BrCompare
BrCompare u6(dataA,dataB,BrUn,BrEq,BrLt);
//ImmGen
assign immIn = inst[31:7];
ImmGen u7(immIn,immOut,immSel);
//muxA
mux2_1 u8(dataA,pcOut,alumux1_out,ASel);
//muxB
mux2_1 u9(dataB,immOut,alumux2_out,BSel);
//ALU
assign {M,S1,S0} = ALUSel;
assign Cin = 1'b0;
ALU32b u10(M,S1,S0,alumux1_out,alumux2_out,Cin,aluout,Cout);
//DMEM
DMEM u11(aluout,dataB,dataR,MemRW,clk);
//muxDMEM
assign in3 = 32'hABBA_0102;
mux4_1 u12(aluout,dataR,pc_plus_4,in3,wb,WBSel);
//muxPC
mux2_1 u0(pc_plus_4,aluout,pcIn,PCSel);

endmodule 
