module ALU32b(M,S1,S0,A,B,Cin,F,Cout);
parameter DATA_LENGTH = 32;

input [DATA_LENGTH-1:0] A,B;
input M,S0,S1,Cin;
output [DATA_LENGTH-1:0] F;
output Cout;

wire [DATA_LENGTH-1:0] tmp;

ALU1b u0(M,S1,S0,A[0],B[0],Cin,F[0],tmp[0]);
ALU1b u1(M,S1,S0,A[1],B[1],tmp[0],F[1],tmp[1]);
ALU1b u2(M,S1,S0,A[2],B[2],tmp[1],F[2],tmp[2]);
ALU1b u3(M,S1,S0,A[3],B[3],tmp[2],F[3],tmp[3]);
ALU1b u4(M,S1,S0,A[4],B[4],tmp[3],F[4],tmp[4]);
ALU1b u5(M,S1,S0,A[5],B[5],tmp[4],F[5],tmp[5]);
ALU1b u6(M,S1,S0,A[6],B[6],tmp[5],F[6],tmp[6]);
ALU1b u7(M,S1,S0,A[7],B[7],tmp[6],F[7],tmp[7]);
ALU1b u8(M,S1,S0,A[8],B[8],tmp[7],F[8],tmp[8]);
ALU1b u9(M,S1,S0,A[9],B[9],tmp[8],F[9],tmp[9]);

ALU1b u10(M,S1,S0,A[10],B[10],tmp[9],F[10],tmp[10]);
ALU1b u11(M,S1,S0,A[11],B[11],tmp[10],F[11],tmp[11]);
ALU1b u12(M,S1,S0,A[12],B[12],tmp[11],F[12],tmp[12]);
ALU1b u13(M,S1,S0,A[13],B[13],tmp[12],F[13],tmp[13]);
ALU1b u14(M,S1,S0,A[14],B[14],tmp[13],F[14],tmp[14]);
ALU1b u15(M,S1,S0,A[15],B[15],tmp[14],F[15],tmp[15]);
ALU1b u16(M,S1,S0,A[16],B[16],tmp[15],F[16],tmp[16]);
ALU1b u17(M,S1,S0,A[17],B[17],tmp[16],F[17],tmp[17]);
ALU1b u18(M,S1,S0,A[18],B[18],tmp[17],F[18],tmp[18]);
ALU1b u19(M,S1,S0,A[19],B[19],tmp[18],F[19],tmp[19]);

ALU1b u20(M,S1,S0,A[20],B[20],tmp[19],F[20],tmp[20]);
ALU1b u21(M,S1,S0,A[21],B[21],tmp[20],F[21],tmp[21]);
ALU1b u22(M,S1,S0,A[22],B[22],tmp[21],F[22],tmp[22]);
ALU1b u23(M,S1,S0,A[23],B[23],tmp[22],F[23],tmp[23]);
ALU1b u24(M,S1,S0,A[24],B[24],tmp[23],F[24],tmp[24]);
ALU1b u25(M,S1,S0,A[25],B[25],tmp[24],F[25],tmp[25]);
ALU1b u26(M,S1,S0,A[26],B[26],tmp[25],F[26],tmp[26]);
ALU1b u27(M,S1,S0,A[27],B[27],tmp[26],F[27],tmp[27]);
ALU1b u28(M,S1,S0,A[28],B[28],tmp[27],F[28],tmp[28]);
ALU1b u29(M,S1,S0,A[29],B[29],tmp[28],F[29],tmp[29]);

ALU1b u30(M,S1,S0,A[30],B[30],tmp[29],F[30],tmp[30]);
ALU1b u31(M,S1,S0,A[31],B[31],tmp[30],F[31],tmp[31]);

assign Cout = tmp[31];


endmodule 
