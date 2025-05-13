module rdMux(
	input rd_able, mem2reg, isJorU,
	input [31:0] from_ALU, from_JorU, from_memory,	
	output reg [31:0] rd
);
initial
	rd = 0;
always@(*)
begin
	if(rd_able)
		if(mem2reg)
            rd = from_memory;
        else if (isJorU)
            rd = from_JorU;
        else
            rd = from_ALU;
	else
		rd = 0;
end
endmodule

module RegFile(
    input clk, rst, rs1_able, rs2_able, rd_able, reg_w,
    input  [4:0]  rs1_addr, rs2_addr,rd_addr,
    input  [31:0] rd_data,
    output [31:0] rs1_data, rs2_data

);
reg [31:0] register [31:0];
integer i;
initial begin
	for(i = 0; i < 32; i = i + 1)
		register[i] = 32'd0;
end

//read register
assign rs1_data = rs1_able? register[rs1_addr] : 0; 
assign rs2_data = rs2_able? register[rs2_addr] : 0;

//write register
always @ (negedge clk or posedge rst) begin 
		if (rst) 
			for (i=0;i<32;i=i+1)
				register[i] <= 0;
		else if (reg_w && rd_addr!=0)
			register[rd_addr] <= rd_data;
end
endmodule