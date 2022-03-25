`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// Device 		:   bpac_059
// Description  :	Module ADC Data_remapping		
//
// Hystory		: 	
//
/////////////////////////////////////////////////////////////////////////////////
*/

module adc_data_remapping
(
input	wire		[7:0]			Z_ADC1_I_DATA_P								,
input	wire		[7:0]			Z_ADC1_I_DATA_N								,
input	wire		[7:0]			Z_ADC1_Q_DATA_P								,
input	wire		[7:0]			Z_ADC1_Q_DATA_N                             ,
input 	wire		[7:0]			Z_ADC2_I_DATA_P								,
input 	wire		[7:0]			Z_ADC2_I_DATA_N								,
input 	wire		[7:0]			Z_ADC2_Q_DATA_P								,
input 	wire		[7:0]			Z_ADC2_Q_DATA_N                             ,
input 	wire		[7:0]			Z_ADC3_I_DATA_P								,
input 	wire		[7:0]			Z_ADC3_I_DATA_N								,
input 	wire		[7:0]			Z_ADC3_Q_DATA_P								,
input 	wire		[7:0]			Z_ADC3_Q_DATA_N                             ,
input 	wire		[7:0]			Z_ADC4_I_DATA_P								,
input 	wire		[7:0]			Z_ADC4_I_DATA_N								,
input 	wire		[7:0]			Z_ADC4_Q_DATA_P								,
input 	wire		[7:0]			Z_ADC4_Q_DATA_N                             ,
input 	wire		[7:0]			ADC1_I_DATA_P								,
input 	wire		[7:0]			ADC1_I_DATA_N								,
input 	wire		[7:0]			ADC1_Q_DATA_P								,
input 	wire		[7:0]			ADC1_Q_DATA_N                             	,
input 	wire		[7:0]			ADC2_I_DATA_P								,
input 	wire		[7:0]			ADC2_I_DATA_N								,
input 	wire		[7:0]			ADC2_Q_DATA_P								,
input 	wire		[7:0]			ADC2_Q_DATA_N                             	,
input 	wire		[7:0]			ADC3_I_DATA_P								,
input 	wire		[7:0]			ADC3_I_DATA_N								,
input 	wire		[7:0]			ADC3_Q_DATA_P								,
input 	wire		[7:0]			ADC3_Q_DATA_N                             	,
input 	wire		[7:0]			ADC4_I_DATA_P								,
input 	wire		[7:0]			ADC4_I_DATA_N								,
input 	wire		[7:0]			ADC4_Q_DATA_P								,
input 	wire		[7:0]			ADC4_Q_DATA_N            				    ,	

output	wire		[7:0][7:0]		data_i_p									,	
output	wire		[7:0][7:0]		data_i_n									,	
output	wire		[7:0][7:0]		data_q_p									,	
output	wire		[7:0][7:0]		data_q_n										

);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wires and regs
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
assign data_i_p[0]	=  Z_ADC1_I_DATA_P;
assign data_i_n[0]	=  Z_ADC1_I_DATA_N;
assign data_q_p[0]	=  Z_ADC1_Q_DATA_P;
assign data_q_n[0]	=  Z_ADC1_Q_DATA_N;

///////////////////////////////////////////////////////////////
assign data_i_p[1]	=  {
					   Z_ADC2_I_DATA_P[0],	
					   Z_ADC2_I_DATA_P[4],	
					   Z_ADC2_I_DATA_P[5],	
					   Z_ADC2_I_DATA_P[6],
					   Z_ADC2_I_DATA_P[2],
					   Z_ADC2_I_DATA_P[3],
					   Z_ADC2_I_DATA_P[1],
					   Z_ADC2_I_DATA_P[7]				   
					};
assign data_i_n[1]	=  {
					   Z_ADC2_I_DATA_N[0],	
					   Z_ADC2_I_DATA_N[4],	
					   Z_ADC2_I_DATA_N[5],	
					   Z_ADC2_I_DATA_N[6],
					   Z_ADC2_I_DATA_N[2],
					   Z_ADC2_I_DATA_N[3],
					   Z_ADC2_I_DATA_N[1],
					   Z_ADC2_I_DATA_N[7]	
					};
assign data_q_p[1]	=  {
						Z_ADC2_Q_DATA_P[7],
						Z_ADC2_Q_DATA_P[5],
						Z_ADC2_Q_DATA_P[6],
						Z_ADC2_Q_DATA_P[4],
						Z_ADC2_Q_DATA_P[3],
						Z_ADC2_Q_DATA_P[1],
						Z_ADC2_Q_DATA_P[2],
						Z_ADC2_Q_DATA_P[0]
					};
assign data_q_n[1]	=  {
						Z_ADC2_Q_DATA_N[7],
						Z_ADC2_Q_DATA_N[5],
						Z_ADC2_Q_DATA_N[6],
						Z_ADC2_Q_DATA_N[4],
						Z_ADC2_Q_DATA_N[3],
						Z_ADC2_Q_DATA_N[1],
						Z_ADC2_Q_DATA_N[2],
						Z_ADC2_Q_DATA_N[0]
					};
///////////////////////////////////////////////////////////////
assign data_i_p[2]	=  {
					   Z_ADC3_I_DATA_P[5],	
					   Z_ADC3_I_DATA_P[0],	
					   Z_ADC3_I_DATA_P[1],	
					   Z_ADC3_I_DATA_P[4],
					   Z_ADC3_I_DATA_P[7],
					   Z_ADC3_I_DATA_P[3],
					   Z_ADC3_I_DATA_P[2],
					   Z_ADC3_I_DATA_P[6]				   
					};
assign data_i_n[2]	=  {
					   Z_ADC3_I_DATA_N[5],				
					   Z_ADC3_I_DATA_N[0],	            
					   Z_ADC3_I_DATA_N[1],	            
					   Z_ADC3_I_DATA_N[4],              
					   Z_ADC3_I_DATA_N[7],              
					   Z_ADC3_I_DATA_N[3],              
					   Z_ADC3_I_DATA_N[2],              
					   Z_ADC3_I_DATA_N[6]	            
					};
assign data_q_p[2]	=  {
						Z_ADC3_Q_DATA_P[5],
						Z_ADC3_Q_DATA_P[4],
						Z_ADC3_Q_DATA_P[7],
						Z_ADC3_Q_DATA_P[6],
						Z_ADC3_Q_DATA_P[0],
						Z_ADC3_Q_DATA_P[1],
						Z_ADC3_Q_DATA_P[2],
						Z_ADC3_Q_DATA_P[3]
					};
assign data_q_n[2]	=  {
						Z_ADC3_Q_DATA_N[5],
						Z_ADC3_Q_DATA_N[4],
						Z_ADC3_Q_DATA_N[7],
						Z_ADC3_Q_DATA_N[6],
						Z_ADC3_Q_DATA_N[0],
						Z_ADC3_Q_DATA_N[1],
						Z_ADC3_Q_DATA_N[2],
						Z_ADC3_Q_DATA_N[3]
					};
///////////////////////////////////////////////////////////////
assign data_i_p[3]	=  {
					   Z_ADC4_I_DATA_P[5],	
					   Z_ADC4_I_DATA_P[4],	
					   Z_ADC4_I_DATA_P[7],	
					   Z_ADC4_I_DATA_P[6],
					   Z_ADC4_I_DATA_P[1],
					   Z_ADC4_I_DATA_P[3],
					   Z_ADC4_I_DATA_P[2],
					   Z_ADC4_I_DATA_P[0]				   
					};
assign data_i_n[3]	=  {
					   Z_ADC4_I_DATA_N[5],	
					   Z_ADC4_I_DATA_N[4],	
					   Z_ADC4_I_DATA_N[7],	
					   Z_ADC4_I_DATA_N[6],
					   Z_ADC4_I_DATA_N[1],
					   Z_ADC4_I_DATA_N[3],
					   Z_ADC4_I_DATA_N[2],
					   Z_ADC4_I_DATA_N[0]	
					};
assign data_q_p[3]	=  {
						Z_ADC4_Q_DATA_P[6],
						Z_ADC4_Q_DATA_P[1],
						Z_ADC4_Q_DATA_P[0],
						Z_ADC4_Q_DATA_P[3],
						Z_ADC4_Q_DATA_P[4],
						Z_ADC4_Q_DATA_P[2],
						Z_ADC4_Q_DATA_P[5],
						Z_ADC4_Q_DATA_P[7]
					};
assign data_q_n[3]	=  {
						Z_ADC4_Q_DATA_N[6],
						Z_ADC4_Q_DATA_N[1],
						Z_ADC4_Q_DATA_N[0],
						Z_ADC4_Q_DATA_N[3],
						Z_ADC4_Q_DATA_N[4],
						Z_ADC4_Q_DATA_N[2],
						Z_ADC4_Q_DATA_N[5],
						Z_ADC4_Q_DATA_N[7]
					};
///////////////////////////////////////////////////////////////
assign data_i_p[4]	=  ADC1_I_DATA_P;
assign data_i_n[4]	=  ADC1_I_DATA_N;
assign data_q_p[4]	=  ADC1_Q_DATA_P;
assign data_q_n[4]	=  ADC1_Q_DATA_N;

///////////////////////////////////////////////////////////////
assign data_i_p[5]	=  {
					   ADC2_I_DATA_P[0],	
					   ADC2_I_DATA_P[4],	
					   ADC2_I_DATA_P[5],	
					   ADC2_I_DATA_P[6],
					   ADC2_I_DATA_P[2],
					   ADC2_I_DATA_P[3],
					   ADC2_I_DATA_P[1],
					   ADC2_I_DATA_P[7]				   
					};
assign data_i_n[5]	=  {
					   ADC2_I_DATA_N[0],	
					   ADC2_I_DATA_N[4],	
					   ADC2_I_DATA_N[5],	
					   ADC2_I_DATA_N[6],
					   ADC2_I_DATA_N[2],
					   ADC2_I_DATA_N[3],
					   ADC2_I_DATA_N[1],
					   ADC2_I_DATA_N[7]	
					};
assign data_q_p[5]	=  {
						ADC2_Q_DATA_P[7],		
						ADC2_Q_DATA_P[5],       
						ADC2_Q_DATA_P[6],       
						ADC2_Q_DATA_P[4],       
						ADC2_Q_DATA_P[3],       
						ADC2_Q_DATA_P[1],       
						ADC2_Q_DATA_P[2],       
						ADC2_Q_DATA_P[0]        
					};
assign data_q_n[5]	=  {
						ADC2_Q_DATA_N[7],
						ADC2_Q_DATA_N[5],
						ADC2_Q_DATA_N[6],
						ADC2_Q_DATA_N[4],
						ADC2_Q_DATA_N[3],
						ADC2_Q_DATA_N[1],
						ADC2_Q_DATA_N[2],
						ADC2_Q_DATA_N[0]
					};
///////////////////////////////////////////////////////////////
assign data_i_p[6]	=  {
					   ADC3_I_DATA_P[5],			
					   ADC3_I_DATA_P[0],	        
					   ADC3_I_DATA_P[1],	        
					   ADC3_I_DATA_P[4],            
					   ADC3_I_DATA_P[7],            
					   ADC3_I_DATA_P[3],            
					   ADC3_I_DATA_P[2],            
					   ADC3_I_DATA_P[6]				 
					};
assign data_i_n[6]	=  {
					   ADC3_I_DATA_N[5],	
					   ADC3_I_DATA_N[0],	
					   ADC3_I_DATA_N[1],	
					   ADC3_I_DATA_N[4],
					   ADC3_I_DATA_N[7],
					   ADC3_I_DATA_N[3],
					   ADC3_I_DATA_N[2],
					   ADC3_I_DATA_N[6]	
					};
assign data_q_p[6]	=  {
						ADC3_Q_DATA_P[5],
						ADC3_Q_DATA_P[4],
						ADC3_Q_DATA_P[7],
						ADC3_Q_DATA_P[6],
						ADC3_Q_DATA_P[0],
						ADC3_Q_DATA_P[1],
						ADC3_Q_DATA_P[2],
						ADC3_Q_DATA_P[3]
					};
assign data_q_n[6]	=  {
						ADC3_Q_DATA_N[5],
						ADC3_Q_DATA_N[4],
						ADC3_Q_DATA_N[7],
						ADC3_Q_DATA_N[6],
						ADC3_Q_DATA_N[0],
						ADC3_Q_DATA_N[1],
						ADC3_Q_DATA_N[2],
						ADC3_Q_DATA_N[3]
					};
///////////////////////////////////////////////////////////////
assign data_i_p[7]	=  {
					   ADC4_I_DATA_P[5],	
					   ADC4_I_DATA_P[4],	
					   ADC4_I_DATA_P[7],	
					   ADC4_I_DATA_P[6],
					   ADC4_I_DATA_P[1],
					   ADC4_I_DATA_P[3],
					   ADC4_I_DATA_P[2],
					   ADC4_I_DATA_P[0]				   
					};
assign data_i_n[7]	=  {
					   ADC4_I_DATA_N[5],	
					   ADC4_I_DATA_N[4],	
					   ADC4_I_DATA_N[7],	
					   ADC4_I_DATA_N[6],
					   ADC4_I_DATA_N[1],
					   ADC4_I_DATA_N[3],
					   ADC4_I_DATA_N[2],
					   ADC4_I_DATA_N[0]	
					};
assign data_q_p[7]	=  {
						ADC4_Q_DATA_P[6],
						ADC4_Q_DATA_P[1],
						ADC4_Q_DATA_P[0],
						ADC4_Q_DATA_P[3],
						ADC4_Q_DATA_P[4],
						ADC4_Q_DATA_P[2],
						ADC4_Q_DATA_P[5],
						ADC4_Q_DATA_P[7]
					};
assign data_q_n[7]	=  {
						ADC4_Q_DATA_N[6],
						ADC4_Q_DATA_N[1],
						ADC4_Q_DATA_N[0],
						ADC4_Q_DATA_N[3],
						ADC4_Q_DATA_N[4],
						ADC4_Q_DATA_N[2],
						ADC4_Q_DATA_N[5],
						ADC4_Q_DATA_N[7]
					};
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
