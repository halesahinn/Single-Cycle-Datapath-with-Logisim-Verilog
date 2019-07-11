module RegisterFile( input 	 		clk,
	   	     input 			writeEnabled,
		     input 	[ 3  : 0 ] 	readAddr1, 
		     input   	[ 3  : 0 ] 	readAddr2,
		     input 	[ 3  : 0 ] 	writeAddr,
		     input 	[ 15 : 0 ] 	inp,
	             output 	[ 15 : 0 ] 	output1, 
		     output 	[ 15 : 0 ] 	output2 ) ;
  
	reg [ 15 : 0 ] registers [ 15 : 0 ] ; // Define registers themselves.
	integer i ;

	// Initialize all register content to zeroes.	
	initial begin
		for( i = 4'b0000 ; i <= 4'b1111 ; i = i + 4'b0001 )
		begin
			registers[ i ] = 16'h0000 ;
		end // End of for loop.
	end // End of Initial.
	
	// Read.
	assign output1 = registers[ readAddr1 ] ;
	assign output2 = registers[ readAddr2 ] ;

	// Write.
	always @( posedge clk )
	begin
		if( writeEnabled ) registers[ writeAddr ] <= inp ;
	end // End of Always.

endmodule 