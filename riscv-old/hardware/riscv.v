module Riscv (
  input         clock_i,
  input         reset_i,
  output        read_enable_o,
  output [31:0] address_o,
  input  [31:0] data_i
);

//--------------------------------------------------------------------------------------

reg [31:0] address_r;
reg [31:0] instruction_address_r;

always @(posedge clock_i) begin
  if (reset_i) begin
    address_r <= 32'd0;
    instruction_address_r <= 32'd0;
  end
  else begin
    address_r <= address_r + 32'd4;
    instruction_address_r <= address_r;
  end
end

assign read_enable_o = 1'b1;
assign address_o = address_r;

//--------------------------------------------------------------------------------------

// Decode logic.

wire [4:0] rs1_w    = data_i[19:15];
wire [4:0] rs2_w    = data_i[24:20];
wire [4:0] rd_w     = data_i[11:7];

wire [2:0] func3_w  = data_i[14:12];
wire [6:0] funct7_w = data_i[31:25];

wire [31:0] immediate_i_w = {{20{data_i[31]}}, data_i[31:20]};

endmodule
