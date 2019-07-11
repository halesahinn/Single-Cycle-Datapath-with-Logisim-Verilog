module CentralProcessingUnit() ;

	// Define memory components, main registers and the clock.
	reg [ 15 : 0 ] instructionMemory [ 1023 : 0 ], dataMemory [ 1023 : 0 ] ;
	reg [ 15 : 0 ] programCounter, instructionRegister, stackPointer ;
	reg clk ;

	// Define wires and registers.
	wire immSelect, pcSelect, spSelect, regWrite, memWrite, memRead, 
	     regWriteSelect, store, instRegWrite, pcWrite, spWrite ;
	wire [ 1  : 0 ] aluSelect ;
	wire [ 3  : 0 ] dr, sr1, sr2Imm ;
	wire [ 15 : 0 ] jumpAddr, ldStAddr, regFileOutput1, regFileOutput2, aluOutput ;
	reg  [ 15 : 0 ] dataMemoryOutput ;
	// Initialize registers.
	initial
	begin
		programCounter 		= 16'h0000 ;
		instructionRegister 	= 16'h0000 ;
		stackPointer 		= 16'h0000 ;
	end // End of Initial.

	// Decide on spDataAddress (Mux).
	wire [ 15 : 0 ] spDataAddress ;
	assign spDataAddress = ( spSelect == 0 ) ? stackPointer + 16'hffff : stackPointer ;

	// Decide on data memory address.
	wire [ 9 : 0 ] memoryAddress ;
	assign memoryAddress = ( spWrite == 1 ) ? ~spDataAddress[ 9 : 0 ] : { { 1 { ldStAddr[ 8 ] } }, ldStAddr[ 8 : 0 ] } ;
	
	// Update Data Memory.
	always @( posedge clk )
	begin
		if( memWrite == 1 )
			dataMemory[ memoryAddress ] = regFileOutput1 ;
		else if( memRead == 1 )
			dataMemoryOutput = dataMemory[ memoryAddress ] ;
	end // End of Always.

	// Decide on jump offset (0 if no jump) (Mux).
	wire [ 15 : 0 ] jumpOffset ;
	assign jumpOffset = ( pcSelect == 1 ) ? { { 3 { jumpAddr[ 12 ] } }, jumpAddr[ 12 : 0 ] } : 16'h0000 ;
	
	// Compute total offset (that will be used to increment PC).
	wire [ 15 : 0 ] totalOffset ;
	assign totalOffset = jumpOffset + 16'h0001 ;

	// Decide on stack pointer offset (-1 or +1 depending on push/pop) (Mux).
	wire [ 15 : 0 ] spOffset ;
	assign spOffset = ( spSelect == 1 ) ? 16'h0001 : 16'hffff ;

	always @( posedge clk ) if( instRegWrite ) instructionRegister 	<= instructionMemory[ programCounter[ 9 : 0 ] ] ;
	always @( posedge clk ) if( pcWrite ) 	   programCounter 	<= programCounter + totalOffset ;
	always @( posedge clk ) if( spWrite ) 	   stackPointer 	<= stackPointer + spOffset ;
	
	// Decide on aluInput1 (Mux).
	wire [ 15 : 0 ] aluInput1 ;
	//wire [ 15 : 0 ] sr2ImmSignExtended ;
	//assign sr2ImmSignExtended = { { 12 { sr2Imm[ 3 ] } }, sr2Imm[ 3 : 0 ] } ; // Sign Extend.
	assign aluInput1 = ( immSelect == 1 ) ? 16'h0007 : regFileOutput2 ;
	//assign aluInput1 = ( immSelect == 1 ) ? { { 12 { sr2Imm[ 3 ] } }, sr2Imm[ 3 : 0 ] } : regFileOutput2 ;

	// Decide on register file write input (Mux).
	wire [ 15 : 0 ] regFileWrInput ;
	assign regFileWrInput = ( regWriteSelect == 1 ) ? dataMemoryOutput : aluOutput ;

	// Decide on register file read address 1 (Mux).
	wire [ 3 : 0 ] regReadAddr1 ;
	assign regReadAddr1 = ( store == 1 ) ? dr : sr1 ;

	// Define the three main components.
	ArithmeticLogicUnit ALU( aluSelect, aluInput1, regFileOutput1, aluOutput ) ;
	ControlUnit CU( clk, instructionRegister, stackPointer[ 8 : 0 ],
			aluSelect, dr, sr1, sr2Imm, jumpAddr, ldStAddr, immSelect,
		     	pcSelect, spSelect, regWrite, memWrite, memRead, regWriteSelect, store, 
		     	instRegWrite, pcWrite, spWrite ) ;
	RegisterFile RF( clk, regWrite, regReadAddr1, sr2Imm, dr, regFileWrInput, regFileOutput1, regFileOutput2 ) ;

	// Load instruction memory and data memory from file.
	initial  
	begin
		$readmemh( "AssemblerOutput.hex", instructionMemory ) ;
		$readmemh( "DataMemory.dat", dataMemory ) ;
	end // End of Initial.

	// Oscillate the clock.
	initial begin
		clk = 0 ;
		forever #4  clk = ~clk ;
	end

endmodule 