//Jean-Claude Yordan Torres
//Register file

//32 bit Register Module Start
module Register32(output reg [31:0] Q, input [31:0] D, input Reg_EN, CLR, CLK);

	always @(posedge CLK, negedge CLR)
	begin
	if(CLR) Q <= 32'h00000000;
	else if(Reg_EN) Q <= D;
	end
endmodule
//32 bit Register Module End

//Decoder Module Start
module Decoder(output reg [15:0] E, input [3:0] DSEL, input Dec_EN);
	always @(posedge Dec_EN) //Elsewhere: "always @(*)". Change only to be consistent in all modules without CLK if it doesn't break anything, or if it could fix any issue.
	if(Dec_EN == 1) begin
	case(DSEL)
//R0
4'b0000 :E= 16'b0000000000000001;
//R1
4'b0001 :E= 16'b0000000000000010;
//R2
4'b0010 :E= 16'b0000000000000100;
//R3
4'b0011 :E= 16'b0000000000001000;	
//R4
4'b0100 :E= 16'b0000000000010000;
//R5
4'b0101 :E= 16'b0000000000100000;	
//R6
4'b0110 :E= 16'b0000000001000000;	
//R7
4'b0111 :E= 16'b0000000010000000;	
//R8
4'b1000 :E= 16'b0000000100000000;	
//R9
4'b1001 :E= 16'b0000001000000000;		
//R10
4'b1010 :E= 16'b0000010000000000;
//R11
4'b1011 :E= 16'b0000100000000000;	
//R12
4'b1100 :E= 16'b0001000000000000;		
//R13
4'b1101 :E= 16'b0010000000000000;		
//R14
4'b1110 :E= 16'b0100000000000000;
//R15
4'b1111 :E= 16'b1000000000000000;
endcase
end
else E = 16'b0000000000000000;

endmodule
//Decoder Module End

//MUX Module Start
module mux_16x1(output reg[31:0] Y, input[3:0] S, input Mux_EN, input [31:0] I0,I1,I2,I3,I4,I5,I6,I7,I8,I9,I10,I11,I12,I13,I14,I15);

	always @(S,I0,I1,I2,I3,I4,I5,I6,I7,I8,I9,I10,I11,I12,I13,I14,I15)
	if(Mux_EN == 1)begin
	case(S)
//R0
4'b0000 :Y=I0;
//R1
4'b0001 :Y=I1;
//R2
4'b0010 :Y=I2;
//R3
4'b0011 :Y=I3;	
//R4
4'b0100 :Y=I4;
//R5
4'b0101 :Y=I5;	
//R6
4'b0110 :Y=I6;	
//R7
4'b0111 :Y=I7;	
//R8
4'b1000 :Y=I8;	
//R9
4'b1001 :Y=I9;		
//R10
4'b1010 :Y=I10;
//R11
4'b1011 :Y=I11;	
//R12
4'b1100 :Y=I12;		
//R13
4'b1101 :Y=I13;		
//R14
4'b1110 :Y=I14;
//R15
4'b1111 :Y=I15;
endcase
end

endmodule
//MUX Module End

//Register File Module Start
module Reg_File(output wire [31:0] PA, PB, input [31:0] IN, input [3:0] SA, SB, DSEL, input [1:0] Mux_EN_Sel, input Dec_EN, CLR, CLK);

	wire [15:0] E;
	assign E0= E[0];
	assign E1= E[1];
	assign E2= E[2];
	assign E3= E[3];
	assign E4= E[4];
	assign E5= E[5];
	assign E6= E[6];
	assign E7= E[7];
	assign E8= E[8];
	assign E9= E[9];
	assign E10= E[10];
	assign E11= E[11];
	assign E12= E[12];
	assign E13= E[13];
	assign E14= E[14];
	assign E15= E[15];
	wire [31:0] Reg_out_0;
	wire [31:0] Reg_out_1;
	wire [31:0] Reg_out_2;
	wire [31:0] Reg_out_3;
	wire [31:0] Reg_out_4;
	wire [31:0] Reg_out_5;
	wire [31:0] Reg_out_6;
	wire [31:0] Reg_out_7;
	wire [31:0] Reg_out_8;
	wire [31:0] Reg_out_9;
	wire [31:0] Reg_out_10;
	wire [31:0] Reg_out_11;
	wire [31:0] Reg_out_12;
	wire [31:0] Reg_out_13;
	wire [31:0] Reg_out_14;
	wire [31:0] Reg_out_15;
	assign Mux_EN0 = Mux_EN_Sel[0];
	assign Mux_EN1 = Mux_EN_Sel[1];
	
