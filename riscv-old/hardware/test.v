`timescale 1ns / 1ns

module Test;

//--------------------------------------------------------------------------------------

reg clock_r;
reg reset_r;

//--------------------------------------------------------------------------------------

wire [31:0] address_w;
wire [31:0] data_w;
wire        read_enable_w;

Ram #(
  .RamSize(1024),
  .MemoryFile(`PROGRAM_FILE)
) ram (
  .clock_i(clock_r),
  .reset_i(reset_r),
  .read_enable_i(read_enable_w),
  .address_i(address_w),
  .data_o(data_w)
);

//--------------------------------------------------------------------------------------

Riscv riscv (
  .clock_i(clock_r),
  .reset_i(reset_r),
  .read_enable_o(read_enable_w),
  .address_o(address_w),
  .data_i(data_w)
);

//--------------------------------------------------------------------------------------

initial begin
  $dumpfile(`GTKW_FILE);
  $dumpvars;
  reset_r = 1;
  #2;
  reset_r = 0;
  #100;
  $finish;
end

//--------------------------------------------------------------------------------------

always begin
  clock_r = 0;
  #1;
  clock_r = 1;
  #1;
end

endmodule
