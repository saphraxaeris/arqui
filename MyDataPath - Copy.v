module InstructionRegister(output reg [31:0] out, input [31:0] in, input LE, CLR, CLK); //Add LE, CLR & CLK to all modules that need it in all files
	always @(posedge CLK, negedge CLR)
	begin
	//$display("The value of in is: %b, %d", in, $time);
	if(CLR) out <= 32'h00000000;
	else if(LE) out <= in;
	else out <= out;
	//$display("The value of out is: %b, %d", out, $time);
	end
endmodule

module MDR(output reg [31:0] out, input [31:0] in, input LE, CLR, CLK); //Add LE, CLR & CLK to all modules that need it in all files
	always @(posedge CLK, negedge CLR)
	begin
	//$display("The value of in is: %b, %d", in, $time);
	if(CLR) out <= 32'h00000000;
	else if(LE) out <= in;
	else out <= out;
	//$display("The value of out is: %b, %d", out, $time);
	end
endmodule

module MAR(output reg [7:0] out, input [31:0] in, input LE, CLR, CLK); //Add LE, CLR & CLK to all modules that need it in all files
	always @(posedge CLK, negedge CLR)
	begin
	//$display("The value of in is: %b, %d", in, $time);
	if(CLR) out <= 8'b00000000;
	else if(LE) out <= in[7:0];
	else out <= out;
	//$display("The value of out is: %b, %d", out, $time);
	end
endmodule

module ShifterAndSignExt(output reg [31:0] out, input [31:0] instruction, Rm);
	reg lsb; //keeps least significant bit
	reg [31:0] tempReg;
	integer i;
	always @(*)
	begin
		case(instruction[27:25])
			3'b000: begin
				if(instruction[4] == 1'b0) //Data processing imm shift
					begin
						tempReg = instruction[7:0];
						for(i=0;i<(instruction[11:8])*2;i=i+1)
							begin
								lsb = tempReg[0];
								tempReg = tempReg>>1;
								tempReg[31]=lsb;
							end
						assign out = tempReg;
					end
				else //Data processing register shift
					begin
						case(instruction[6:5])
							2'b00: begin //LSL
								assign out = Rm;
							end
							2'b01: begin //LSR
								assign out = 0;
							end
							2'b10: begin //ASR
								if (Rm[31] == 0) begin
									assign out = 0;
								end
								else begin
									assign out = 32'hFFFFFFFF;
								end
							end
							2'b11: begin //ROR
								assign out = Rm >>> 1;
							end
						endcase
					end
			end
			3'b001: begin //Data processing imm
				case(instruction[6:5])
					2'b00: begin //LSL
						assign out = Rm << instruction[11:7];
					end
					2'b01: begin //LSR
						assign out = Rm >> instruction[11:7];
					end
					2'b10: begin //ASR
						assign out = $signed(Rm) >>> instruction[11:7];
					end
					2'b11: begin //ROR
						tempReg = Rm;
						for(i=0; i<instruction[11:7]; i=i+1) begin
							lsb = tempReg[0];
							tempReg = tempReg >> 1;
							tempReg[31] = lsb;
						end
						assign out = tempReg;
					end
				endcase
			end
			3'b010: begin //Load/store imm
				assign out = instruction[11:0];
			end
			3'b011: begin //Load/store register
				tempReg = instruction[7:0];
				for(i=0;i<(instruction[11:8])*2;i=i+1)
					begin
						lsb = tempReg[0];
						tempReg = tempReg>>1;
						tempReg[31]=lsb;
					end
				assign out = tempReg;
			end
			3'b101: begin //Branch and branch/link
				assign out = { {8{instruction[23]}}, instruction[23:0]*4 };;
			end
			default: assign out = Rm;
		endcase
	end
endmodule

module cond_test(output reg results_cond_test, input N, Z, C, V, input [3:0] cond);
	always @(*)
	begin 
		case(cond)

			//Equal
			4'b0000: begin 
						if(Z==1) results_cond_test=1;
						else results_cond_test=0;
					end
			//NotEqual
			4'b0001: begin 
						if(Z==0) results_cond_test=1;
						else results_cond_test=0;
					end
			//CS/HS
			4'b0010: begin 
						if(C==1) results_cond_test=1;
						else results_cond_test=0;
					end
			//CC/LO
			4'b0011: begin 
						if(C==0) results_cond_test=1;
						else results_cond_test=0;
					end
			//MI
			4'b0100: begin 
						if(N==1) results_cond_test=1;
						else results_cond_test=0;
					end
			//PL
			4'b0101: begin 
						if(N==0) results_cond_test=1;
						else results_cond_test=0;
					end
			//VS
			4'b0110: begin 
						if(V==1) results_cond_test=1;
						else results_cond_test=0;
					end
			//VC
			4'b0111: begin 
						if(V==0) results_cond_test=1;
						else results_cond_test=0;
					end
			//HI
			4'b1000: begin 
						if(C==1 && Z==0) results_cond_test=1;
						else results_cond_test=0;
					end
			//LS
			4'b1001: begin 
						if(C==0 && Z==1) results_cond_test=1;
						else results_cond_test=0;
					end
			//GE
			4'b1010: begin 
						if(C==V) results_cond_test=1;
						else results_cond_test=0;
					end
			//LT
			4'b1011: begin 
						if(!C==V) results_cond_test=1;
						else results_cond_test=0;
					end
			//GT
			4'b1100: begin 
						if(Z==0 && N==V) results_cond_test=1;
						else results_cond_test=0;
					end
			//LE
			4'b1101: begin 
						if(Z==1 | N==!V) results_cond_test=1;
						else results_cond_test=0;
					end
			//AL
			4'b1110: results_cond_test=1;
						
		endcase
	end
endmodule

module StatusRegister(output reg N, Z, C, V, input N_in, Z_in, C_in, V_in, input LE, CLR, CLK);
	always @(posedge CLK, negedge CLR)
	begin
	//$display("The value of in is: %b, %d", in, $time);
	if(CLR) begin N <= 0; Z <= 0; C <= 0; V <= 0; end
	else if(LE) begin N <= N_in; Z <= Z_in; C <= C_in; V <= V_in; end
	else N <= N; Z <= Z; C <= C; V <= V;
	//$display("The value of out is: %b, %d", out, $time);
	end
endmodule 

module Mux2x1_4bits(output reg [3:0] Out, input [3:0] A,B, input S);
    always @(*)
	case(S)
	    0:  assign Out=A;
       	    1:  assign Out=B;
	endcase
endmodule

module Mux2x1_32bits(output reg [31:0] Out, input [31:0] A,B, input S);
    always @(*)
	case(S)
	    0:  assign Out=A;
       	    1:  assign Out=B;
	endcase
endmodule

module Mux4x1_4bits(output reg [3:0] Out, input [3:0] A,B,C,D, input[1:0] S);
    always @(*)
	case(S)
	    2'b00:  assign Out=A;
       	    2'b01:  assign Out=B;
	    2'b10:  assign Out=C;
	    2'b11:  assign Out=D;
	endcase
endmodule

module Mux4x1_32bits(output reg [31:0] Out, input [31:0] A,B,C,D, input[1:0] S);
    always @(*)
	case(S)
	    2'b00:  assign Out=A;
       	    2'b01:  assign Out=B;
	    2'b10:  assign Out=C;
	    2'b11:  assign Out=D;
	endcase
endmodule

module AND(output reg out, input a, b);
	always @(*)
	assign out = a & b;
endmodule

module NOT(output reg out, input a);
	always @(*)
	assign out = !a;
endmodule
	