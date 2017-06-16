module IncrementerRegisterAdder(output reg [7:0] Out, input[7:0] In);
    always @(*) //MAY WANT TO MENTION EXPLICITLY INPUTS INSIDE ALWAYS CLAUSE FOR ALL MODULES IN ALL FILES IF THERE ARE ANY ISSUES. DON'T KNOW IF IT MAKES A DIFFERENCE.
	   assign Out = In + 1;
endmodule

module IncrementerRegister(output reg [7:0] Out, input[7:0] In, input CLR, CLK);
    always @(posedge CLK, negedge CLR)
	   assign Out = In;
endmodule

module Mux4x1_8bits(output reg [7:0] Out, input [7:0] A,B,C,D, input[1:0] S);
    always @(*)
	case(S)
	    2'b00:  assign Out=A;
       	    2'b01:  assign Out=B;
	    2'b10:  assign Out=C;
	    2'b11:  assign Out=D;
	endcase
endmodule

module Mux4x1_1bit(output reg Out, input A,B,C,D, input[1:0] S);
    always @(*)
	case(S)
	    2'b00:  assign Out=A;
       	    2'b01:  assign Out=B;
	    2'b10:  assign Out=C;
	    2'b11:  assign Out=D;
	endcase
endmodule

module Inverter(output reg Out, input In, input Inv);
    always @(*)
        if(Inv) assign Out = !In;
        else assign Out = In;
endmodule

module NextStateAddressSelector(input [2:0] N, input Sts, output reg [1:0] M, input reset);
    always @(*) begin
    if(reset) M = 2'b01;
    else case(N)
	3'b000: assign M=2'b00; //Encoder
	3'b001: assign M=2'b01; //Direct 1
	3'b010: assign M=2'b10; //Control Register
	3'b011: assign M=2'b11; //Incrementer
        3'b100: begin //(THERE'S AN ERROR IN THE TABLE IN THIS BLOCK; POSSIBLE SOURCE OF BUGS HERE)
        	if(Sts) assign M=2'b10; //Control Register 
        	else assign M=2'b00; //Encoder
    	end
        3'b101: begin
        	if(Sts) assign M=2'b10; //Control Register
        	else assign M=2'b11; //Incrementer
        end
        3'b110: begin
        	if(Sts) assign M=2'b00; //Encoder
        	else assign M=2'b11; //Incrementer
        end
        3'b111: begin
        	if(Sts) assign M=2'b10; //Control Register
        	else assign M=2'b01; //Direct 1
        end
    endcase
    end
endmodule

