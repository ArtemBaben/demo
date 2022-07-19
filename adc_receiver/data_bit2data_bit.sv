`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// 
// Device 		:   universal
//
/////////////////////////////////////////////////////////////////////////////////
*/
 
module data_bit2data_bit
#(
parameter							PORTS						= 8,
parameter 							INPUT_DATA_WIDTH			= 12,	// 4  
parameter							OUTPUT_DATA_WIDTH			= 16
) 
(
input	wire     	[(PORTS-1):0][(INPUT_DATA_WIDTH-1):0 ]												data_in ,
output	wire     	[(PORTS-1):0][(OUTPUT_DATA_WIDTH-1):0]												data_out
);

////////////////////////////////////////////////////////////////////////////
// Wires and regs
////////////////////////////////////////////////////////////////////////////
genvar 					i;

generate
for (i=0;i<PORTS;i=i+1) begin : generate_bit2bit_word
	assign data_out[i] = { {(OUTPUT_DATA_WIDTH-INPUT_DATA_WIDTH){data_in[i][INPUT_DATA_WIDTH-1]}},data_in[i]}; 
end
endgenerate

 

endmodule

`default_nettype wire

/*
// Description	:	  
//
//
// History 		: 
//              
//
//
////////////////////////////////////////////////////////////////////////////////////
*/