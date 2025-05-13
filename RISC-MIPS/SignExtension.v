module SignExt(Out,In);

output [31:0] Out;
input  [15:0] In;

assign Out=In[15]?{16'hFFFF,In}:{16'h0000,In};

endmodule

module Shft2(Out,In);

output [31:0] Out;
input  [31:0] In;

assign Out={In[29:0],2'b00};

endmodule


module Shft2Jump(Out,In);

output [27:0] Out;
input  [25:0] In;

assign Out={In[25:0],2'b00};

endmodule