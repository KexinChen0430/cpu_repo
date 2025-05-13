// Please include verilog file if you write module in other file

`include "CU.v"
`include "ALU.v"
`include "PC.v"
`include "RegFile.v"
`include "dealData.v"

module CPU(
    input             clk,
    input             rst,
    input      [31:0] data_out,   //the data sent from DM
    input      [31:0] instr_out,
    output            instr_read,
    output            data_read,
    output     [31:0] instr_addr, //the instr. address in IM
    output     [31:0] data_addr,  //the data address in DM
    output  [3:0] data_write, 
    output  [31:0] data_in     //the data need to be WRITTEN into DM
);

wire instr_read_wire, data_read_wire;

//from CU.v
wire rs1_able, rs2_able, rd_able, reg_w, mem_r, mem_w;
wire branch, mem2reg, alu_src, u, a_out, mulh, isJorU, shiftFromrs2; //, jalr, plus_imm,
wire [1:0]JUtype;
wire [2:0]imm_type;
wire [3:0]alu_op;

//from ALU.v
wire [31:0]second_src, alu_result;
wire Zero;

//from PC.v
wire [1:0]  pc_src;
wire [31:0] addr_result, instr_addr_wire;
wire [31:0] PCfromJU, RDfromJU;
//from RegFile.v
wire [31:0] rd_result, rs1_data, rs2_data;

//from dealData.v
wire [31:0] load_final_data, imm_result, instr_wire, data_addr_wire;


assign instr_read = instr_read_wire;
assign data_read = data_read_wire;
assign instr_addr = instr_addr_wire;
assign data_addr = data_addr_wire;


//CU
CU ControlUnit(
    //input
    .opcode(instr_wire[6:0]),.funct3(instr_wire[14:12]), .funct7(instr_wire[31:25]),.a_in(instr_wire[30]),
    //output
    .branch(branch), .mem_r(mem_r), .mem2reg(mem2reg), .alu_op(alu_op), 
    .imm_type(imm_type), .mem_w(mem_w), .alu_src(alu_src), .rs1_able(rs1_able), .rs2_able(rs2_able), 
    .rd_able(rd_able), .reg_w(reg_w), .u(u) , .a_out(a_out),//.jalr(jalr), //.plus_imm(plus_imm), , 
    .mulh(mulh), .isJorU(isJorU), .JUtype(JUtype), .shiftFromrs2(shiftFromrs2)
);

//ALU
ALUmux mux_forALU(.rs2(rs2_data), .imm(imm_result), .alu_src(alu_src), .second_src(second_src));
ALU theALU(.u(u), .a(a_out), .mulh(mulh), .alu_op(alu_op), .shamt(instr_wire[24:20]),
.src1(rs1_data), .src2(second_src), .alu_result(alu_result),.Zero(Zero), .shiftFromrs2(shiftFromrs2));

//PC
JorU_PCandRD toDealJU(.isJorU(isJorU), .JUtype(JUtype), .old_PC(instr_addr_wire), .imm(imm_result), 
.rs1(rs1_data), .rd(RDfromJU), .new_PC(PCfromJU));
PCSrc generate_PCsrc_NEW(.branch(branch), .Zero(Zero), .isJorU(isJorU), .pc_src(pc_src));
PCmux mux_forPC_NEW(.isJorU(isJorU), .pc_src(pc_src), .old_pc(instr_addr_wire), .imm(imm_result), 
.pc_fromJU(PCfromJU), .new_pc(addr_result));
PC thePC(.clk(clk), .instr_read(instr_read_wire), .new_addr(addr_result), .PC_addr(instr_addr_wire));

//RegFile
rdMux mux_forRd_NEW(.rd_able(rd_able),.mem2reg(mem2reg),.isJorU(isJorU), .from_ALU(alu_result),
.from_JorU(RDfromJU), .from_memory(load_final_data),.rd(rd_result));

RegFile theReg(.clk(clk), .rst(rst), .rs1_able(rs1_able), .rs2_able(rs2_able), .rd_able(rd_able), 
.reg_w(reg_w), .rs1_addr(instr_wire[19:15]), .rs2_addr(instr_wire[24:20]), .rd_addr(instr_wire[11:7]), 
.rd_data(rd_result), .rs1_data(rs1_data), .rs2_data(rs2_data));

//dealData
dealDataRead toDealDataRead(clk, mem_r, data_read_wire);
dealLoad toDealLoad(.mem_r(mem_r),.read(data_read_wire),.data_addr(data_addr_wire),.funct3(instr_wire[14:12]),.load_data(data_out), 
.out_data(load_final_data));//
genAndExtend_Imm toGetImm(.ImmType(imm_type), .first25(instr_wire[31:7]), .imm_result(imm_result));
dealStore toDealStore(.mem_w(mem_w), .storeWay(instr_wire[13:12]), .addr_last2(alu_result[1:0]), 
.rs2_data(rs2_data), .where2write(data_write), .data_in(data_in));

whetherRead toGetInstrRead(clk, mem_r, mem_w, instr_read_wire);
generate_DataAddr toGetDataAddr(mem_r, mem_w, alu_result, data_addr_wire);
reg_forInstr theRegForInstruction(.instr_read(instr_read_wire), .instr_in(instr_out), .instr_out(instr_wire));


endmodule