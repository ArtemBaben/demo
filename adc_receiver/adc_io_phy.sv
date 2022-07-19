`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// 
// Device 		:   bpac_059		
//
// Description  :	Module ADC IO Calibration and physical IO
//
// History		: 	v2 - iserdes calibration + idelay calibration + mux lines 1 adc
//					
/////////////////////////////////////////////////////////////////////////////////
*/
/*
adc_io_phy
#(
	.PORTS									(8),
	.DATA_WIDTH_ADC							(8),
	.USE_CHIPSCOPE							(0)			    	
) 
adc_io_phy_inst
	(
	// system_interface
	.CLK_BUFR_I								(),
	.CLK_ADC_I								(),
	.CLK_BUFR_Q								(),
	.CLK_ADC_Q								(),
	.SYS_WR_EN_ADC							(),
	.SYS_CLK								(),
	.SYS_RST								(),
	.SYS_RST_ILOGIC							(),
	.ISERDES_RESYNC							(),
	// data_in 
	.DATA_I_P								(),
	.DATA_I_N								(),
	.DATA_Q_P								(),
	.DATA_Q_N								(),
	// data_out
	.DATA_O_I								(),		//i7i6i5i4i3i2i1i0
	.DATA_O_Q								(),		//q7q6q5q4q3q2q1q0
	// dbg_manual_calibration iodelay/bitslip
	.dbg_clk_i								(),
	.dbg_control_pin						(),
	.dbg_bitslip_i							(),
	.dbg_bitslip_q							(),
	.dbg_mux_lines							(),
	.dbg_i_dl_cnt_val_o						(),
	.dbg_i_dl_ce							(),
	.dbg_i_dl_cnt_in						(),
	.dbg_i_dl_in							(),
	.dbg_i_dl_load_val						(),
	.dbg_q_dl_cnt_val_o						(),
	.dbg_q_dl_ce							(),
	.dbg_q_dl_cnt_in						(),
	.dbg_q_dl_in							(),
	.dbg_q_dl_load_val						()
);

*/
 
module adc_io_phy
#(
parameter 			PORTS								= 8				,
parameter 			DATA_WIDTH_ADC						= 12			,
parameter			TIME_LENGTH_IDELAY_CALIB			= 8096			,
parameter			USE_CHIPSCOPE						= 0							    	
) 
(
// system_interface
input	wire					 						CLK_BUFR_I		,
input	wire					  						CLK_ADC_I		,
input	wire					 						CLK_BUFR_Q		,
input	wire					  						CLK_ADC_Q		,
input	wire											SYS_CLK			,
input	wire											SYS_WR_EN_ADC	,	
input	wire											SYS_RST			,
input   wire											SYS_RST_ILOGIC	,
input	wire					  						ISERDES_RESYNC	,
output  wire											ADC_CALIB_COMPLETE,
// data_in 
input	wire		[(DATA_WIDTH_ADC-1):0]				DATA_I_P		,
input	wire      	[(DATA_WIDTH_ADC-1):0]				DATA_I_N		,
input	wire		[(DATA_WIDTH_ADC-1):0]				DATA_Q_P		,
input	wire      	[(DATA_WIDTH_ADC-1):0]				DATA_Q_N		,
// data_out
output	wire		[(8*DATA_WIDTH_ADC-1):0]			DATA_O_I		,		//i7i6i5i4i3i2i1i0
output	wire		[(8*DATA_WIDTH_ADC-1):0]			DATA_O_Q		,		//q7q6q5q4q3q2q1q0

// dbg_manual_calibration iodelay/bitslip
input	wire											dbg_chipscope_clk		,	
input	wire      										dbg_clk_i				,
input	wire      										dbg_control_pin			,
input	wire 											dbg_bitslip_i			,
input	wire 											dbg_bitslip_q			,
input	wire     	[7:0]								dbg_mux_lines			,


output	wire     	[4:0]								dbg_i_dl_cnt_val_o		,
input	wire 											dbg_i_dl_ce				,
input	wire     	[4:0]								dbg_i_dl_cnt_in			,
input	wire 											dbg_i_dl_in				,
input	wire 											dbg_i_dl_load_val		,

output	wire      	[4:0]								dbg_q_dl_cnt_val_o		,
input	wire 											dbg_q_dl_ce				,
input	wire     	[4:0]								dbg_q_dl_cnt_in			,
input	wire 											dbg_q_dl_in				,
input	wire 											dbg_q_dl_load_val		,

input	wire		[15:0]								bram_addr_adc_calib		,
output	wire 		[47:0]								bram_data_adc_calib		

);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wires and regs
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire 																	en_calib_idelay							;

wire [(DATA_WIDTH_ADC-1):0][(PORTS-1):0]								s_data_serdes_i_cal						;
wire [(DATA_WIDTH_ADC-1):0][(PORTS-1):0]								s_data_serdes_q_cal						;	

wire [(8*DATA_WIDTH_ADC-1):0]											data_i									;	
wire [(8*DATA_WIDTH_ADC-1):0]											data_q									;		

wire [4:0] 																i_dl_cnt_val_o							;	
wire [4:0] 																q_dl_cnt_val_o							;

// sw_	
wire 																	s_bitslip_i_sw							;
wire 																	s_bitslip_q_sw							;			
wire 																	q_dl_ce_sw        						;
wire [4:0]																q_dl_cnt_in_sw    						;
wire 																	q_dl_in_sw        						;
wire                              										q_dl_load_val_sw						;
wire 																	i_dl_ce_sw        						;
wire [4:0]																i_dl_cnt_in_sw    						;
wire 																	i_dl_in_sw        						;
wire                              										i_dl_load_val_sw						;			
wire [7:0]																mux_number_line_calib_sw				;

// Manual calibration	
wire 																	s_bitslip_i_man							;
wire 																	s_bitslip_q_man							;			
wire 																	q_dl_ce_man        						;
wire [4:0]																q_dl_cnt_in_man    						;
wire 																	q_dl_in_man        						;
wire                              										q_dl_load_val_man						;
wire 																	i_dl_ce_man        						;
wire [4:0]																i_dl_cnt_in_man    						;
wire 																	i_dl_in_man        						;
wire                              										i_dl_load_val_man						;			
wire [7:0]																mux_number_line_calib_man				;

// Auto calibration	
wire 																	s_bitslip_i_aut							;
wire 																	s_bitslip_q_aut							;			
wire 																	q_dl_ce_aut        						;
wire [4:0]																q_dl_cnt_in_aut    						;
wire 																	q_dl_in_aut        						;
wire                              										q_dl_load_val_aut						;
wire 																	i_dl_ce_aut        						;
wire [4:0]																i_dl_cnt_in_aut    						;
wire 																	i_dl_in_aut        						;
wire                              										i_dl_load_val_aut						;			
wire [7:0]																mux_number_line_calib_aut				;

wire [(PORTS-1):0]														mux_s_data_serdes_i_cal					;
wire [(PORTS-1):0]														mux_s_data_serdes_q_cal					;
wire [(DATA_WIDTH_ADC-1):0]												mux_s_bitslip_i							;
wire [(DATA_WIDTH_ADC-1):0]												mux_s_bitslip_q	                        ;
				
wire [(DATA_WIDTH_ADC-1):0]												mux_q_dl_ce	        					;
wire [(DATA_WIDTH_ADC-1):0][4:0]										mux_q_dl_cnt_in	    					;
wire [(DATA_WIDTH_ADC-1):0]												mux_q_dl_in	        					;
wire [(DATA_WIDTH_ADC-1):0]												mux_q_dl_load_val						;	
wire [(DATA_WIDTH_ADC-1):0][4:0]										mux_q_dl_cnt_val_o   					;

				
wire [(DATA_WIDTH_ADC-1):0]												mux_i_dl_ce	        					;
wire [(DATA_WIDTH_ADC-1):0][4:0]										mux_i_dl_cnt_in	    	                ;
wire [(DATA_WIDTH_ADC-1):0]												mux_i_dl_in	        	                ;
wire [(DATA_WIDTH_ADC-1):0]												mux_i_dl_load_val			            ;
wire [(DATA_WIDTH_ADC-1):0][4:0]										mux_i_dl_cnt_val_o   					;

wire 																	s_use_q_inv								;								
wire 																	s_use_i_inv								;

wire 																	calibration_done_i						;
wire 																	calibration_not_done_i					;
wire 																	calibration_done_q						;
wire 																	calibration_not_done_q					;

wire [(PORTS-1):0][(DATA_WIDTH_ADC-1):0]								s_data_q								;
wire [(PORTS-1):0][(DATA_WIDTH_ADC-1):0]								s_data_i								;	

wire																	s_control_pin							;

wire																	s_value_dav								;
wire [31:0][23:0]														s_value_counter_good_i					;				
wire [31:0][23:0]														s_value_counter_good_q					;	



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Code Twos_complement creator
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* ADC12D500RF Two's complement code default
bo2tc
	#(
		.PORTS									(	PORTS)				
	)
	bo2tc_i_inst
	(
		.DATA_IN								(s_data_i),
		.DATA_OUT	                            (DATA_O_I)
	);

bo2tc
	#(
		.PORTS									(	PORTS)				
	)
	bo2tc_q_inst
	(
		.DATA_IN								(s_data_q),
		.DATA_OUT	                            (DATA_O_Q)
	);
*/

assign DATA_O_I = s_data_i	;
assign DATA_O_Q	= s_data_q	;
	
////////////////////////////////////////////////////////////////////////////
// data_input modules
////////////////////////////////////////////////////////////////////////////	
	data_adc
	#(
		.PORTS			        				(DATA_WIDTH_ADC					),
		.ISERDES_BITS							(8								)
	) 
	data_adc_inst
	(
	    .RST_I          						(SYS_RST_ILOGIC		     	    ),
		.DATA_I_P								(DATA_I_P						),
		.DATA_I_N								(DATA_I_N						),
		.DATA_Q_P								(DATA_Q_P						),
		.DATA_Q_N								(DATA_Q_N						),
		.CLK_BUFR_I								(CLK_BUFR_I						),
		.CLK_ADC_I								(CLK_ADC_I						),
		.CLK_BUFR_Q								(CLK_BUFR_Q						),
		.CLK_ADC_Q								(CLK_ADC_Q						),
		.DATA_O_I								(s_data_i						), 
		.DATA_O_Q								(s_data_q						),
		.DATA_SERDES_I_CAL      				(s_data_serdes_i_cal			),
		.DATA_SERDES_Q_CAL						(s_data_serdes_q_cal			),
		.BITSIP_I								(mux_s_bitslip_i				),		
		.BITSIP_Q								(mux_s_bitslip_q				),
		.ISERDES_RESYNC							(ISERDES_RESYNC					),	
		.IDELAY_CLK								(SYS_CLK						),
		.SYS_CLK								(SYS_CLK						),
		.SYS_WR_EN_ADC							(SYS_WR_EN_ADC					),
		.q_dl_cnt_val_o							(mux_q_dl_cnt_val_o				),					
		.q_dl_ce	    						(mux_q_dl_ce	        		),   					
		.q_dl_cnt_in							(mux_q_dl_cnt_in	    		),   					
		.q_dl_in	    						(mux_q_dl_in	        		),   					
		.q_dl_load_val							(mux_q_dl_load_val				),					
		.i_dl_cnt_val_o							(mux_i_dl_cnt_val_o				),					
		.i_dl_ce	    						(mux_i_dl_ce	        		),   					
		.i_dl_cnt_in							(mux_i_dl_cnt_in	    		),   					
		.i_dl_in	    						(mux_i_dl_in	        		),   					
		.i_dl_load_val							(mux_i_dl_load_val				),
		
		.dbg_chipscope_clk                      (dbg_chipscope_clk              )  
	);


/////////////////////////////////////////////////////////////
// create idelay calibration module 
/////////////////////////////////////////////////////////////
idelay_calibration_adc
#(
	.TIME_LENGTH 								(TIME_LENGTH_IDELAY_CALIB		),
	.ENABLE_IDELAY_CALIB						(1								),
	.USE_DEBUG									(0								)																						
)
the_idelay_adc_calibration_inst
(
	// system_interface
	.clk_i										(SYS_CLK						),
	.rst_i										(SYS_RST | SYS_RST_ILOGIC		
												|s_control_pin					),
	.en_calib_idelay							(en_calib_idelay				),	
	.calibration_done_i							(calibration_done_i				),
	.calibration_not_done_i						(calibration_not_done_i			),
	.calibration_done_q							(calibration_done_q				),
	.calibration_not_done_q						(calibration_not_done_q			),
	.USE_INV_Q 									(s_use_q_inv 					),
	.USE_INV_I 									(s_use_i_inv 					),
	// iodelay_group	
	.i_dl_cnt_val_o								(           					),	//	[4:0] 			ic_i_dl_cnt_val_o		
	.i_dl_ce	        						(i_dl_ce_aut    				),	//  				ic_i_dl_ce	        
	.i_dl_cnt_in	    						(i_dl_cnt_in_aut				),	//  [4:0]			ic_i_dl_cnt_in	    
	.i_dl_in	        						(i_dl_in_aut    				),	//  				ic_i_dl_in	        
	.i_dl_load_val								(i_dl_load_val_aut				),	//					ic_i_dl_load_val			
	.q_dl_cnt_val_o								(           					),	//	[4:0] 			ic_q_dl_cnt_val_o	
	.q_dl_ce	        						(q_dl_ce_aut    				),	//					ic_q_dl_ce	        
	.q_dl_cnt_in	    						(q_dl_cnt_in_aut				),	//	[4:0]			ic_q_dl_cnt_in	    
	.q_dl_in	        						(q_dl_in_aut    				),	//					ic_q_dl_in	        
	.q_dl_load_val								(q_dl_load_val_aut				),	//					ic_q_dl_load_val	
	// data 					
	.data_serdes_i								(mux_s_data_serdes_i_cal		),
	.data_serdes_q	   							(mux_s_data_serdes_q_cal		),
	
	.o_idelay_value_counter_good_i				(s_value_counter_good_i			),
	.o_idelay_value_counter_good_q				(s_value_counter_good_q			),		
	.o_idelay_value_dav					        (s_value_dav					)
);	

/////////////////////////////////////////////////////////////
// Table calibration 
/////////////////////////////////////////////////////////////
bram_adc_idelay_values 
bram_adc_idelay_values_inst
(
	.clka 										(SYS_CLK						),//: IN STD_LOGIC;
	.wea 										(s_value_dav					),//: IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	.addra 										(mux_number_line_calib_sw[3:0]	),//: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	.dina 										({	s_value_counter_good_i,
													s_value_counter_good_q	}	),//: IN STD_LOGIC_VECTOR(1535 DOWNTO 0);
	.clkb 										(SYS_CLK						),//: IN STD_LOGIC;
	.addrb 										(bram_addr_adc_calib[8:0]		),//: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	.doutb 										(bram_data_adc_calib			) //: OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
);




/////////////////////////////////////////////////////////////
// create iserdes calibration module 
/////////////////////////////////////////////////////////////
iserdes_calibration_adc
#
(
.DATA_WIDTH_ADC									(DATA_WIDTH_ADC					)
)
the_iserdes_adc_calibration_inst
(
	// system_interface
	.clk_i										(SYS_CLK						),
	.rst_i										(SYS_RST | SYS_RST_ILOGIC 
												|s_control_pin					),
	.en_calib_idelay_o							(en_calib_idelay				),	
	.calibration_done_i_i						(calibration_done_i				),
	.calibration_not_done_i_i					(calibration_not_done_i			),
	.calibration_done_q_i						(calibration_done_q				),
	.calibration_not_done_q_i					(calibration_not_done_q			),
	.use_inv_q_o 								(s_use_q_inv 					),
	.use_inv_i_o 								(s_use_i_inv 					),
	// iserdes_cmd	
	.bitslip_i_o								(s_bitslip_i_aut				),
	.bitslip_q_o								(s_bitslip_q_aut				),
	.adc_calib_complete							(ADC_CALIB_COMPLETE				),
	.number_line_calib							(mux_number_line_calib_aut		)
	
);


/////////////////////////////////////////////////////////////
// create MUX_ADC_LINES module 
/////////////////////////////////////////////////////////////
mux_lines_calib_adc
	#(
		.PORTS 		(DATA_WIDTH_ADC)				
	)
mux_lines_calib_adc_inst
	(
	// system_interface
	.clk_i										(SYS_CLK						),
	.rst_i										(SYS_RST | SYS_RST_ILOGIC		),
	.mux_cntrl									(mux_number_line_calib_sw		),	
		
	// serdes_data ports group in	
	.data_serdes_i_i							(s_data_serdes_i_cal			),
	.data_serdes_q_i							(s_data_serdes_q_cal			),
	// serdes_data ports group out	
	.data_serdes_i_o							(mux_s_data_serdes_i_cal	 	),
	.data_serdes_q_o							(mux_s_data_serdes_q_cal	 	),
	
	// idelay ports group in
	.i_i_dl_ce	    							(i_dl_ce_sw	    				),						
	.i_i_dl_cnt_in								(i_dl_cnt_in_sw					),                          
	.i_i_dl_in	    							(i_dl_in_sw	    				),                          
	.i_i_dl_load_val							(i_dl_load_val_sw				),   
	.o_i_dl_cnt_val_o							(i_dl_cnt_val_o					),
	.i_q_dl_ce	    							(q_dl_ce_sw	    				),                          
	.i_q_dl_cnt_in								(q_dl_cnt_in_sw					),                         
	.i_q_dl_in	    							(q_dl_in_sw	    				),                          
	.i_q_dl_load_val							(q_dl_load_val_sw				), 
	.o_q_dl_cnt_val_o							(q_dl_cnt_val_o					),	
	// iodelay_group out                                                                                    
	.o_i_dl_ce	    							(mux_i_dl_ce	    			),                          
	.o_i_dl_cnt_in								(mux_i_dl_cnt_in				),
	.o_i_dl_in	    							(mux_i_dl_in	    			),
	.o_i_dl_load_val							(mux_i_dl_load_val				),
	.i_i_dl_cnt_val_o							(mux_i_dl_cnt_val_o				),
	.o_q_dl_ce	    							(mux_q_dl_ce	    			),
	.o_q_dl_cnt_in								(mux_q_dl_cnt_in				),
	.o_q_dl_in	    							(mux_q_dl_in	    			),
	.o_q_dl_load_val							(mux_q_dl_load_val				),
	.i_q_dl_cnt_val_o							(mux_q_dl_cnt_val_o				),	
	.bitslip_i_i								(s_bitslip_i_sw					),		
	.bitslip_q_i								(s_bitslip_q_sw					),	
	.bitslip_i_o								(mux_s_bitslip_i				),		
	.bitslip_q_o								(mux_s_bitslip_q				)
	
	);
	
	
/////////////////////////////////////////////////////////////
// create SWITCH MODE "Automat" or "Manual" calibration mode
/////////////////////////////////////////////////////////////
mux_manual_or_automat
mux_manual_or_automat_inst
	(
	// system_interface
	.clk_i										(SYS_CLK						),
	.dbg_clk_i									(dbg_clk_i						),
	.rst_i										(SYS_RST						),
	.dbg_control_pin							(dbg_control_pin				),	
	.control_pin								(s_control_pin					),
	// iodelay_group2mux_lines
	.i_dl_cnt_val_o								(i_dl_cnt_val_o					),
	.i_dl_ce	        						(i_dl_ce_man	    			),
	.i_dl_cnt_in	    						(i_dl_cnt_in_man				),
	.i_dl_in	        						(i_dl_in_man	    			),
	.i_dl_load_val								(i_dl_load_val_man				),
	.q_dl_cnt_val_o								(q_dl_cnt_val_o					),
	.q_dl_ce	        						(q_dl_ce_man	    			),
	.q_dl_cnt_in	    						(q_dl_cnt_in_man				),
	.q_dl_in	        						(q_dl_in_man	    			),
	.q_dl_load_val								(q_dl_load_val_man				),
	// iodelay_group2debug
	.dbg_i_dl_cnt_val_o							(dbg_i_dl_cnt_val_o				),
	.dbg_i_dl_ce	        					(dbg_i_dl_ce					),
	.dbg_i_dl_cnt_in	    					(dbg_i_dl_cnt_in				),
	.dbg_i_dl_in	        					(dbg_i_dl_in					),
	.dbg_i_dl_load_val							(dbg_i_dl_load_val				),
	.dbg_q_dl_cnt_val_o							(dbg_q_dl_cnt_val_o				),
	.dbg_q_dl_ce	        					(dbg_q_dl_ce					),
	.dbg_q_dl_cnt_in	    					(dbg_q_dl_cnt_in				),
	.dbg_q_dl_in	        					(dbg_q_dl_in					),
	.dbg_q_dl_load_val							(dbg_q_dl_load_val				),
	// iserdes_group2debug
	.dbg_bitslip_i								(dbg_bitslip_i					),		
	.dbg_bitslip_q								(dbg_bitslip_q					),	
	// iserdes_group2mux_lines
	.bitslip_i_o								(s_bitslip_i_man				),		
	.bitslip_q_o								(s_bitslip_q_man				),
	// mux2debug
	.dbg_mux_lines								(dbg_mux_lines					),
	// debug2mux
	.mux_lines_o								(mux_number_line_calib_man		)	
);	



assign   mux_number_line_calib_sw = (s_control_pin) ? mux_number_line_calib_man : mux_number_line_calib_aut	;

assign   i_dl_ce_sw				  = (s_control_pin) ? i_dl_ce_man			 	: i_dl_ce_aut				;
assign   i_dl_cnt_in_sw			  = (s_control_pin) ? i_dl_cnt_in_man		 	: i_dl_cnt_in_aut			;
assign   i_dl_in_sw				  = (s_control_pin) ? i_dl_in_man			 	: i_dl_in_aut				;
assign   i_dl_load_val_sw		  = (s_control_pin) ? i_dl_load_val_man	 	 	: i_dl_load_val_aut			;

assign   q_dl_ce_sw				  = (s_control_pin) ? q_dl_ce_man			 	: q_dl_ce_aut				;
assign   q_dl_cnt_in_sw			  = (s_control_pin) ? q_dl_cnt_in_man		 	: q_dl_cnt_in_aut			;
assign   q_dl_in_sw				  = (s_control_pin) ? q_dl_in_man			 	: q_dl_in_aut				;
assign   q_dl_load_val_sw		  = (s_control_pin) ? q_dl_load_val_man	 	 	: q_dl_load_val_aut			;			

assign   s_bitslip_i_sw			  = (s_control_pin) ? s_bitslip_i_man			: s_bitslip_i_aut			;	
assign   s_bitslip_q_sw			  = (s_control_pin) ? s_bitslip_q_man			: s_bitslip_q_aut			;	

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