//Decoder, Register, MUX Module Instancing
	Decoder Dec1 (E,DSEL,Dec_EN);

	Register32 R0 (Reg_out_0,IN,E0,CLR,CLK);
	Register32 R1 (Reg_out_1,IN,E1,CLR,CLK);
	Register32 R2 (Reg_out_2,IN,E2,CLR,CLK);
	Register32 R3 (Reg_out_3,IN,E3,CLR,CLK);
	Register32 R4 (Reg_out_4,IN,E4,CLR,CLK);
	Register32 R5 (Reg_out_5,IN,E5,CLR,CLK);
	Register32 R6 (Reg_out_6,IN,E6,CLR,CLK);
	Register32 R7 (Reg_out_7,IN,E7,CLR,CLK);
	Register32 R8 (Reg_out_8,IN,E8,CLR,CLK);
	Register32 R9 (Reg_out_9,IN,E9,CLR,CLK);
	Register32 R10 (Reg_out_10,IN,E10,CLR,CLK);
	Register32 R11 (Reg_out_11,IN,E11,CLR,CLK);
	Register32 R12 (Reg_out_12,IN,E12,CLR,CLK);
	Register32 R13 (Reg_out_13,IN,E13,CLR,CLK);
	Register32 R14 (Reg_out_14,IN,E14,CLR,CLK);
	Register32 R15 (Reg_out_15,IN,E15,CLR,CLK);
	
	mux_16x1 MUX1(PA, SA, Mux_EN0, Reg_out_0,Reg_out_1,Reg_out_2,Reg_out_3,Reg_out_4,Reg_out_5,Reg_out_6,Reg_out_7,Reg_out_8,Reg_out_9,Reg_out_10,Reg_out_11,Reg_out_12,Reg_out_13,Reg_out_14,Reg_out_15);
	mux_16x1 MUX2(PB, SB, Mux_EN1, Reg_out_0,Reg_out_1,Reg_out_2,Reg_out_3,Reg_out_4,Reg_out_5,Reg_out_6,Reg_out_7,Reg_out_8,Reg_out_9,Reg_out_10,Reg_out_11,Reg_out_12,Reg_out_13,Reg_out_14,Reg_out_15);

endmodule
//Register File Module End	
	
//Test Module Start
module Test_Reg_File;

 	wire [31:0] PA,PB;
 	reg [31:0] IN;
 	reg [3:0] RA,RB,DSEL;
 	reg [1:0] Mux_EN_Sel;
 	reg Dec_EN,CLR,CLK;

 	parameter sim_time =50000;

 	Reg_File test1 (PA,PB,IN,RA,RB,DSEL,Mux_EN_Sel,Dec_EN,CLR,CLK );

	initial #sim_time $finish;
	initial begin
		CLK = 1'b0;
		repeat (100) #5 CLK = ~CLK;
	end
 	initial begin

		IN <=32'b00000000000000000000011110000000;
		CLR <=1;
		

 		#10 begin
 		IN <=32'b00000000000000000000001100000111;
 		CLR <=0;
 		DSEL <=4'b0101;
 		Dec_EN <=1'b1;
		end 

		#10 begin 
		Dec_EN <=1'b0;
		end
		
        	#10 begin
 		IN <=32'b11111111111111111111111111111111;
 		CLR <=0;
 		DSEL <=4'b1111;
 		Dec_EN <=1'b1;
		end 

		#10 begin 
		Dec_EN <=1'b0;
		end
		
		#10 begin
		IN <=32'b00010100000000000000000000000110;
		CLR <=0;
		DSEL <=4'b0100;
		Dec_EN <=1'b1;	
		end

		#10 begin 
		Dec_EN <=1'b0;
		end

		#10 begin
		IN <=32'b00010110100000000000000000000101;
		CLR <=0;
		DSEL <=4'b1011;
		Dec_EN <=1'b1;	
		end

		#10 begin 
		Dec_EN <=1'b0;
		end

		#10 begin
		Mux_EN_Sel =2'b11;
		RA <=4'b1011;
		RB <=4'b0100;
		end
		
		#10 begin
		Mux_EN_Sel =2'b11;
		RA <=4'b0101;
		RB <=4'b1111;
		end
		
		#10 begin
		Mux_EN_Sel =2'b11;
		RA <=4'b0000;
		RB <=4'b0001;
		end
		
	end 
	initial begin
		fo = $fopen("output.out", "w");
		$fdisplay(fo, " PA   PB  Mux_EN_Sel  IN  Time");
		$monitor(" %b   %b  %b %b  %d",PA,PB, Mux_EN_Sel,IN,$time);
	end
endmodule
//Test Module End