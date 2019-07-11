////////////////////////////////////////////////////////////////////////////////////////////////////////
////// Hale Þahin 150116841																Assembler //////
//////		Gülþah Yýlmaz 150113854		[CSE3015 Digital Logic Design Project]		12.12.2016	  //////	
//////			Burak Canik	150115502									CSE3015 Project.cpp		  //////
////////////////////////////////////////////////////////////////////////////////////////////////////////
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm>

// Prints all elements in the given array (std::vector) to the file (ofstream).
void PrintArrayToFile( const std::vector< int >& array, std::ofstream& ofs )
{	
	for( auto& e : array ) // Use a for each loop to iterate through the array (vector).
		ofs << e ;
}

// Converts from decimal to unsigned binary.
std::vector< int > DecimalToUnsignedBinary( int decimal, int bitSize )
{
	std::vector< int > binary( bitSize ) ; // Define an array (std::vector) to hold the bits.

	int i = 0 ;
	while( decimal >= 0 && i < bitSize - 1 )
	{
		binary[ i ] = decimal % 2 ;
		decimal /= 2 ;
		i++ ;
	}
	binary[ bitSize - 1 ] = decimal ; // Don't forget the last bit.

	std::reverse( binary.begin(), binary.end() ) ; // Use std::reverse to reverse the bits in our array (std::vector).

	return binary ;
}

// Converts from decimal to signed binary.
std::vector< int > DecimalToSignedBinary( int decimal, int bitSize )
{
	std::vector< int > binary( bitSize ) ; // Define an array (std::vector) to hold the bits.

	// If this is a positive number or 0, just use the unsigned function.
	if( decimal >= 0 )
		binary = DecimalToUnsignedBinary( decimal, bitSize ) ;
	// If it's negative, follow the steps below (2's complement method).
	else 
	{
		// 1) Convert to the absolute value.
		int decimalABS = std::abs( decimal ) ;

		// 2) Convert to binary.
		binary = DecimalToUnsignedBinary( decimalABS, bitSize ) ;

		// 3) Leave all least significant zeroes and the FIRST least significant one intact, flip the rest.
		//		3.a) Loop until FIRST least significant one is found.int i = 0 ;
		int i = bitSize - 1 ;
		while( binary.at( i ) != 1 ) 
			i-- ;

		//		3.b) Flip the rest of the more signficant bits.
		for( i = i - 1 ; i >= 0 ; i-- )
			binary.at( i ) = 1 - binary.at( i ) ;
	}

	return binary ;
}

// Converts from binary to hexadecimal.
std::string BinaryToHexadecimal( std::string binaryStr )
{
	std::vector< int > binary ; // Convert to an array (std::vector).
	for( auto& e : binaryStr )	// Using a for each loop, convert each char to int.
		binary.push_back( static_cast< int >( e - 48 ) ) ; // 48 = ASCII for '0'.

	// Then convert from binary to hexadecimal.
	std::string hexadecimalStr ;

	for( int i = binary.size() - 1 ; i >= 0 ; i -= 4 ) // Looping from LSB to MSB (reverse loop).
	{	// Compute the hex digit, convert to char, then add to the string.
		int inBase16 = binary.at( i - 0 ) * 1 + binary.at( i - 1 ) * 2 +
					   binary.at( i - 2 ) * 4 + binary.at( i - 3 ) * 8 ;
		hexadecimalStr += ( inBase16 >= 10 ) ? static_cast< char >( inBase16 + 65 - 10 )   // 65 = ASCII for 'A'.
											 : static_cast< char >( inBase16 + 48      ) ; // 38 = ASCII for '0'.
	}

	std::reverse( hexadecimalStr.begin(), hexadecimalStr.end() ) ; // Reverse the digits.

	return hexadecimalStr ;
}

