`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// Device 		:   bpac_059
// Description  :	Iserdes calibration module
//
//					Control calibration ISERDES and IDELAY 
//
//
//
//
/////////////////////////////////////////////////////////////////////////////////
*/

module iserdes_calibration_adc
#(
parameter DATA_WIDTH_ADC			=	12	
)
(
// system_interface
input	wire					 				clk_i						,
input	wire									rst_i						,
output	reg										en_calib_idelay_o			,	
input   wire									calibration_done_i_i		,
input   wire									calibration_not_done_i_i	,
input   wire									calibration_done_q_i		,				
input   wire									calibration_not_done_q_i	,
output  reg										adc_calib_complete			,
output  wire  			[7:0]					number_line_calib			,


output	reg										use_inv_q_o					,
output	reg										use_inv_i_o					,

//  				
output	reg										bitslip_i_o					,		
output	reg										bitslip_q_o							
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam IDLE 				= 6'b000001;
localparam EN_CALIB 			= 6'b000010;
localparam WAIT_CALIB			= 6'b000100;
localparam CHANGE_BITSLIP		= 6'b001000;
localparam STOP_CALIB			= 6'b010000;
localparam CALIB_COMPLETE		= 6'b100000;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wires and regs
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
genvar											i								;
reg					[5:0 ]						states							;
reg 				[7:0 ]						number_lines					;		



always@(posedge clk_i)
	begin: global_control
		if(rst_i) begin
			states 				<= IDLE;
			en_calib_idelay_o	<= 1'b0;
			number_lines		<= 8'd0;
			adc_calib_complete	<= 1'b0;
		end
		else begin
			case(states)
				IDLE: begin
					en_calib_idelay_o	<= 1'b0;
					bitslip_i_o 		<= 1'b0; 
					bitslip_q_o 		<= 1'b0; 
					
					if(number_lines<DATA_WIDTH_ADC) begin
						if((!calibration_done_i_i && !calibration_not_done_i_i || !calibration_done_q_i && !calibration_not_done_q_i))
						states 				<= EN_CALIB;
						else 	
						states 				<= IDLE;
					end 
					else states 			<= CALIB_COMPLETE;
						
						
				end		
			
				EN_CALIB: begin
					en_calib_idelay_o	<= 1'b1;
					states 				<= WAIT_CALIB;

				end		
				
				WAIT_CALIB: begin
					if(calibration_not_done_i_i || calibration_not_done_q_i) states <= CHANGE_BITSLIP;
					else if(!calibration_done_i_i && !calibration_not_done_i_i || !calibration_done_q_i && !calibration_not_done_q_i) states <= WAIT_CALIB;
					 else states 		<= STOP_CALIB; 
					 
					bitslip_i_o 		<= 1'b0; 
					bitslip_q_o 		<= 1'b0; 

				end						
				
				CHANGE_BITSLIP: begin
					if(calibration_not_done_i_i)
						bitslip_i_o 	<= 1'b1;
					if(calibration_not_done_q_i)
						bitslip_q_o 	<= 1'b1;
						
					states 				<= IDLE; 		
						
				end					
				
				STOP_CALIB: begin
					if(calibration_done_i_i && calibration_done_q_i)	number_lines <= number_lines + 1;
					states <= IDLE;
				end			

				CALIB_COMPLETE: begin
					adc_calib_complete  <= 1'b1;
					states 				<= CALIB_COMPLETE;

				end 
				
				default: states 		<= IDLE; 
			endcase			
		end
	end

	
always@(posedge clk_i)
	begin
		if(number_lines == 3) use_inv_q_o <= 1'b1; else use_inv_q_o <= 1'b0;  
		if(number_lines == 4) use_inv_i_o <= 1'b1; else use_inv_i_o <= 1'b0;  
	end 	
	
assign number_line_calib = number_lines;	
	
endmodule