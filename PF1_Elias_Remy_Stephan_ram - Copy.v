module ram256x8(output reg [31:0] DataOut, input Enable, ReadWrite, input [7:0] Address, input [31:0] DataIn, input [1:0] Mode, output reg moc);
	reg [7:0] Memory[0:255]; //256 locations of 8bits
	always @ (Enable, ReadWrite)
	if(Enable) begin
		if(ReadWrite) begin
			case(Mode)
				2'b00: assign DataOut = Memory[Address];
				2'b01: assign DataOut = {Memory[Address], Memory[Address+1]};
				2'b10: assign DataOut = {Memory[Address], Memory[Address+1], Memory[Address+2], Memory[Address+3]};
				2'b11: begin assign DataOut = {Memory[Address], Memory[Address+1], Memory[Address+2], Memory[Address+3]};
				#5 assign DataOut = {Memory[Address+4], Memory[Address+5], Memory[Address+6], Memory[Address+7]};
				end			
			endcase
		end
		else begin
			case(Mode)
				2'b00: Memory[Address] = DataIn[7:0];
				2'b01:begin
				Memory[Address] = DataIn[15:8];
				Memory[Address+1] = DataIn[7:0];
				end
				2'b10:begin
				Memory[Address] = DataIn[31:24];
				Memory[Address+1] = DataIn[23:16];
				Memory[Address+2] = DataIn[15:8];
				Memory[Address+3] = DataIn[7:0];
				end
				2'b11:begin
				#5 Memory[Address] = DataIn[31:24]; //Originally: "... = DataIn[63:56]", which gave out of bounds warning.
				#5 Memory[Address+1] = DataIn[23:16]; //Originally: "... = DataIn[55:48]", which gave out of bounds warning.
				#5 Memory[Address+2] = DataIn[15:8]; //Originally: "... = DataIn[47:40]", which gave out of bounds warning.
				#5 Memory[Address+3] = DataIn[7:0]; //Originally: "... = DataIn[39:32]", which gave out of bounds warning.
				Memory[Address+4] = DataIn[31:24];
				Memory[Address+5] = DataIn[23:16];
				Memory[Address+6] = DataIn[15:8];
				Memory[Address+7] = DataIn[7:0];
				end
			endcase
		end
	assign moc = 1;
	end
endmodule

module RAM_Access;
	integer fi,fo,code,i;
	reg [7:0] data;
	reg Enable, ReadWrite;
	reg [7:0] DataIn;
	reg [7:0] Address;
	reg [1:0] Mode;
	wire [7:0] DataOut;
	wire MOC;
	ram256x8 ram1 (DataOut, Enable, ReadWrite, Address, DataIn,Mode, MOC);
	initial begin
		Mode = 2'b00;
		fi = $fopen("PF1_Elias_Remy_Stephan_ramdata.txt", "r");
		Address = 8'b00000000;
		while(!$feof(fi)) begin
			code = $fscanf(fi, "%b", data);
			ReadWrite = 1'b0;
			DataIn = data;
			Enable = 1'b1;
			#5 Enable = 1'b0;
			Address <= Address+1;
		end
		$fclose(fi);
	end

	initial begin
		#10000 fo = $fopen("PF1_Elias_Remy_Stephan_ramdata.out", "w"); //Delayed to prevent reading and writing at the same time
		Enable = 1'b0;
		ReadWrite = 1'b1;
		Address = #1 8'b00000000;
		repeat (256) begin
			#5 Enable = 1'b1;
			#5 Enable = 1'b0;
			Address = Address+1;
		end
		$finish;
	end
	always @ (posedge Enable)
	begin
		#1;
		$fdisplay(fo,"data at %d = %b %d", Address, DataOut, $time);
	end
endmodule