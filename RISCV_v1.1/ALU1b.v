module ALU1b (M,S1,S0,Ai,Bi,Ci,Fi,Co);


input M,S1,S0,Ai,Bi,Ci;
output reg Fi, Co;

always @(M or S1 or S0 or Ai or Bi or Ci)
begin
	case({M,S1,S0})
	
		3'b000: 
			begin
				Fi = Ai & Bi;
				Co = 0;
			end
			
		3'b001: 
			begin
				Fi = Ai | Bi;
				Co = 0;
			end
			
		3'b010: 
			begin
				Fi = Ai ^ Bi;
				Co = 0;
			end
		
		3'b011: 
			begin
				Fi = ~(Ai ^ Bi);
				Co = 0;
			end
			
		3'b100: 
			begin
				Fi = Ai ^ Ci;
				Co = Ai & Ci;
			end
		
		3'b101:
			begin
				Fi = Ai ^ Bi ^ Ci;
				Co = Ai & Bi | Bi & Ci | Ci & Ai;
			end
		
		3'b110:
			begin
				Fi = Ai ^ ~Bi ^ Ci;
				Co = Ai & ~Bi | ~Bi & Ci | Ci & Ai;
			end
		
		3'b111:
			begin
				Fi = ~Ai ^ Bi ^ Ci;
				Co = ~Ai & Bi | Bi & Ci | Ci & ~Ai;
			end
		
	endcase

end

endmodule
