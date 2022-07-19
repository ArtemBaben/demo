`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// Device 		:   bpac_059
// Description  :	Module ADC_IO_MULT
//
/////////////////////////////////////////////////////////////////////////////////
*/
/*
adc_phy_mult
#(
	PORTS																	(8),
	DATA_WIDTH_ADC															(8),
	PORTS_ADC																(4),
	QUANTITY_FMC															(2),
	USE_CHIPSCOPE															(0)		
)
adc_phy_mult_inst
(	
	// system_interface
	.CLK_BUFR_I																()	,
	.CLK_ADC_I																()	,
	.CLK_BUFR_Q																()	,
	.CLK_ADC_Q																()	,
	.SYS_CLK																()	,
	.SYS_RST																()	,
	.SYS_WR_EN_ADC															()	,
	.SYS_RST_ILOGIC															()	,
	.ISERDES_RESYNC															()	,
	// data_in 
	.DATA_I_P																()	,
	.DATA_I_N																()	,
	.DATA_Q_P																()	,
	.DATA_Q_N																()	,
	// data_out
	.DATA_O_I																()	,			//i7i6i5i4i3i2i1i0
	.DATA_O_Q																()	,			//q7q6q5q4q3q2q1q0
	// dbg_manual_calibration iodelay/bitslip
	.dbg_clk_i																()	,
	.dbg_control_pin														()	,
	.dbg_bitslip_i															()	,
	.dbg_bitslip_q															()	,
	.dbg_mux_lines															()	,
	.dbg_i_dl_cnt_val_o														()	,
	.dbg_i_dl_ce															()	,
	.dbg_i_dl_cnt_in														()	,
	.dbg_i_dl_in															()	,
	.dbg_i_dl_load_val														()	,
	.dbg_q_dl_cnt_val_o														()	,
	.dbg_q_dl_ce															()	,
	.dbg_q_dl_cnt_in														()	,
	.dbg_q_dl_in															()	,
	.dbg_q_dl_load_val														()	
);

*/
 
module adc_phy_mult
#(
	parameter	PORTS																	= 12,
	parameter	DATA_WIDTH_ADC															= 12,
	parameter	PORTS_ADC																= 2,
	parameter	QUANTITY_FMC															= 4,
	parameter	TIME_LENGTH_IDELAY_CALIB												= 8096,
	parameter	USE_CHIPSCOPE															= 0		
)
(	
	// system_interface
	input	wire	[(PORTS_ADC*QUANTITY_FMC-1):0]										CLK_BUFR_I				,
	input	wire	[(PORTS_ADC*QUANTITY_FMC-1):0]										CLK_ADC_I				,
	input	wire	[(PORTS_ADC*QUANTITY_FMC-1):0]										CLK_BUFR_Q				,
	input	wire	[(PORTS_ADC*QUANTITY_FMC-1):0]										CLK_ADC_Q				,
	input	wire																		SYS_CLK					,
	input	wire																		SYS_WR_EN_ADC			,	
	input	wire																		SYS_RST					,
	input   wire																		SYS_RST_ILOGIC			,
	input	wire																		ISERDES_RESYNC			,
	output	wire	[(PORTS_ADC*QUANTITY_FMC-1):0]										ADC_CLB_COMPL			,
	// data_in 
	input	wire	[(PORTS_ADC*QUANTITY_FMC-1):0]	[(DATA_WIDTH_ADC-1):0]				DATA_I_P				,
	input	wire    [(PORTS_ADC*QUANTITY_FMC-1):0]  [(DATA_WIDTH_ADC-1):0]				DATA_I_N				,
	input	wire	[(PORTS_ADC*QUANTITY_FMC-1):0]	[(DATA_WIDTH_ADC-1):0]				DATA_Q_P				,
	input	wire    [(PORTS_ADC*QUANTITY_FMC-1):0]  [(DATA_WIDTH_ADC-1):0]				DATA_Q_N				,
	// data_out
	output	wire	[(PORTS_ADC*QUANTITY_FMC-1):0]	[(8*DATA_WIDTH_ADC-1):0]			DATA_O_I				,		//i7i6i5i4i3i2i1i0
	output	wire	[(PORTS_ADC*QUANTITY_FMC-1):0]	[(8*DATA_WIDTH_ADC-1):0]			DATA_O_Q				,		//q7q6q5q4q3q2q1q0
	// dbg_manual_calibration iodelay/bitslip
    input	wire																		dbg_chipscope_clk		,	
	input	wire      																	dbg_clk_i			 	,
	input	wire      																	dbg_control_pin		 	,
	input	wire 																		dbg_bitslip_i		 	,
	input	wire 																		dbg_bitslip_q		 	,
	input	wire     	[(8-1):0]														dbg_mux_lines		 	,
	output	wire     	[4:0]															dbg_i_dl_cnt_val_o	 	,
	input	wire 																		dbg_i_dl_ce			 	,
	input	wire     	[4:0]															dbg_i_dl_cnt_in		 	,
	input	wire 																		dbg_i_dl_in			 	,
	input	wire 																		dbg_i_dl_load_val	 	,
	output	wire      	[4:0]															dbg_q_dl_cnt_val_o	 	,
	input	wire 																		dbg_q_dl_ce			 	,
	input	wire     	[4:0]															dbg_q_dl_cnt_in		 	,
	input	wire 																		dbg_q_dl_in			 	,
	input	wire 																		dbg_q_dl_load_val	    ,
	input	wire		[(QUANTITY_FMC*PORTS_ADC-1):0]									dbg_switch_adc		    ,	
	
	input	wire		[7:0][15:0]							                            bram_addr_adc_calib		,
    output	wire 		[7:0][47:0]							                            bram_data_adc_calib     						

);              

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wires and regs
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
genvar										i					;

// dbg_manual_calibration iodelay/bitslip
wire    [(PORTS_ADC*QUANTITY_FMC-1):0]  												mux_adc_dbg_control_pin			;
wire 	[(PORTS_ADC*QUANTITY_FMC-1):0]													mux_adc_dbg_bitslip_i			;
wire 	[(PORTS_ADC*QUANTITY_FMC-1):0]													mux_adc_dbg_bitslip_q			;
wire    [(PORTS_ADC*QUANTITY_FMC-1):0] 	[7:0]											mux_adc_dbg_mux_lines			;
wire    [(PORTS_ADC*QUANTITY_FMC-1):0] 	[4:0]											mux_adc_dbg_i_dl_cnt_val_o		;
wire 	[(PORTS_ADC*QUANTITY_FMC-1):0]													mux_adc_dbg_i_dl_ce				;
wire    [(PORTS_ADC*QUANTITY_FMC-1):0] 	[4:0]											mux_adc_dbg_i_dl_cnt_in			;
wire 	[(PORTS_ADC*QUANTITY_FMC-1):0]													mux_adc_dbg_i_dl_in				;
wire 	[(PORTS_ADC*QUANTITY_FMC-1):0]													mux_adc_dbg_i_dl_load_val		;
wire    [(PORTS_ADC*QUANTITY_FMC-1):0]  [4:0]											mux_adc_dbg_q_dl_cnt_val_o		;
wire 	[(PORTS_ADC*QUANTITY_FMC-1):0]													mux_adc_dbg_q_dl_ce				;
wire    [(PORTS_ADC*QUANTITY_FMC-1):0] 	[4:0]											mux_adc_dbg_q_dl_cnt_in			;
wire 	[(PORTS_ADC*QUANTITY_FMC-1):0]													mux_adc_dbg_q_dl_in				;
wire 	[(PORTS_ADC*QUANTITY_FMC-1):0]													mux_adc_dbg_q_dl_load_val		;



generate
for (i=0;i<PORTS_ADC*QUANTITY_FMC;i=i+1) begin : adc_phy_io_
adc_io_phy
#(
	.PORTS									(PORTS					 		),
	.DATA_WIDTH_ADC							(DATA_WIDTH_ADC			 		),
	.TIME_LENGTH_IDELAY_CALIB				(TIME_LENGTH_IDELAY_CALIB		),
	.USE_CHIPSCOPE							(0								)			    	
) 
adc_io_phy_inst
	(
	// system_interface
	.CLK_BUFR_I								(CLK_BUFR_I 				[i]	),
	.CLK_ADC_I								(CLK_ADC_I					[i]	),
	.CLK_BUFR_Q								(CLK_BUFR_Q 				[i]	),
	.CLK_ADC_Q								(CLK_ADC_Q					[i]	),
	.SYS_CLK								(SYS_CLK						),
	.SYS_WR_EN_ADC							(SYS_WR_EN_ADC					),
	.SYS_RST								(SYS_RST						),
	.SYS_RST_ILOGIC							(SYS_RST_ILOGIC					),
	.ISERDES_RESYNC							(ISERDES_RESYNC					),
	.ADC_CALIB_COMPLETE						(ADC_CLB_COMPL				[i]	),	
	// data_in 
	.DATA_I_P								(DATA_I_P 					[i]	),
	.DATA_I_N								(DATA_I_N 					[i]	),
	.DATA_Q_P								(DATA_Q_P 					[i]	),
	.DATA_Q_N								(DATA_Q_N 					[i]	),
	// data_out
	.DATA_O_I								(DATA_O_I					[i]	),		//i7i6i5i4i3i2i1i0
	.DATA_O_Q								(DATA_O_Q					[i]	),		//q7q6q5q4q3q2q1q0	
	// dbg_manual_calibration iodelay/bitslip
	.dbg_chipscope_clk                      (dbg_chipscope_clk              ),
	.dbg_clk_i								(dbg_clk_i						),
	.dbg_control_pin						(mux_adc_dbg_control_pin	[i]	),
	.dbg_bitslip_i							(mux_adc_dbg_bitslip_i	    [i]	),
	.dbg_bitslip_q							(mux_adc_dbg_bitslip_q		[i]	),
	.dbg_mux_lines							(mux_adc_dbg_mux_lines		[i]	),
	.dbg_i_dl_cnt_val_o						(mux_adc_dbg_i_dl_cnt_val_o	[i]	),
	.dbg_i_dl_ce							(mux_adc_dbg_i_dl_ce		[i]	),
	.dbg_i_dl_cnt_in						(mux_adc_dbg_i_dl_cnt_in	[i]	),
	.dbg_i_dl_in							(mux_adc_dbg_i_dl_in		[i]	),
	.dbg_i_dl_load_val						(mux_adc_dbg_i_dl_load_val	[i]	),
	.dbg_q_dl_cnt_val_o						(mux_adc_dbg_q_dl_cnt_val_o	[i]	),
	.dbg_q_dl_ce							(mux_adc_dbg_q_dl_ce		[i]	),
	.dbg_q_dl_cnt_in						(mux_adc_dbg_q_dl_cnt_in	[i]	),
	.dbg_q_dl_in							(mux_adc_dbg_q_dl_in		[i]	),
	.dbg_q_dl_load_val						(mux_adc_dbg_q_dl_load_val	[i]	),
	// Table idelay values 
    .bram_addr_adc_calib		            (bram_addr_adc_calib        [i] ),
    .bram_data_adc_calib		            (bram_data_adc_calib        [i] )	
);	
end
endgenerate


/////////////////////////////////////////////////////////////
// create MUX_ADC_LINES module 
/////////////////////////////////////////////////////////////
mux_lines_adc_io
	#(
		.PORTS 									(PORTS_ADC*QUANTITY_FMC			),
		.DATA_WIDTH_ADC							(DATA_WIDTH_ADC			 		)	
	)
mux_lines_switch_adc_inst
	(
	// system_interface
	.clk_i										(dbg_clk_i						),
	.rst_i										(SYS_RST 						),
	.mux_cntrl									(dbg_switch_adc					),	

	.dbg_control_pin_i							(dbg_control_pin				),
	.dbg_control_pin_o							(mux_adc_dbg_control_pin		),
	
	.dbg_mux_lines_i							(dbg_mux_lines					),
	.dbg_mux_lines_o							(mux_adc_dbg_mux_lines			),
	// idelay ports group in
	.i_i_dl_ce	    							(dbg_i_dl_ce	    			),						
	.i_i_dl_cnt_in								(dbg_i_dl_cnt_in				),                          
	.i_i_dl_in	    							(dbg_i_dl_in   					),                          
	.i_i_dl_load_val							(dbg_i_dl_load_val				),   
	.o_i_dl_cnt_val_o							(dbg_i_dl_cnt_val_o				),
	.i_q_dl_ce	    							(dbg_q_dl_ce   					),                          
	.i_q_dl_cnt_in								(dbg_q_dl_cnt_in				),                         
	.i_q_dl_in	    							(dbg_q_dl_in   					),                          
	.i_q_dl_load_val							(dbg_q_dl_load_val				), 
	.o_q_dl_cnt_val_o							(dbg_q_dl_cnt_val_o				),	
	// iodelay_group out                                                                                    
	.o_i_dl_ce	    							(mux_adc_dbg_i_dl_ce	    	),                          
	.o_i_dl_cnt_in								(mux_adc_dbg_i_dl_cnt_in		),
	.o_i_dl_in	    							(mux_adc_dbg_i_dl_in   			),
	.o_i_dl_load_val							(mux_adc_dbg_i_dl_load_val		),
	.i_i_dl_cnt_val_o							(mux_adc_dbg_i_dl_cnt_val_o		),
	.o_q_dl_ce	    							(mux_adc_dbg_q_dl_ce   			),
	.o_q_dl_cnt_in								(mux_adc_dbg_q_dl_cnt_in		),
	.o_q_dl_in	    							(mux_adc_dbg_q_dl_in   			),
	.o_q_dl_load_val							(mux_adc_dbg_q_dl_load_val		),
	.i_q_dl_cnt_val_o							(mux_adc_dbg_q_dl_cnt_val_o		),	
	.bitslip_i_i								(dbg_bitslip_i					),		
	.bitslip_q_i								(dbg_bitslip_q					),	
	.bitslip_i_o								(mux_adc_dbg_bitslip_i			),		
	.bitslip_q_o								(mux_adc_dbg_bitslip_q			)
	
	);
	
	
/*
////////////////////////////////////////////////////////////////////////////
// ChipScope
////////////////////////////////////////////////////////////////////////////
genvar j;
generate
	if (USE_CHIPSCOPE) begin: gen_chipscope
		// Domain clk_ser_div
		(* TIG = "TRUE" *) (* DONT_TOUCH = "TRUE" *) (* mark_debug = "TRUE" *) reg  [(PORTS-1):0][(PORTS-1):0]			cs_data_serdes_i	;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "TRUE" *) (* mark_debug = "TRUE" *) reg  [(PORTS-1):0][(PORTS-1):0]			cs_data_serdes_q	;
			
		for (i=0;i<PORTS;i=i+1) begin : cs_data_serdes_debug
				for (j=0;j<PORTS;j=j+1) begin
						always @(posedge clk_ser_div) begin
								cs_data_serdes_i[i][j] <= data_in_fifo_i[i][j] ;
								cs_data_serdes_q[i][j] <= data_in_fifo_q[i][j] ;
						end
			
		end	
		end
	end
endgenerate
*/

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