module Encoder(output reg [7:0] Out, input [31:0] In);
    //Not designed yet
    //integer load_imm_misc_off_pre = 105;
    //integer load_imm_misc_post = 110;
    //integer load_mult = 70;
    //integer store_mult = 80;

    // States
    reg reset = 8'b00000000;

    reg cond = 8'b00000100;

    reg log_ari_op_r = 8'b00000101;
    reg log_ari_op_shift = 8'b00000110;
    reg log_ari_op_imm = 8'b00000111;

    reg test_comp_op_r = 8'b00001000;
    reg test_comp_op_shift = 8'b00001001;
    reg test_comp_op_imm = 8'b00001010;

    reg mov_op_r = 8'b00001011;
    reg mov_op_shift = 8'b00001100;
    reg mov_op_imm = 8'b00001101;

    reg branch = 8'b00001110;
    reg branch_link = 8'b00001111;

    reg load_reg_off = 8'b00010001;
    reg load_reg_pre = 8'b00010101;
    reg load_reg_post = 8'b00011001;

    reg load_imm_off = 8'b00011110;
    reg load_imm_pre = 8'b00100010;
    reg load_imm_post = 8'b00100110;

    reg store_reg_off = 8'b00101011;
    reg store_reg_pre = 8'b00101111;
    reg store_reg_post = 8'b00110011;    
    
    reg store_imm_off = 8'b00111000;
    reg store_imm_pre = 8'b00111100;
    reg store_imm_post = 8'b01000000;
    
    reg load_reg_double_off = 8'b01000101;
    reg load_reg_double_pre = 8'b01001001;
    reg load_reg_double_post = 8'b01001101;

    reg load_imm_double_off = 8'b01010010;
    reg load_imm_double_pre = 8'b01010110;
    reg load_imm_double_post = 8'b01011010;
    
    reg store_reg_double_off = 8'b01011111;
    reg store_reg_double_pre = 8'b01100011;
    reg store_reg_double_post = 8'b01100111;

    reg store_imm_double_off = 8'b01101100;
    reg store_imm_double_pre = 8'b01110000;
    reg store_imm_double_post = 8'b01110100;

    //Important bits in instruction

    reg [3:0] Rn;
    reg [3:0] Rd;
    reg [3:0] Rm;
    reg [4:0] shift_amount;
    reg [1:0] shift;
    reg P;
    reg U;
    reg BS;
    reg W;
    reg SL;

    always @(*)
    begin
    assign Rn = In[19:16];
    assign Rd = In[15:12];
    assign shift_amount = In[11:7];
    assign shift = In[6:5];
    assign Rm = In[3:0];
    assign P = In[24];
    assign U = In[23];
    assign BS = In[22];
    assign W = In[21];
    assign SL = In[20];
    
    //COND still not included in decision taking here. Also, we may need reset assignments inside blocks after determining type of instruction when it corresponds.
    case(In[27:25])
        4'b000:begin // Data Processing Shift
            if (!In[4]) //Immediate Shift
		if(P & !U)
			assign Out = test_comp_op_shift;
		else
			assign Out = log_ari_op_shift;
	    else //Register Shift
		if(P & !U)
			assign Out = test_comp_op_r;
		else
			assign Out = log_ari_op_r;
        end
        3'b001: begin // Data processing Immediate
		if(P & !U)
			assign Out = test_comp_op_imm;
		else
			assign Out = log_ari_op_imm;
	end
        3'b010: begin // load/store Immediate Offset
		if(SL) begin
			if(P)
                            if(W) assign Out = load_imm_pre;
                            else assign Out = load_imm_off;
			else 
			    if (!W) assign Out = load_imm_post;
		end
		else begin
			if(P)
                            if(W) assign Out = store_imm_pre;
                            else assign Out = store_imm_off;
                	else
                            if(!W) assign Out = store_imm_post;
                end
	end
	3'b011: begin // load/store Register Offset
		if(SL) begin
			if(P)
                            if(W) assign Out = load_reg_pre;
                            else assign Out = load_reg_off;
			else 
			    if (!W) assign Out = load_reg_post;
		end
		else begin
			if(P)
                            if(W) assign Out = store_reg_pre;
                            else assign Out = store_reg_off;
                	else
                            if(!W) assign Out = store_reg_post;
                end
	end
	3'b101: begin //Branch & Branch w/ link
		if (P) assign Out = branch_link;
		else assign Out = branch;
	end
	default: assign Out = reset;
    endcase
    end
endmodule

