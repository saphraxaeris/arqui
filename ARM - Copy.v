module ControlUnit( //Remember that N, Inv, S, and CR are for internal use only.
	output [3:0] CUOp, //new
	output [1:0] m,
	output [1:0] MA,
	output [1:0] MC,
	output [1:0] MuxALUBSel,
	output  MuxALUASel,
		MB,
		MD,
		ME,
		IRload,
		IRClr,
		RFload,
		MDRload,
		MDRClr,
		SRload,
		SRClr,
		MARload,
		MARClr,
		RW,
		MOV,

	input [31:0] IRContents,
	input   MOC,
		Cond,
		reset
	);

	///////////////////////////////////////CU's body///////////////////////////////////////////

	////////////////////////////My wires//////////////////////////

	wire [7:0] incrementerReg_out;
	wire [7:0] incrementerAdder_out;
	wire [7:0] muxMicrostore_out;
	wire [7:0] encoder_out;		
	wire [7:0] ONE = 8'b00000001;
	wire GND = 0;	
	wire [7:0] CtrlReg_CR;
	wire [1:0] nsaSelector_out;
	wire [42:0] microstore_out;

	wire [2:0] nsaSelector_n;
	wire inverter_inv;
	wire [3:0] CtrlReg_CUOp;
	wire [1:0] muxInverter_s;
	wire [1:0] CtrlReg_m;
	wire [1:0] CtrlReg_MA;
	wire [1:0] CtrlReg_MC;
	wire [1:0] CtrlReg_MuxALUBSel;
	wire CtrlReg_MB;
	wire CtrlReg_RFload;
	wire CtrlReg_IRload;
	wire CtrlReg_MARload;
	wire CtrlReg_MDRload;
	wire CtrlReg_RW;
	wire CtrlReg_MOV;
	wire CtrlReg_MOC;
	wire CtrlReg_MuxALUASel;
	wire CtrlReg_MD;
	wire CtrlReg_ME;
	wire CtrlReg_MARClr;
	wire CtrlReg_MDRClr;
	wire CtrlReg_IRClr;
	wire CtrlReg_SRload;
	wire CtrlReg_SRClr;
	wire CtrlReg_Cond;

	wire inverter_out;
	wire muxInverter_out;
	
	////////////////////////////////////////////////////////

	////////////////////////////Modules Connections/////////////////////////////////////

	IncrementerRegister IncReg(incrementerReg_out, incrementerAdder_out);
	IncrementerRegisterAdder IncAdd(incrementerAdder_out, muxMicrostore_out);
	Mux4x1_8bits muxMicrostore(muxMicrostore_out, encoder_out, ONE, CtrlReg_CR, incrementerReg_out, nsaSelector_out);
	Microstore microstore(muxMicrostore_out, microstore_out);
	ControlRegister CtrlReg(nsaSelector_n, inverter_inv, CtrlReg_CUOp, muxInverter_s, CtrlReg_m, CtrlReg_MA,
				CtrlReg_MC, CtrlReg_MuxALUBSel, CtrlReg_CR, CtrlReg_MB, CtrlReg_RFload, CtrlReg_IRload,
				CtrlReg_MARload, CtrlReg_MDRload, CtrlReg_RW, CtrlReg_MOV, CtrlReg_MOC, CtrlReg_MuxALUASel,
				CtrlReg_MD, CtrlReg_ME, CtrlReg_MARClr, CtrlReg_MDRClr, CtrlReg_IRClr, CtrlReg_SRload,
				CtrlReg_SRClr, CtrlReg_Cond, microstore_out);
	Encoder encoder(encoder_out, IRContents);

	NextStateAddressSelector nsaSelector(nsaSelector_n, inverter_out, nsaSelector_out);
	Inverter inv(inverter_out, muxInverter_out, inverter_inv);
	Mux4x1_1bit muxInverter(muxInverter_out, MOC, Cond, GND, GND, MuxInverter_s);

	///////////////////////////////////////////////////////////////////////////////////

	//////////////////////////Control Unit's Output Assignments////////////////////////

	assign CUOp = CtrlReg_CUOp;
	assign m = CtrlReg_m;
	assign MA = CtrlReg_MA;
	assign MC = CtrlReg_MC;
	assign MuxALUBSel = CtrlReg_MuxALUBSel;
	assign MuxALUASel = CtrlReg_MuxALUASel;
	assign MB = CtrlReg_MB;
	assign MD = CtrlReg_MD;
	assign ME = CtrlReg_ME;
	assign IRload = CtrlReg_IRload;
	assign IRClr = CtrlReg_IRClr;
	assign RFload = CtrlReg_RFload;
	assign MDRload = CtrlReg_MDRload;
	assign MDRClr = CtrlReg_MDRClr;
	assign SRload = CtrlReg_SRload;
	assign SRClr = CtrlReg_SRClr;
	assign MARload = CtrlReg_MARload;
	assign MARClr = CtrlReg_MARClr;
	assign RW = CtrlReg_RW;
	assign MOV = CtrlReg_MOV;
