module ArithmeticLogicUnit( aluSelect, input1, input2, out ) ;

	// Define inputs and output.
	input  wire [  1 : 0 ]	aluSelect ;
	output reg  [ 15 : 0 ] 	input1, input2 ;
	output reg  [ 15 : 0 ] 	out ;

	always @( aluSelect or input1 or input2 )
	begin
		case( aluSelect )
			2'b00   : out = 16'h0000 ;
			2'b01   : out = input1 | input2 ;
			2'b10   : out = input1 & input2 ;
			2'b11   : out = input1 + input2 ;
			default : out = 16'h0000 ;
		endcase
	end // End of Always.

endmodule 