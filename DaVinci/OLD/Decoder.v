/*
File Name   : Decoder.v
Description : RISC-V RV32I 译码器
Written By  : Tealer Guo
Data        : 2019/04/14
*/
module decoder(
	input[31:0] instr,

	output[6:0] type_code,
	output[9:0] alu_op,
	output[4:0] rs1,
	output[4:0] rs2,
	output[4:0] rd
);
	// 实例化模块
	typecode_decoder tc_dec(
		.instr(instr),
		.type_code(type_code),
		.alu_op(alu_op),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.R_alu_op_out(),
		.R_rs1_out(),
		.R_rs2_out(),
		.R_rd_out()
	);
endmodule
// 分辨指令类型
module typecode_decoder(
	/*取指令的低7位opcode分辨指令类型*/
	input[31:0] instr, // 32-bit指令输入
	output[6:0] type_code, // 8-bit指令类型输出
	output[9:0] alu_op,
	output[4:0] rs1,
	output[4:0] rs2,
	output[4:0] rd,
	// R-type输出
	output[9:0] R_alu_op_out,
	output[4:0] R_rs1_out,
	output[4:0] R_rs2_out,
	output[4:0] R_rd_out
);
	// 取指令的低7位
	assign type_code=instr[6:0];
	// 实例化
	R_type_decode R_type_dec(
		.instr(instr),
		.alu_op(R_alu_op_out),
		.rs1(R_rs1_out),
		.rs2(R_rs2_out),
		.rd(R_rd_out)
	);

	reg[9:0] alu_op_temp;
	reg[4:0] rs1_temp;
	reg[4:0] rs2_temp;
	reg[4:0] rd_temp;

	// 多路选择
	always @(*)
	begin
		if(type_code===7'b0110011)
			alu_op_temp=R_alu_op_out;
			rs1_temp=R_rs1_out;
			rs2_temp=R_rs2_out;
			rd_temp=R_rd_out;
	end

	assign alu_op=alu_op_temp;
	assign rs1=rs1_temp;
	assign rs2=rs2_temp;
	assign rd=rd_temp;

endmodule

// R指令解码
module R_type_decode(
	/*
	alu_op       op_name
	0000000001   add
	0000000010   sub
	0000000011   sll
	0000000101   slt
	0000000110   sltu
	0000000111   xor
	0000001000   srl
	0000001001   sra
	0000001010   or
	0000001011   and
	 */
	input[31:0] instr, // 32-bit

	output[9:0] alu_op,
	output[4:0] rs1,
	output[4:0] rs2,
	output[4:0] rd
);

	wire[2:0] funct3; // 3-bit
	wire[6:0] funct7; // 7-bit

	assign rs1=instr[19:15];
	assign rs2=instr[24:20];
	assign rd=instr[11:7];

	assign funct3=instr[14:12];
	assign funct7=instr[31:25];
	
	reg[9:0] alu_op_temp;

	// R指令译码
	always @(*)
	begin
		// funct7 0000000
		if(funct7===7'b0000000)
			begin
				if(funct3===3'b000)
					alu_op_temp=10'b0000000001; // add
			end
			begin
				if(funct3===3'b001)
					alu_op_temp=10'b0000000011; // sll
			end
			begin
				if(funct3===3'b010)
					alu_op_temp=10'b0000000101; // slt
			end
			begin
				if(funct3===3'b011)
					alu_op_temp=10'b0000000110; // sltu
			end
			begin
				if(funct3===3'b100)
					alu_op_temp=10'b0000000111; // xor
			end
			begin
				if(funct3===3'b101)
					alu_op_temp=10'b0000001000; // srl
			end
			begin
				if(funct3===3'b110)
					alu_op_temp=10'b0000001010; // or
			end
			begin
				if(funct3===3'b111)
					alu_op_temp=10'b0000001011; // and
			end
	end
	always @(*)
	begin
		// funct7 0100000
		if(funct7===7'b0100000)
			begin
				if(funct3===3'b000)
					alu_op_temp=10'b0000000010; // sub
			end
			begin
				if(funct3===3'b101)
					alu_op_temp=10'b0000001001; // sra
			end
	end

	assign alu_op=alu_op_temp;

module I_type_decode(
	input[31:0] instr,
	output[9:0] alu_op,
	output[4:0] rs1,
	output[4:0] rd
);
	always @(*) begin
		
	end

endmodule