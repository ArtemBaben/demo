`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// 
// Description  :	Select Calibration mode "Manual" or "Automat"
//
//
//
//
/////////////////////////////////////////////////////////////////////////////////
*/
/*
mux_manual_or_automat
mux_manual_or_automat_inst
(
// system_interface
.clk_i						(),
.dbg_clk_i					(),
.rst_i						(),
.dbg_control_pin			(),	
.control_pin				(),
// iodelay_group2mux_lines
.i_dl_cnt_val_o				(),
.i_dl_ce	        		(),
.i_dl_cnt_in	    		(),
.i_dl_in	        		(),
.i_dl_load_val				(),
.q_dl_cnt_val_o				(),
.q_dl_ce	        		(),
.q_dl_cnt_in	    		(),
.q_dl_in	        		(),
.q_dl_load_val				(),
// iodelay_group2debug
.dbg_i_dl_cnt_val_o			(),
.dbg_i_dl_ce	        	(),
.dbg_i_dl_cnt_in	    	(),
.dbg_i_dl_in	        	(),
.dbg_i_dl_load_val			(),
.dbg_q_dl_cnt_val_o			(),
.dbg_q_dl_ce	        	(),
.dbg_q_dl_cnt_in	    	(),
.dbg_q_dl_in	        	(),
.dbg_q_dl_load_val			(),
// iserdes_group2debug
.dbg_bitslip_i				(),		
.dbg_bitslip_q				(),	
// iserdes_group2mux_lines
.bitslip_i_o				(),		
.bitslip_q_o				(),
// mux2debug
.dbg_mux_lines				(),
// debug2mux
.mux_lines_o				()	
);				
*/
module mux_manual_or_automat
(
// system_interface
input	wire					 						clk_i						,
input	wire					 						dbg_clk_i					,
input	wire											rst_i						,
input	wire				 	 						dbg_control_pin				,	
output	wire				 	 						control_pin					,


// iodelay_group2mux_lines
input	wire		[4:0] 								i_dl_cnt_val_o				,
output  wire 											i_dl_ce	        			,
output	wire		[4:0]								i_dl_cnt_in	    			,
output	wire 											i_dl_in	        			,
output	wire											i_dl_load_val				,
				
input	wire		[4:0] 								q_dl_cnt_val_o				,
output  wire 											q_dl_ce	        			,
output	wire		[4:0]								q_dl_cnt_in	    			,
output	wire 											q_dl_in	        			,
output	wire											q_dl_load_val				,

// iodelay_group2debug
output	wire		[4:0] 								dbg_i_dl_cnt_val_o			,
input   wire 											dbg_i_dl_ce	        		,
input	wire		[4:0]								dbg_i_dl_cnt_in	    		,
input	wire 											dbg_i_dl_in	        		,
input	wire											dbg_i_dl_load_val			,
				
output	wire		[4:0] 								dbg_q_dl_cnt_val_o			,
input   wire 											dbg_q_dl_ce	        		,
input	wire		[4:0]								dbg_q_dl_cnt_in	    		,
input	wire 											dbg_q_dl_in	        		,
input	wire											dbg_q_dl_load_val			,


// iserdes_group2debug
input 	wire											dbg_bitslip_i				,		
input 	wire											dbg_bitslip_q				,	
// iserdes_group2mux_lines
output 	wire											bitslip_i_o					,		
output 	wire											bitslip_q_o					,

// mux2debug
input 	wire		[7:0]								dbg_mux_lines				,
// debug2mux
output 	wire		[7:0]								mux_lines_o					

);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wires and regs
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire													i_dl_ce_xpm			; 
wire													i_dl_load_val_xpm	; 
wire													q_dl_ce_xpm			; 
wire													q_dl_load_val_xpm	;   		
wire													bitslip_i_xpm		; 
wire													bitslip_q_xpm		; 


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Main body
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// iodelay_group2mux_lines
xpm_cdc_array_single #(
	
	//Common module parameters
	.DEST_SYNC_FF   		(4										), 
	.SIM_ASSERT_CHK 		(0										), 
	.SRC_INPUT_REG  		(1										), 
	.WIDTH          		(16										)  
	                                                                   
	) xpm_cdc_array_single_inst_iodelay2muxlines(                      
	                                                                   
	.src_clk  				(dbg_clk_i								), 
	.src_in   				({
								dbg_i_dl_ce	    	,			    		
								dbg_i_dl_cnt_in	    ,			
								dbg_i_dl_in	        ,			   
								dbg_i_dl_load_val	,
								dbg_q_dl_ce	    	,			    		
								dbg_q_dl_cnt_in	    ,			
								dbg_q_dl_in	        ,			   
								dbg_q_dl_load_val										
							}),						
	.dest_clk 				(clk_i									), 
	.dest_out 				({
								i_dl_ce_xpm   		,			    		
								i_dl_cnt_in	    	,			
								i_dl_in	        	,			   
								i_dl_load_val_xpm	,
								q_dl_ce_xpm    		,			    		
								q_dl_cnt_in	    	,			
								q_dl_in	        	,			   
								q_dl_load_val_xpm			
							})
	);
	
xpm_cdc_array_single #(
	
	//Common module parameters
	.DEST_SYNC_FF   		(4										), 
	.SIM_ASSERT_CHK 		(0										), 
	.SRC_INPUT_REG  		(1										), 
	.WIDTH          		(11										)  
	                                                                   
	) xpm_cdc_array_single_inst_iserdes2muxlines(                      
	                                                                   
	.src_clk  				(dbg_clk_i								), 
	.src_in   				({
								dbg_mux_lines		,
								dbg_bitslip_i		,
								dbg_bitslip_q		,
								dbg_control_pin	
							}),						
	.dest_clk 				(clk_i									), 
	.dest_out 				({
								mux_lines_o			,
								bitslip_i_xpm		,
								bitslip_q_xpm		,
								control_pin												    		
							})
	);

// detect_edge_bitslip____load_val_____dl_ce
detect_edge
	detect_edge_bitslip_i
    (
		.clk					(clk_i								),
		.reset					(rst_i								),
		.sig					(bitslip_i_xpm						),
		.rise					(bitslip_i_o						),
		.fall					(									)
    );

detect_edge
	detect_edge_bitslip_q
    (
		.clk					(clk_i								),
		.reset					(rst_i								),
		.sig					(bitslip_q_xpm						),
		.rise					(bitslip_q_o						),
		.fall					(									)
    );

			
detect_edge
	detect_edge_i_dl_ce_xpm
    (
		.clk					(clk_i								),
		.reset					(rst_i								),
		.sig					(i_dl_ce_xpm						),
		.rise					(i_dl_ce							),
		.fall					(									)
    );

detect_edge
	detect_edge_q_dl_ce_xpm
    (
		.clk					(clk_i								),
		.reset					(rst_i								),
		.sig					(q_dl_ce_xpm						),
		.rise					(q_dl_ce							),
		.fall					(									)
    );			
			
detect_edge
	detect_edge_i_dl_load_val_xpm
    (
		.clk					(clk_i								),
		.reset					(rst_i								),
		.sig					(i_dl_load_val_xpm					),
		.rise					(i_dl_load_val						),
		.fall					(									)
    );

detect_edge
	detect_edge_q_dl_load_val_xpm
    (
		.clk					(clk_i								),
		.reset					(rst_i								),
		.sig					(q_dl_load_val_xpm					),
		.rise					(q_dl_load_val						),
		.fall					(									)
    );					


xpm_cdc_array_single #(
	
	//Common module parameters
	.DEST_SYNC_FF   		(4										), 
	.SIM_ASSERT_CHK 		(0										), 
	.SRC_INPUT_REG  		(1										), 
	.WIDTH          		(10										)  
	                                                                   
	) xpm_cdc_array_single_inst_dl_cnt_val_o2dbg(                      
	                                                                   
	.src_clk  				(clk_i									), 
	.src_in   				({
							i_dl_cnt_val_o,
							q_dl_cnt_val_o
							}),						
	.dest_clk 				(dbg_clk_i								), 
	.dest_out 				({
							dbg_i_dl_cnt_val_o,
							dbg_q_dl_cnt_val_o
							})
	);


endmodule

`default_nettype wire