endmodule//Control Unit

//Module Datapath
module datapath(
	input [3:0] CUOp,
	input [1:0] m,
	input [1:0] MA,
	input [1:0] MC,
	input [1:0] MuxALUBSel,
	input MuxALUASel,
	input MB,
	input MD,
	input ME,
	input IRload,
	input IRClr,
	input RFload,
	input MDRload,
	input MDRClr,
	input SRload,
	input SRClr,
	input MARload,
	input MARClr,
	input RW,
	input MOV,
	input CLK,
	input reset,

	output wire [31:0] IRContents,
	output wire MOC,
		    Cond
	);
	
	/////////////////////////Datapath's body//////////////////////////////////////

	////////////////////////////My wires//////////////////////////

	wire [31:0] RAM_out;
	wire [31:0] IR_out;
	wire [31:0] ALU_out;
	wire [3:0] MuxARegFile_out;
	wire [3:0] MuxBRegFile_out;
	wire [3:0] MuxCRegFile_out;
	wire [31:0] rf_pa;
	wire [31:0] rf_pb;
	wire [31:0] shifterAndSignExt_out;
	wire [31:0] muxALUB_out;
	wire [31:0] muxALUA_out;
	wire [31:0] mdr_out;
	wire [31:0] ZERO = 32'b00000000000000000000000000000000;
	wire [31:0] FOUR = 32'b00000000000000000000000000000100;
	wire [3:0] muxCUOp_out;
	wire SR_n;
	wire SR_z;
	wire SR_c;
	wire SR_v;
	wire ALU_n;
	wire ALU_z;
	wire ALU_c;
	wire ALU_v;
	wire cond_test_out;
	
	wire [31:0] muxMDR_out;
	wire [7:0] mar_out;
	wire sign;
	wire RAM_rw;
	wire RAM_moc;

	////////////////////////////////////////////////////////

	////////////////////////////Modules Connections/////////////////////////////////////

	InstructionRegister(IR_out, RAM_out, IRload, IRClr, CLK);

	Mux4x1_4bits muxARegFile(MuxARegFile_out, IR_out[19:16], IR_out[15:12], 4'b1111, 4'b0000, MA);
	Mux2x1_4bits muxBRegFile(MuxBRegFile_out, IR_out[3:0], 4'b1111, MB);
	Mux4x1_4bits muxCRegFile(MuxCRegFile_out, IR_out[15:12], 4'b1111, IR_out[19:16], 4'b1110, MC);
	Reg_File rf(rf_pa, rf_pb, ALU_out, MuxARegFile_out, MuxBRegFile_out, MuxCRegFile_out, 2'b11, RFload, reset, CLK); //2'b11 fixes an error in the Register File, where Muxes where selecting the outputs of PA and PB, which wasn't necessary.
	ShifterAndSignExt shiftAndSign(shifterAndSignExt_out, IR_out, rf_pb);
	
	Mux4x1_32bits muxALUB(muxALUB_out, rf_pb, shifterAndSignExt_out, mdr_out, ZERO, muxALUBSel);
	Mux2x1_32bits muxALUA(muxALUA_out, rf_pa, FOUR, muxALUASel);
	Mux2x1_4bits muxCUOp(muxCUOp_out, IR_out[24:21], CUOp, MD);
	ALU alu(muxALUA_out, muxALUB_out, muxCUOp_out, SR_c, ALU_out, ALU_n, ALU_z, ALU_c, ALU_v);
	StatusRegister SR(SR_n, SR_z, SR_c, SR_v, ALU_n, ALU_z, ALU_c, ALU_v, SRload, SRClr, CLK);
	cond_test condTest(cond_test_out, SR_n, SR_z, SR_c, SR_v, IR_out[31:28]);
	
	Mux2x1_32bits muxMDR(muxMDR_out, RAM_out, ALU_out, ME);
	MDR mdr(mdr_out, muxMDR_out, MDRload, MDRClr, CLK);
	MAR mar(mar_out, ALU_out, MARload, MARClr, CLK);

	and(sign, IR_out[20], IR_out[6]);
	not(RAM_rw, RW);
	ram256x8 RAM(RAM_out, MOV, RAM_rw, mar_out, mdr_out, RAM_moc);	

	///////////////////////////////////////////////////////////////////////////////////

	//////////////////////////Datapath's Output Assignments////////////////////////

	assign IRContents = IR_out;
	assign MOC = RAM_moc;
	assign Cond = cond_test_out;
endmodule// Datapath

module ARM(input CLK, reset);
	wire [3:0] CUOp; //new
	wire [1:0] m;
	wire [1:0] MA;
	wire [1:0] MC;
	wire [1:0] MuxALUBSel;
	wire  	MuxALUASel,
		MB,
		MD,
		ME,
		IRload,
		IRClr,
		RFload,
		MDRload,
		MDRClr,
		SRload,
		SRClr,
		MARload,
		MARClr,
		RW,
		MOV;

	wire [31:0] IRContents;
	wire    MOC,
		Cond;

	ControlUnit cu(CUOp, m, MA, MC, MuxALUBSel, MuxALUASel, MB, MD, ME, IRload, IRClr,
		    RFload, MDRload, MDRClr, SRload, SRClr, MARload, MARClr, RW, MOV,
		    IRContents, MOC, Cond, reset);

	Datapath dp(CUOp, m, MA, MC, MuxALUBSel, MuxALUASel, MB, MD, ME, IRload, IRClr,
		    RFload, MDRload, MDRClr, SRload, SRClr, MARload, MARClr, RW, MOV,
		    CLK, reset, IRContents, MOC, Cond);
endmodule

module arm_tester();
	reg CLK,reset;

	// Initialize the ARM module
	ARM arm(CLK, reset);

	// Reset the control unit

	initial begin 
		reset = 1;
		#1 reset = 0;
	end

	// Start the clock generator
	integer clock_speed = 5;
	integer clock_repetitions = 700;
	
	initial begin
		CLK = 1;

		repeat (clock_repetitions) #clock_speed begin
		CLK = ~CLK;
		//$display("%3d", CLK);
		end

	end

	// Load the instruction file to the RAM module
	integer   fd, code, positionInMemory;
	reg [31:0] data;
	initial begin
		fd = $fopen("testcode_arm2.txt","r"); 
		positionInMemory = 0;
		while (!($feof(fd))) begin
			code = $fscanf(fd, "%b", data);
			arm.datapath.ram.mem[positionInMemory]= data[7:0];
			positionInMemory = positionInMemory + 1;
		end
		$fclose(fd);
	end

	//Charlie You can play with this: The displays and monitor change the values you want to show.
	//Output data:
	initial $display("Dump:");
	always @(arm.CU.state_mux_out) begin
		$monitor(" marout = %3d,SRout= %3b", arm.datapath.mar.out,arm.datapath.SRContents);
		//$display(" BRout = %3b,offsetShifted= %3b , PC= %3d", arm.datapath.br_out,arm.datapath.BR.offsetShifted , arm.datapath.rf.Reg_out_15);
		//$monitor(" Register 5 = %3d,Register 3 = %3d,Register 2 = %3d, PC= %3d, out=%3b", arm.datapath.rf.Reg_out_5,arm.datapath.rf.Reg_out_3,arm.datapath.rf.Reg_out_2, arm.datapath.rf.Reg_out_15,arm.datapath.PC_out);
		//$monitor("RAM LOAD= %3b, PC=%3d, aluout= %3b", arm.datapath.ram_out, arm.datapath.rf.Reg_out_15,arm.datapath.alu_out);
		//$monitor("address =%3d,state_out =%b,controlunits=%b, mar=%b, ramout=%b, PC=%3d, byte_mode= %3b", arm.CU.state_mux_out,arm.CU.next_state.next,arm.CU.rom_out,arm.datapath.mar.out,arm.datapath.ram_out,arm.datapath.rf.Reg_out_15,arm.datapath.byte_mode);
	end



	// // Output data:
	// initial $display("mar Dump:");
	// integer count = 0;
	// always @(arm.datapath.mar.out) begin
	// 	$display("%3d: %3d", count, arm.datapath.mar.out);
	// 	count = count + 1;
	// end

	initial begin
		#(clock_speed*clock_repetitions);
		$display("\n\nMemory Dump:");
		positionInMemory = 0;
		repeat (64) begin
			$display ("%3d: %b %b %b %b", positionInMemory, 
											arm.datapath.ram.mem[positionInMemory], arm.datapath.ram.mem[positionInMemory+1], 
											arm.datapath.ram.mem[positionInMemory+2], arm.datapath.ram.mem[positionInMemory+3]);
			positionInMemory = positionInMemory + 4;
		end
	end
endmodule

/*
module cu_tb ();

	reg MOC=1,CLK,reset;
	reg [3:0] SRContents = 0000;
	reg [31:0] IRContents = 32'b1110_0010_0010_1111_0000_0000_0000_0000;

	wire [1:0] m;
	wire [1:0] MA ;
	wire [1:0] MC ;
	wire [1:0] MuxALUBSel ;
	wire [1:0] mux7_sel ;
	wire [1:0] mux6_sel ;
	wire [1:0] mux11_sel ;
	wire [1:0] mux12_sel ;
	wire [2:0]  ;
	wire [1:0] RFload ;
	
	wire  MB,
		MuxALUASel,
		MD,
		Dec_Reg_EN,
		register_file_clr,
		MDRClr,
		MDRload,
		ME,
		IRClr,
		IRload,
		SRload,
		SRClr,
		mar_mux_sel,
		MARload,
		MARClr,
		RW,
		MOV,
		ram_buffer_enable,
		alu_buffer_enable;

	

	ControlUnit CU(m,MA,MC,
	MuxALUBSel,mux7_sel,mux6_sel,mux11_sel,mux12_sel, RFload ,
	MB,MuxALUASel,MD,Dec_Reg_EN,	register_file_clr,MDRClr,
	MDRload,	ME,IRClr,IRload,SRload,SRClr,
	mar_mux_sel,MARload,	MARClr,RW,MOV,ram_buffer_enable,
	alu_buffer_enable,MOC,CLK,reset,
	SRContents,IRContents);

    initial begin                   //Clock generator
        CLK = 1'b0;
        repeat(10) #5 CLK = ~CLK;
    end

    initial begin
    	#10
    	CU.state_mux.Y = 8'd000;

    	#20
    	CU.state_mux.Y = 8'd0100;
    end

	initial begin
		$monitor("State_MUX_out: %d  | Pipeline: %b| Clock: %b | Time: %1d", CU.state_mux.Y, CU.pipeline_reg.out, CLK, $time);
	end
endmodule
*/