module Microstore(input [7:0] In, output reg [42:0] Out);
always @(*) begin
//$display("State number (address): %b", In);
case(In)
8'b00000000: assign Out = 43'b0110000000000010000000000001011101101000000; //State 0
8'b00000001: assign Out = 43'b0110000000000000100000000100000101101000000; //State 1
8'b00000010: assign Out = 43'b0110000000000010001101000101100100100000000; //State 2
8'b00000011: assign Out = 43'b1011000000001101001101000000000000000000000; //State 3
8'b00000100: assign Out = 43'b1000010000000100000000000000000000000000000; //State 4
8'b00000101: assign Out = 43'b0100000000000110000000000000000000000000001; //State 5
8'b00000110: assign Out = 43'b0100000000000110000000000000001000000000001; //State 6
8'b00000111: assign Out = 43'b0100000000000110000000000000001000000000001; //State 7
8'b00001000: assign Out = 43'b0100000000000100000000000000000000000000101; //State 8
8'b00001001: assign Out = 43'b0100000000000100000000000000001000000000101; //State 9
8'b00001010: assign Out = 43'b0100000000000100000000000000001000000000101; //State 10
8'b00001011: assign Out = 43'b0100000000000110000000000000000000000000001; //State 11
8'b00001100: assign Out = 43'b0100000000000110000000000000001000000000001; //State 12
8'b00001101: assign Out = 43'b0100000000000110000000000000001000000000001; //State 13
8'b00001110: assign Out = 43'b0100000000000110000000000101101100100000001; //State 14
8'b00001111: assign Out = 43'b0110000000000010000000000111000101101000001; //State 15
8'b00010000: assign Out = 43'b0100000000000110000000000101101100100000000; //State 16
8'b00010001: assign Out = 43'b0110000000000000100000000000000100100000001; //State 17
8'b00010010: assign Out = 43'b0110000000000000001101000000000000000000000; //State 18
8'b00010011: assign Out = 43'b1011000001001100011101000000000000000000000; //State 19
8'b00010100: assign Out = 43'b0100000000000110000000000000010101101000000; //State 20
8'b00010101: assign Out = 43'b0110000000000010100000000010000100100000001; //State 21
8'b00010110: assign Out = 43'b0110000000000000001101000000000000000000000; //State 22
8'b00010111: assign Out = 43'b1011000001011100011101000000000000000000000; //State 23
8'b00011000: assign Out = 43'b0100000000000110000000000000010101101000000; //State 24
8'b00011001: assign Out = 43'b0110000000000000100000000000011100100000001; //State 25
8'b00011010: assign Out = 43'b0110000000000000001101000000000000000000000; //State 26
8'b00011011: assign Out = 43'b1011000001101100011101000000000000000000000; //State 27
8'b00011100: assign Out = 43'b0110000000000010000000000000010101101000000; //State 28
8'b00011101: assign Out = 43'b0100000000000110000000000010000100100000000; //State 29
8'b00011110: assign Out = 43'b0110000000000000100000000000001100100000001; //State 30
8'b00011111: assign Out = 43'b0110000000000000001101000000000000000000000; //State 31
8'b00100000: assign Out = 43'b1011000010000000011101000000000000000000000; //State 32
8'b00100001: assign Out = 43'b0100000000000110000000000000010101101000000; //State 33
8'b00100010: assign Out = 43'b0110000000000010100000000010001100100000001; //State 34
8'b00100011: assign Out = 43'b0110000000000000001101000000000000000000000; //State 35
8'b00100100: assign Out = 43'b1011000010010000011101000000000000000000000; //State 36
8'b00100101: assign Out = 43'b0100000000000110000000000000010101101000000; //State 37
8'b00100110: assign Out = 43'b0110000000000000100000000000011100100000001; //State 38
8'b00100111: assign Out = 43'b0110000000000000001101000000000000000000000; //State 39
8'b00101000: assign Out = 43'b1011000010100000011101000000000000000000000; //State 40
8'b00101001: assign Out = 43'b0110000000000010000000000000010101101000000; //State 41
8'b00101010: assign Out = 43'b0100000000000110000000000010001100100000000; //State 42
8'b00101011: assign Out = 43'b0110000000000000100000000000000100100000001; //State 43
8'b00101100: assign Out = 43'b0110000000000000010000001000011110100000000; //State 44
8'b00101101: assign Out = 43'b0110000000000000000101000000000000000000000; //State 45
8'b00101110: assign Out = 43'b1111000010111000000101000000000000000000000; //State 46
8'b00101111: assign Out = 43'b0110000000000010100000000010000100100000001; //State 47
8'b00110000: assign Out = 43'b0110000000000000010000001000011110100000000; //State 48
8'b00110001: assign Out = 43'b0110000000000000000101000000000000000000000; //State 49
8'b00110010: assign Out = 43'b1111000011001000000101000000000000000000000; //State 50
8'b00110011: assign Out = 43'b0110000000000000100000000000011100100000001; //State 51
8'b00110100: assign Out = 43'b0110000000000000010000001000011110100000000; //State 52
8'b00110101: assign Out = 43'b0110000000000000000101000000000000000000000; //State 53
8'b00110110: assign Out = 43'b1011000011011000000101000000000000000000000; //State 54
8'b00110111: assign Out = 43'b0100000000000110000000000010000100100000000; //State 55
8'b00111000: assign Out = 43'b0110000000000000100000000000001100100000001; //State 56
8'b00111001: assign Out = 43'b0110000000000000010000001000011110100000000; //State 57
8'b00111010: assign Out = 43'b0110000000000000000101000000000000000000000; //State 58
8'b00111011: assign Out = 43'b1111000011101100000101000000000000000000000; //State 59
8'b00111100: assign Out = 43'b0110000000000010100000000010001100100000001; //State 60
8'b00111101: assign Out = 43'b0110000000000000010000001000011110100000000; //State 61
8'b00111110: assign Out = 43'b0110000000000000000101000000000000000000000; //State 62
8'b00111111: assign Out = 43'b1111000011111100000101000000000000000000000; //State 63
8'b01000000: assign Out = 43'b0110000000000000100000000000011100100000001; //State 64
8'b01000001: assign Out = 43'b0110000000000000010000001000011110100000000; //State 65
8'b01000010: assign Out = 43'b0110000000000000000101000000000000000000000; //State 66
8'b01000011: assign Out = 43'b1011000100001100000101000000000000000000000; //State 67
8'b01000100: assign Out = 43'b0100000000000110100000000010001100100000000; //State 68
8'b01000101: assign Out = 43'b0110000000000000100000000000000100100000001; //State 69
8'b01000110: assign Out = 43'b0110000000000000001101100000000000000000000; //State 70
8'b01000111: assign Out = 43'b1011000100011100011101100000000000000000000; //State 71
8'b01001000: assign Out = 43'b0100000000000110000000000000010101101000000; //State 72
8'b01001001: assign Out = 43'b0110000000000010100000000010000100100000001; //State 73
8'b01001010: assign Out = 43'b0110000000000000001101100000000000000000000; //State 74
8'b01001011: assign Out = 43'b1011000100101100011101100000000000000000000; //State 75
8'b01001100: assign Out = 43'b0100000000000110000000000000010101101000000; //State 76
8'b01001101: assign Out = 43'b0110000000000000100000000000011100100000001; //State 77
8'b01001110: assign Out = 43'b0110000000000000001101100000000000000000000; //State 78
8'b01001111: assign Out = 43'b1011000100111100011101100000000000000000000; //State 79
8'b01010000: assign Out = 43'b0110000000000010000000000000010101101000000; //State 80
8'b01010001: assign Out = 43'b0100000000000110000000000010000100100000000; //State 81
8'b01010010: assign Out = 43'b0110000000000000100000000000001100100000001; //State 82
8'b01010011: assign Out = 43'b0110000000000000001101100000000000000000000; //State 83
8'b01010100: assign Out = 43'b1011000101010000011101100000000000000000000; //State 84
8'b01010101: assign Out = 43'b0100000000000110000000000000010101101000000; //State 85
8'b01010110: assign Out = 43'b0110000000000010100000000010001100100000001; //State 86
8'b01010111: assign Out = 43'b0110000000000000001101100000000000000000000; //State 87
8'b01011000: assign Out = 43'b1011000101100000011101100000000000000000000; //State 88
8'b01011001: assign Out = 43'b0100000000000110000000000000010101101000000; //State 89
8'b01011010: assign Out = 43'b0110000000000000100000000000011100100000001; //State 90
8'b01011011: assign Out = 43'b0110000000000000001101100000000000000000000; //State 91
8'b01011100: assign Out = 43'b1011000101110000011101100000000000000000000; //State 92
8'b01011101: assign Out = 43'b0110000000000010000000000000010101101000000; //State 93
8'b01011110: assign Out = 43'b0100000000000110000000000010011100100000000; //State 94
8'b01011111: assign Out = 43'b0110000000000000100000000000000100100000001; //State 95
8'b01100000: assign Out = 43'b0110000000000000010000001000011110100000000; //State 96
8'b01100001: assign Out = 43'b0110000000000000000101100000000000000000000; //State 97
8'b01100010: assign Out = 43'b1111000110001000000101100000000000000000000; //State 98
8'b01100011: assign Out = 43'b0110000000000010100000000010000100100000001; //State 99
8'b01100100: assign Out = 43'b0110000000000000010000001000011110100000000; //State 100
8'b01100101: assign Out = 43'b0110000000000000000101100000000000000000000; //State 101
8'b01100110: assign Out = 43'b1111000110011000000101100000000000000000000; //State 102
8'b01100111: assign Out = 43'b0110000000000000100000000000011100100000001; //State 103
8'b01101000: assign Out = 43'b0110000000000000010000001000011110100000000; //State 104
8'b01101001: assign Out = 43'b0110000000000000000101100000000000000000000; //State 105
8'b01101010: assign Out = 43'b1011000110101000000101100000000000000000000; //State 106
8'b01101011: assign Out = 43'b0100000000000110000000000010000100100000000; //State 107
8'b01101100: assign Out = 43'b0110000000000000100000000000001100100000001; //State 108
8'b01101101: assign Out = 43'b0110000000000000010000001000011110100000000; //State 109
8'b01101110: assign Out = 43'b0110000000000000000101100000000000000000000; //State 110
8'b01101111: assign Out = 43'b1111000110111100000101100000000000000000000; //State 111
8'b01110000: assign Out = 43'b0110000000000010100000000010001100100000001; //State 112
8'b01110001: assign Out = 43'b0110000000000000010000001000011110100000000; //State 113
8'b01110010: assign Out = 43'b0110000000000000000101100000000000000000000; //State 114
8'b01110011: assign Out = 43'b1111000111001100000101100000000000000000000; //State 115
8'b01110100: assign Out = 43'b0110000000000000100000000000011100100000001; //State 116
8'b01110101: assign Out = 43'b0110000000000000010000001000011110100000000; //State 117
8'b01110110: assign Out = 43'b0110000000000000000101100000000000000000000; //State 118
8'b01110111: assign Out = 43'b1011000111011100000101100000000000000000000; //State 119
8'b01111000: assign Out = 43'b0100000000000110000000000010001100100000000; //State 120
default: assign Out = 43'b0110000000000010000000000001011101101000000; //State 0 //Possible source of bugs if reset is not defined correctly in table to increment to next state.
endcase
end
endmodule

