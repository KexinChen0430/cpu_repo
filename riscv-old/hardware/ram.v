module Ram #(
  parameter     RamSize = 4096,
  parameter     MemoryFile = ""
)(
  input         clock_i,
  input         reset_i,
  input         read_enable_i,
  input  [31:0] address_i,
  output [31:0] data_o
);

//--------------------------------------------------------------------------------------

localparam
  AddressBits  = $clog2(RamSize),
  RamWordCount = RamSize / 4;
  
//--------------------------------------------------------------------------------------

reg [31:0] memory_r [RamWordCount-1:0];

initial $readmemh(MemoryFile, memory_r);

//--------------------------------------------------------------------------------------

reg [31:0] read_data_r;

always @(posedge clock_i) begin
  if (reset_i) begin
    read_data_r <= 32'd0;
  end
  else if (read_enable_i) begin
    read_data_r <= memory_r[address_i[AddressBits-1:2]];
  end
end

assign data_o = read_data_r;

endmodule