//32-bit ALU (Arithmetic Logic Unit) for ARM Architecture.
module ALU(input [31:0] a, b, input [3:0] opCode, input carryIn, 
           output reg [31:0] result, output reg N, Z, C, V);
  reg overflowPossible = 1'b0; //For flag updating/handling at the end. Starts at false.
  reg carry = 1'b0;
  integer fo;
  always @ (opCode, a, b, carryIn)
  begin
     
    assign carry = carryIn; //For flag updating/handling at the end. Starts at carryIn.
     $display( "Initial Carry: %b", carryIn);
     $display( "%b", a);
    if(opCode == 4'b0000) //0000b: AND (Logical AND)
      begin
	 $display( "AND"); 
        assign result = a & b;
      end

    if(opCode == 4'b0001) //0001b: EOR (Logical Exclusive-OR)
      begin
	 $display( "EOR"); 
        assign result = a ^ b;
      end 
 
    if(opCode == 4'b0010) //0010b: SUB (Subtract)
      begin
	 $display( "SUB"); 
        assign {carry, result} = a - b;
	assign carry = ~carry; //In substraction, we obtain borrow, not carry.
        assign overflowPossible = 1'b1; //We need to handle overflow possibility.
      end  

    if(opCode == 4'b0011) //0011b: RSB (Reverse Subtract)
      begin
	 $display( "RSB"); 
        assign {carry, result} = b - a;
	assign carry = ~carry; //In substraction, we obtain borrow, not carry.
        assign overflowPossible = 1'b1; //We need to handle overflow possibility.
      end
  
    if(opCode == 4'b0100) //0100b: ADD (Add)
      begin
	 $display( "ADD"); 
        assign {carry, result} = a + b;
	assign overflowPossible = 1'b1; //We need to handle overflow possibility.
      end  
    
    if(opCode == 4'b0101) //0101b: ADC (Add with Carry)
      begin
	 $display( "ADC"); 
        assign {carry, result} = a + b + carryIn;
        assign overflowPossible = 1'b1; //We need to handle overflow possibility.
      end
  
    if(opCode == 4'b0110) //0110b: SBC (Subtract with Carry)
      begin
	 $display( "SBC"); 
        assign {carry, result} = a - b - (!carryIn); //Is this correct?
	assign carry = ~carry; //In substraction, we obtain borrow, not carry.
        assign overflowPossible = 1'b1; //We need to handle overflow possibility.
      end
    
    if(opCode == 4'b0111) //0111b: RSC (Reverse Subtract with Carry)
      begin
	 $display( "RSC"); 
        assign {carry, result} = b - a - (!carryIn); //Is this correct?
	assign carry = ~carry; //In substraction, we obtain borrow, not carry.
        assign overflowPossible = 1'b1; //We need to handle overflow possibility.
      end
  
    if(opCode == 4'b1000) //1000b: TST (Test)
      begin
	 $display( "TST"); 
        assign result = a & b;
      end
  
    if(opCode == 4'b1001) //1001b: TEQ (Test Equivalence)
      begin
	 $display( "TEQ"); 
        assign result = a ^ b;
      end      
    
    if(opCode == 4'b1010) //1010b: CMP (Compare)
      begin
	 $display( "CMP"); 
        assign {carry, result} = a - b;
      end
     
    if(opCode == 4'b1011) //1011b: CMN (Compare Negated)
      begin
	 $display( "CMN"); 
        assign {carry, result} = a + b;
      end
    
    if(opCode == 4'b1100) //1100b: ORR (Logical OR)
      begin
	 $display( "ORR"); 
        assign result = a | b;
      end
    
    if(opCode == 4'b1101) //1101b: MOV (Move)
      begin
	 $display( "MOV"); 
        assign result = b;
      end
    
    if(opCode == 4'b1110) //1110b: BIC (Bit Clear)
      begin
	 $display( "BIC"); 
        assign result = a & (~b);
      end
    
    if(opCode == 4'b1111) //1111b: MVN (Move Not) 
      begin
	 $display( "MVN"); 
        assign result = ~b; //Is this correct?
      end

     $display( "%b", b); 

    /*****FLAGS UPDATING/ASSIGNMENT (and result display)******/
    
    assign N = result[31]; //NEGATIVE FLAG
    assign Z = result == 0; //ZERO FLAG (Can I do it this way?)
    assign C = carry; //CARRY FLAG
    assign V = 1'b0; //We assume 0 unless any of the below occurs:
    if(overflowPossible) //OVERFLOW FLAG
      begin
        if((opCode == 4'b0100) || (opCode == 4'b0101)) //Add operations
          begin
	    /*Overflow in Addition: If two numbers of the same sign yield a number of the opposite sign.*/
            assign V = ((a[31] == b[31]) && (a[31] != result[31])) ? 1'b1 : 1'b0;
          end
        if ((opCode == 4'b0010) || (opCode == 4'b0110)) //Subtract operations
          begin
	    /*Overflow in Subtraction: If two different signed numbers yield a 
          number with the sign of the subtrahend.*/
            assign V = ((a[31] != b[31]) && (b[31] == result[31])) ? 1'b1 : 1'b0;
          end
	if ((opCode == 4'b0011) || (opCode == 4'b0111)) //Reverse subtract operations
	  begin 
            assign V = ((a[31] != b[31]) && (a[31] == result[31])) ? 1'b1 : 1'b0;
          end
      end
       $display( "Result: %b", result);
       $display( "N: %b", N);
       $display( "Z: %b", Z);
       $display( "C: %b", C);
       $display( "V: %b", V);
  end   
endmodule

//Tester for the 32-bit ALU for ARM Architecture.
module ALUTester;
	reg carryIn;
	reg [3:0] opCode;
	reg [31:0] a = 32'b10000000000000000000000000000000; //Modify number to use w/ all ops here.
	reg [31:0] b = 32'b10000000000000000000000000000010; //Modify number to use w/ all ops here.
	wire N, Z, C, V;
	wire [31:0] result;
	parameter sim_time = 100000;
	ALU myALU (a, b, opCode, carryIn, result, N, Z, C, V);

	initial #sim_time $finish;
	initial fork
		carryIn = 1'b0; //I think we have to maintain the carry over operations...
		opCode = 4'b0000; //AND

		#10 carryIn = 1'b0; //I think we have to maintain the carry over operations...
		#10 opCode = 4'b0001; //EOR

		#20 carryIn = 1'b0; //I think we have to maintain the carry over operations...
		#20 opCode = 4'b0010; //SUB

		#30 carryIn = 1'b0; //I think we have to maintain the carry over operations...
		#30 opCode = 4'b0011; //RSB

		#40 carryIn = 1'b0; //I think we have to maintain the carry over operations...
		#40 opCode = 4'b0100; //ADD

		#50 carryIn = 1'b1; //I think we have to maintain the carry over operations...
		#50 opCode = 4'b0101; //ADC

		#60 carryIn = 1'b1; //I think we have to maintain the carry over operations...
		#60 opCode = 4'b0110; //SBC

		#70 carryIn = 1'b1; //I think we have to maintain the carry over operations...
		#70 opCode = 4'b0111; //RSC

		#80 carryIn = 1'b0; //I think we have to maintain the carry over operations...
		#80 opCode = 4'b1000; //TST

		#90 carryIn = 1'b0; //I think we have to maintain the carry over operations...
		#90 opCode = 4'b1001; //TEQ

		#100 carryIn = 1'b0; //I think we have to maintain the carry over operations...
		#100 opCode = 4'b1010; //CMP

		#110 carryIn = 1'b0; //I think we have to maintain the carry over operations...
		#110 opCode = 4'b1011; //CMN

		#120 carryIn = 1'b0; //I think we have to maintain the carry over operations...
		#120 opCode = 4'b1100; //ORR

		#130 carryIn = 1'b0; //I think we have to maintain the carry over operations...
		#130 opCode = 4'b1101; //MOV

		#140 carryIn = 1'b0; //I think we have to maintain the carry over operations...
		#140 opCode = 4'b1110; //BIC

		#150 carryIn = 1'b0; //I think we have to maintain the carry over operations...
		#150 opCode = 4'b1111; //MVN
	join
endmodule