// Encodes given operation and operands into a binary machine instruction and writes it into a file.
void EncodeToFile( const std::string operation, std::string operands, std::ofstream& ofs )
{
	// Process depending on the instruction type.
	if( operation == "JMP" ) // 3 bits opcode, 13 bits for addressing. Address range = [-4096, 4095]
	{
		// Example: "JMP #-1873". Just extract the string following '#' and convert to int, then to binary.
		std::vector< int > address = DecimalToSignedBinary( std::stoi( operands.substr( 1 ) ), 13 ) ;

		// Print the opcode and operands.
		ofs << "000" ;
		PrintArrayToFile( address, ofs ) ;
	}
	else if( operation == "OR"  || operation == "AND"  || operation == "ADD" || 
			 operation == "ORI" || operation == "ANDI" || operation == "ADDI" )
	{	// 3 bits opcode, 3x 4 bits for dest, src1, src2/Imm and finally 1 bit for immediate flag.
		// Example: "ADDI R3,R13,#-2". Extract the register numbers and imm, then convert them to int.
		int comma1Pos = operands.find_first_of( ',' ) ;
		int comma2Pos = operands.find_last_of( ',' ) ;
		int destinationInt  = std::stoi( operands.substr( 1, comma1Pos ) ) ;
		int source1Int	    = std::stoi( operands.substr( comma1Pos + 2, comma2Pos - ( comma1Pos + 2 ) ) ) ;
		int source2OrImmInt	= std::stoi( operands.substr( comma2Pos + 2 ) ) ;

		// Then convert them to binary.
		std::vector< int > destination  = DecimalToSignedBinary( destinationInt,  4 ) ;
		std::vector< int > source1	    = DecimalToSignedBinary( source1Int,	  4 ) ;
		std::vector< int > source2OrImm	= DecimalToSignedBinary( source2OrImmInt, 4 ) ;

		// Print the opcode and operands.
			 if( operation == "OR"  || operation == "ORI"  ) ofs << "001" ;
		else if( operation == "AND" || operation == "ANDI" ) ofs << "010" ;
		else if( operation == "ADD" || operation == "ADDI" ) ofs << "011" ;

		PrintArrayToFile( destination,  ofs ) ;
		PrintArrayToFile( source1,	    ofs ) ;
		PrintArrayToFile( source2OrImm,	ofs ) ;

		ofs << ( operation.back() == 'I' ) ? "1" : "0" ;
	}
	else if( operation == "LD" || operation == "ST" ) // 3 bits opcode, 4 bits register, 9 bits for addressing.
	{
		// Example: "LD R13,#-4". Just extract the numbers following 'R' and '#' and convert to int, then to binary.
		int commaPos = operands.find( ',' ) ;
		std::vector< int > srcOrDest = DecimalToSignedBinary( std::stoi( operands.substr( 1, commaPos - 1 ) ), 4 ) ;
		std::vector< int > address	 = DecimalToSignedBinary( std::stoi( operands.substr( 4	) ), 9 ) ;

		// print the opcode and operands.
		operation == "LD" ? ofs << "100" : ofs << "101" ; // 100 for "LD", 101 for "ST".
		PrintArrayToFile( srcOrDest, ofs ) ;
		PrintArrayToFile( address,	 ofs ) ;
	}
	else if( operation == "PUSH" || operation == "POP" ) // 3 bits opcode, 4 bits register, rest = don't care.
	{
		// Example: "PUSH R1" or "POP R13". Just extract the number following 'R' and convert to int, then to binary.
		std::vector< int > source = DecimalToSignedBinary( std::stoi( operands.substr( 1 ) ), 4 ) ;

		// Print the opcode and the operand.
		operation == "PUSH" ? ofs << "110" : ofs << "111" ; // 110 for "PUSH", 111 for "POP".
		PrintArrayToFile( source, ofs ) ;
		ofs << "000000000" ; // Don't care about the last 9 bits, set to zeroes for convenience.
	}
	ofs << std::endl ; // Get to the next line.
}

int main()
{
	// Open the file containing assembly instructions.
	std::ifstream inputFileStream( "Instructions.asm" ) ;

	if( inputFileStream.fail() )
		std::cout << "Could not open the instructions file. Assembler shutting down..." << std::endl ;
	else
	{
		// Create and open a file that will be containing the "assembled" machine code.
		std::ofstream outputFileStream( "AssemblerOutput.bin" ) ;

		while( !inputFileStream.eof() ) // Iterate through each line in the file.
		{
			std::string operation, operands ;
			inputFileStream >> operation >> operands ;				// Extract the operation and operands.
			EncodeToFile( operation, operands, outputFileStream ) ;	// Encode the instructions and write to file.
		}

		// Close and clear the flags of both files.
		inputFileStream.close() ;
		inputFileStream.clear() ;
		outputFileStream.close() ;
		outputFileStream.clear() ;

		// Open the newly generated machine code file for reading.
		inputFileStream.open( "AssemblerOutput.bin" ) ;

		// Create and open a .hex file that will be containing the hex version of the generated machine code.
		outputFileStream.open( "AssemblerOutput.hex" ) ;

		// Also create another .hex file for logisim input with a special header.
		std::ofstream logisimFileStream( "AssemblerOutputForLogisim.hex" ) ;

		logisimFileStream << "v2.0 raw" << std::endl ;

		while( !inputFileStream.eof() ) // Iterate through each line in the file.
		{
			std::string machineCodeBinStr ;
			inputFileStream >> machineCodeBinStr ; // Extract the binary machine code.
			std::string machineCodeHexStr = BinaryToHexadecimal( machineCodeBinStr ) ; // Convert to hexadecimal.
			outputFileStream  << machineCodeHexStr << std::endl ; // Write to .hex file.
			logisimFileStream << machineCodeHexStr << std::endl ; // Write to .hex file (logisim).
		}

		std::cout << "AssemblerOutput.bin, AssemblerOutput.hex and AssemblerOutputForLogisim.hex\
					  files are generated." << std::endl ;
	} // Currently open files will automatically close upon exiting this block (destructors invoked).

	// Wait for user input to terminate program.
	system( "pause" ) ;
	return 0 ;
}