module ControlRegister(output reg [2:0] N, output reg Inv, output reg [3:0] CUOp, output reg [1:0] S, m, MA, MC, MuxALUBSel, output reg [7:0] CR, output reg MB, RFload, IRload, MARload, MDRload, RW, MOV, MOC, MuxALUASel, MD, ME, MARClr, MDRClr, IRClr, SRload, SRClr, Cond, input [42:0] In, input CLR, CLK);
always @(posedge CLK, negedge CLR) begin
	//$display("State Signlas: %b", In);
        assign N = In[42:40];
        assign Inv = In[39];
        assign S = In[38:37];
        assign CR = In[36:29];
        assign RFload = In[28];
        assign IRload = In[27];
        assign MARload = In[26];
        assign MDRload = In[25];
        assign RW = In[24];
        assign MOV = In[23];
        assign MOC = In[22];
        assign m = In[21:20];
        assign MA = In[19:18];
        assign MB = In[17];
        assign MC = In[16:15];
        assign MuxALUASel = In[14];
        assign MuxALUBSel = In[13:12];
        assign MD = In[11];
        assign ME = In[10];
        assign CUOp = In[9:6];
        assign MARClr = In[5];
        assign MDRClr = In[4];
        assign IRClr = In[3];
        assign SRload = In[2];
        assign SRClr = In[1];
        assign Cond = In[0];
    end
endmodule
