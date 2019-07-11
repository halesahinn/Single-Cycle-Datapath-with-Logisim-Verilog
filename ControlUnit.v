module ControlUnit( input 			clk,
		    input 	[ 15 : 0 ]	cuInput,
		    input 	[ 8  : 0 ]	sP,
		    output	[ 1  : 0 ]	aluSelect,	
		    output	[ 3  : 0 ]	dr,
		    output	[ 3  : 0 ]	sr1,
		    output	[ 3  : 0 ]	sr2Imm,
		    output	[ 15 : 0 ]	jumpAddr,
		    output	[ 15 : 0 ]	ldStAddr,
		    output 			immSelect,
		    output 			pcSelect,
		    output 			spSelect,
		    output 			regWrite,
		    output 			memWrite,
		    output 			memRead,
		    output 			regWriteSelect,
		    output 			store,
		    output 			instRegWrite,
		    output 			pcWrite,
		    output 			spWrite ) ;
					
	// Define wires.
	wire jump, orOri, andAndi, addAddi, ld, st, push, pop ;
	wire [ 2 : 0 ] opcode ;
	reg w ;
	
	initial w = 1'b0 ; // Initalize w.
		
	// Assign the addresses, destination and source (and immediate val.) registers.
	assign immSelect = cuInput[ 0  : 0  ] ;
	assign jumpAddr	 = cuInput[ 12 : 0  ] ;
	assign ldStAddr  = cuInput[ 8  : 0  ] ;
	assign aluSelect = cuInput[ 14 : 13 ] ;
	assign dr	 = cuInput[ 12 : 9  ] ;
	assign sr1	 = cuInput[ 8  : 5  ] ;
	assign sr2Imm	 = cuInput[ 4  : 1  ] ;
	
	// Assign the decoder input ;
	assign opcode = cuInput[ 15 : 13 ] ;
	
	// Assign decoder outputs.
	assign jump 	= ~opcode[ 2 ] & ~opcode[ 1 ] & ~opcode[ 0 ] ; // 000
	assign orOri 	= ~opcode[ 2 ] & ~opcode[ 1 ] &  opcode[ 0 ] ; // 001
	assign andAndi 	= ~opcode[ 2 ] &  opcode[ 1 ] & ~opcode[ 0 ] ; // 010
	assign addAddi 	= ~opcode[ 2 ] &  opcode[ 1 ] &  opcode[ 0 ] ; // 011
	assign ld 	=  opcode[ 2 ] & ~opcode[ 1 ] & ~opcode[ 0 ] ; // 100
	assign st 	=  opcode[ 2 ] & ~opcode[ 1 ] &  opcode[ 0 ] ; // 101
	assign push 	=  opcode[ 2 ] &  opcode[ 1 ] & ~opcode[ 0 ] ; // 110
	assign pop 	=  opcode[ 2 ] &  opcode[ 1 ] &  opcode[ 0 ] ; // 111
	
	// W changes value every clock rising edge.
	always @( posedge clk )
	begin
		w <= ~w ;
	end // End of Always.
	
	// Assign control signals now using the above decoder outputs and w.
	assign pcSelect 	= jump ;
	assign spSelect 	= push ;
	assign regWrite 	= ( orOri | andAndi | addAddi | ld | pop ) & w ;
	assign memWrite 	= ( st | push ) & w ;
	assign memRead  	= ( ld | pop  ) & w ;
	assign regWriteSelect 	= ( ld | pop  ) ;
	assign store		= st ;
	
	assign instRegWrite 	= ~w ;
	assign pcWrite	    	=  w ;
	assign spWrite 	    	= ( ( |sP & pop ) | push ) & w ;
		
endmodule