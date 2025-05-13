module dealDataRead(
    input clk, mem_r, 
    output reg data_read
);
always@(negedge clk)
begin
	if(mem_r)
		data_read <= ~data_read;
	else
		data_read <= 0;
end  
endmodule


module dealLoad(
    input mem_r, read,data_addr,
	input [2:0] funct3,
	input [31:0] load_data,
	output reg [31:0] out_data
);
always@(*)
begin
	if(mem_r&read)begin
		case(funct3)
			3'b010://lw
				out_data = load_data;
			3'b000: //lb
				if(load_data[7])
                    out_data = {{24{1'b1}},load_data[7:0]};
				else
                    out_data = {{24{1'b0}},load_data[7:0]};                    
			3'b001: //lh
				if(load_data[15])
                    out_data = {{16{1'b1}},load_data[15:0]};
				else
                    out_data = {{16{1'b0}},load_data[15:0]};
			3'b100: //lbu
                out_data = {{24{1'b0}},load_data[7:0]};   
			default: //lhu
                out_data = {{16{1'b0}},load_data[15:0]};
		endcase
    end        
	else
		out_data = 0;
end
endmodule



module genAndExtend_Imm(
    input [2:0] ImmType,
	input [31:7] first25, //25 is least bit for imm 	
	output reg [31:0] imm_result
);
reg is20, add0;
reg [11:0] result12;
reg [19:0] result20;

always@(*)
begin
    result12 = 0; result20 = 0; is20 = 0; add0 = 0;
	case(ImmType)
		3'b001: begin
			result12 = first25[31:20];
		end		
		3'b011: begin
			result12 = {first25[31:25],first25[11:7]};
		end
		3'b100: begin
			result12 = {first25[31],first25[7],first25[30:25],first25[11:8]};
			add0 = 1;
		end
		3'b101: begin
			result20 = first25[31:12]; is20 = 1;
		end
		3'b110: begin
			result20 = {first25[31],first25[19:12],first25[20],first25[30:21]};
			is20 = 1; add0 = 1;
		end
		default: begin
			add0 = 0;
			is20 = 0;
			result12 = 0;
			result20 = 0;
		end
	endcase
end

always@(*)
begin
	if(!is20) //12
		if(!add0) 
			if(result12[11] == 0) 
                imm_result = {{20{1'b0}}, result12};
			else
                imm_result = {{20{1'b1}}, result12};
		else 
			if(result12[11] == 0) 
                imm_result = { {19{1'b0}}, result12, 1'b0};
			else
                imm_result = { {19{1'b1}}, result12, 1'b0};
	else //20
		if(!add0) 
            imm_result = { result20, {12{1'b0}} };
		else 
			if(result20[19] == 0) 
                imm_result = {{12{1'b0}}, result20, 1'b0};
			else
                imm_result = {{12{1'b1}}, result20, 1'b0};
				
end
endmodule



module dealStore(
    input mem_w,
	input [1:0] storeWay, addr_last2,
	input [31:0] rs2_data,
	output reg [3:0] where2write,
	output reg [31:0] data_in
);
initial
	where2write = 0;
	
always@(*)
begin
	if(mem_w)begin
		case(storeWay) //by the last 2 bit of funct3
			2'b00: //sb: write 1 byte
				case(addr_last2) //deal if not 4's multiple
					2'b00: begin
                        where2write = 4'b0001;
                        data_in = {{24{1'b0}},rs2_data[7:0]};
                    end
					2'b01:begin
                        where2write = 4'b0010;
                        data_in = {{16{1'b0}},rs2_data[7:0],{8{1'b0}}};
                    end
					2'b10: begin
                        where2write = 4'b0100;
                        data_in = {{8{1'b0}},rs2_data[7:0],{16{1'b0}}};
                    end
					2'b11:
                    begin
                        where2write = 4'b1000;
                        data_in = {rs2_data[7:0],{24{1'b0}}};
                    end
				endcase
			2'b01: //sh
				case(addr_last2)
					2'b00:begin
                        where2write = 4'b0011;
                        data_in = {{16{1'b0}},rs2_data[15:0]};
                    end
						
					2'b01:begin
                        where2write = 4'b0110;
                        data_in = {{8{1'b0}},rs2_data[15:0],{8{1'b0}}};
                    end
					default:begin
                        where2write = 4'b1100;
                        data_in = {rs2_data[15:0],{16{1'b0}}};
                    end		
				endcase
			default:begin //sw
                where2write = 4'b1111;
                data_in = rs2_data;
            end
		endcase
    end
	else begin
        where2write = 4'b0000;	
        data_in = 32'b0;
    end		
end
endmodule


module generate_DataAddr(
    input mem_r,mem_w,
	input [31:0] ALU_result,
	output [31:0] data_addr
);    
    assign data_addr =  (mem_r | mem_w) ? ALU_result : 0;
endmodule


module whetherRead(
    input clk, mem_r, mem_w,
	output reg instr_read
);
    always@(negedge clk) 
    begin
        if(mem_r||mem_w)
            instr_read <= ~instr_read;
        else
            instr_read <= 1;
    end
endmodule


module reg_forInstr(
    input instr_read,
	input [31:0] instr_in,
	output [31:0] instr_out
);
reg [31:0] instr_reg;
assign instr_out = instr_reg;
always@(instr_in)
begin
	if(instr_read)
		instr_reg = instr_in;
end
endmodule

/*
module reg_forData(
    input data_read,
	input [31:0] data_in,
	output [31:0] data_out
);
reg [31:0] data_reg;
assign data_out = data_reg;
always@(data_in)
begin
	if(data_read)
		data_reg = data_in;
end
endmodule*/