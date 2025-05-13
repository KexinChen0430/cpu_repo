module CPU(
	input Reset,
	input PCWre
);
	wire[31:0] address; // 指令地址
	wire[31:0] instr; // 指令
	wire[9:0] alu_op; // alu操作码
	wire[4:0] rs1; // rs1地址
	wire[4:0] rs2; // rs2地址
	wire[4:0] rd; // rd地址
	wire State_r=1; // 读取位
	wire State_w=0; // 写入位
	wire[31:0] rs1_data,rs2_data,rd_data; // rs1,rs2,rd数据
	wire Delete=0;

	// 生成地址
	AGU agu(
		._Rest(Reset),
		.PCWre(PCWre),
		.address(address)
	);
	// 取指令
	IMemory imemory(
		.address(address),
		.instr(instr)
	);
	// 译码
	decoder decoder(
		.instr(instr),
		.alu_op(alu_op),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd)
	);
	// 取寄存器值
	Regfile regfile_1(
		.State(State_r),
		.address_1(rs1),
		.address_2(rs2),
		.data_1(rs1_data),
		.data_2(rs2_data)
	);
	// 计算
	ALU alu(
		.rs1_num(rs1_data),
		.rs2_num(rs2_data),
		.alu_op(alu_op),
		.rd_num(rd_data)
	);
	// 访存
	DMemory dmemory(
		.Delete(Delete),
		.State(State_w),
		.data_w(rd_data),
		.address(rd)
	);
	// 回写
	Regfile regfile_3(
		.State(State_w),
		.address_1(rd),
		.data_w(rd_data)
	);
endmodule