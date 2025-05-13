module Mux(Out,I0,I1,Sel);

output [31:0] Out;
input  [31:0] I0,I1;
input  Sel;

assign Out=(~Sel)?I0:I1;

endmodule

module Mux5(Out,I0,I1,Sel);

output [4:0] Out;
input  [4:0] I0,I1;
input  Sel;

assign Out=(~Sel)?I0:I1;

endmodule

module Mux6(Out,I0,I1,Sel);

output [5:0] Out;
input  [5:0] I0,I1;
input  Sel;

assign Out=(~Sel)?I0:I1;

endmodule