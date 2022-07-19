`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// 
// Device 		:   bpac_059
//
/////////////////////////////////////////////////////////////////////////////////
*/
 
module adc_receiver
#(
parameter 							PORTS_ADC					= 2		,	// 4  
parameter							QUANTITY_FMC				= 4		,
parameter 							DATA_WIDTH_ADC				= 12	,  	// 4 
parameter							DATA_WIDTH_ADC_CV			= 16	,	
parameter							USE_ALIGNMENT_ALGORITHM		= "NO"	,
parameter                           DDELAY_IDELAY_FIXED_Q       = 6,//{16'd1, 16'd1, 16'd1, 16'd1, 16'd1, 16'd1, 16'd1, 16'd1},    
parameter                           DDELAY_IDELAY_FIXED_I       = 6,//{16'd1, 16'd14, 16'd14, 16'd14, 16'd14, 16'd14, 16'd14, 16'd14},

parameter							TIME_LENGTH_IDELAY_CALIB	= 8096	,
parameter							USE_CHIPSCOPE				= 1

 

) 
(
//	Z_ADC 0	//////////////////////////////////////////////////////////
input	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC1_I_DATA_P								,
input	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC1_I_DATA_N								,
input	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC1_Q_DATA_P								,
input	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC1_Q_DATA_N                             ,
input	wire										Z_ADC1_DCLKI_P								,
input	wire      									Z_ADC1_DCLKI_N								,
input	wire   										Z_ADC1_DCLKQ_P								,
input	wire   										Z_ADC1_DCLKQ_N								,

//	Z_ADC 1	//////////////////////////////////////////////////////////
input 	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC2_I_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC2_I_DATA_N								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC2_Q_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC2_Q_DATA_N                             ,
input 	wire										Z_ADC2_DCLKI_P								,
input 	wire      									Z_ADC2_DCLKI_N								,
input 	wire      									Z_ADC2_DCLKQ_P								,
input 	wire      									Z_ADC2_DCLKQ_N								,

//	Z_ADC 2	//////////////////////////////////////////////////////////
input 	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC3_I_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC3_I_DATA_N								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC3_Q_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC3_Q_DATA_N                             ,
input 	wire										Z_ADC3_DCLKI_P								,
input 	wire      									Z_ADC3_DCLKI_N								,
input 	wire      									Z_ADC3_DCLKQ_P								,
input 	wire      									Z_ADC3_DCLKQ_N								,

//	Z_ADC 3	//////////////////////////////////////////////////////////
input 	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC4_I_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC4_I_DATA_N								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC4_Q_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			Z_ADC4_Q_DATA_N                             ,
input 	wire										Z_ADC4_DCLKI_P								,
input 	wire      									Z_ADC4_DCLKI_N								,
input 	wire      									Z_ADC4_DCLKQ_P								,
input 	wire      									Z_ADC4_DCLKQ_N								,

//	ADC 0	//////////////////////////////////////////////////////////
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC1_I_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC1_I_DATA_N								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC1_Q_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC1_Q_DATA_N                             	,
input 	wire										ADC1_DCLKI_P								,
input 	wire      									ADC1_DCLKI_N								,
input 	wire      									ADC1_DCLKQ_P								,
input 	wire      									ADC1_DCLKQ_N								,

//	ADC 1	//////////////////////////////////////////////////////////
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC2_I_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC2_I_DATA_N								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC2_Q_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC2_Q_DATA_N                             	,
input 	wire										ADC2_DCLKI_P								,
input 	wire      									ADC2_DCLKI_N								,
input 	wire      									ADC2_DCLKQ_P								,
input 	wire      									ADC2_DCLKQ_N								,

//	ADC 2	//////////////////////////////////////////////////////////
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC3_I_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC3_I_DATA_N								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC3_Q_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC3_Q_DATA_N                             	,
input 	wire										ADC3_DCLKI_P								,
input 	wire      									ADC3_DCLKI_N								,
input 	wire      									ADC3_DCLKQ_P								,
input 	wire      									ADC3_DCLKQ_N								,

//	ADC 3	//////////////////////////////////////////////////////////
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC4_I_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC4_I_DATA_N								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC4_Q_DATA_P								,
input 	wire		[(DATA_WIDTH_ADC-1):0]			ADC4_Q_DATA_N                             	,
input 	wire										ADC4_DCLKI_P								,
input 	wire      									ADC4_DCLKI_N								,
input 	wire      									ADC4_DCLKQ_P								,
input 	wire      									ADC4_DCLKQ_N								,


output 	wire		[(PORTS_ADC-1):0]				HMC_DCLKOUT_P								,
output 	wire		[(PORTS_ADC-1):0]				HMC_DCLKOUT_N								,
output 	wire		[(PORTS_ADC-1):0]				Z_HMC_DCLKOUT_P								,
output 	wire		[(PORTS_ADC-1):0]				Z_HMC_DCLKOUT_N								,


// fpga_interface
output	wire		[(QUANTITY_FMC*PORTS_ADC-1):0] [127:0]								SYS_DATA_ADC_I						,	
output	wire		[(QUANTITY_FMC*PORTS_ADC-1):0] [127:0]								SYS_DATA_ADC_Q						,
output	wire																			SYS_DAV_ADC							,
input	wire																			SYS_RST								,
input	wire																			SYS_CLK								,
input	wire																			SYS_CLK_ALIGN						,
input	wire																			SYS_WR_EN_ADC						,	
input   wire        [(QUANTITY_FMC*PORTS_ADC-1):0]                                      adc_dclk_rst                        ,         

input	wire																			SYS_RST_BUFR						,
input 	wire																			SYS_RST_ILOGIC						,
output	wire		[(QUANTITY_FMC*PORTS_ADC-1):0] 										ADC_CLB_COMPL						,
output	wire		[(QUANTITY_FMC*PORTS_ADC-1):0] 										ALIGN_DATA_CMPL						,
input	wire		[(QUANTITY_FMC*PORTS_ADC*2-1):0]									BUFMR_CE_OE							,
// idelay_ctrl interface
input	wire																			REF_CLK_IODELAY						,	//200 MHz
output	wire		[(QUANTITY_FMC*PORTS_ADC-1):0]										RDY_IODELAY_CTRL					,
// dbg_manual_calibration iodelay/bitslip
input	wire      																		dbg_clk_i							,
input	wire      																		dbg_control_pin						,
input	wire 																			dbg_bitslip_i						,
input	wire 																			dbg_bitslip_q						,
input	wire     	[7:0]																dbg_mux_lines						,
output	wire     	[4:0]																dbg_i_dl_cnt_val_o					,
input	wire 																			dbg_i_dl_ce							,
input	wire     	[4:0]																dbg_i_dl_cnt_in						,
input	wire 																			dbg_i_dl_in							,
input	wire 																			dbg_i_dl_load_val					,
output	wire      	[4:0]																dbg_q_dl_cnt_val_o					,
input	wire 																			dbg_q_dl_ce							,
input	wire     	[4:0]																dbg_q_dl_cnt_in						,
input	wire 																			dbg_q_dl_in							,
input	wire 																			dbg_q_dl_load_val				    ,
input	wire		[(QUANTITY_FMC*PORTS_ADC-1):0]									    dbg_switch_adc		                ,	

input	wire		[7:0]  																mux_qi								,
input	wire																			en_align_data_adc					,
output	wire		[63:0]																data_ddelay							,

output	wire		[15:0]																dbg_bufr_clk_bus					,		
	
input	wire		[7:0][15:0]							                                bram_addr_adc_calib		            ,
output	wire 		[7:0][47:0]							                                bram_data_adc_calib     			



);

////////////////////////////////////////////////////////////////////////////
// Wires and regs
////////////////////////////////////////////////////////////////////////////
genvar                                                              	i              							;
(* KEEP = "TRUE" *)wire [(QUANTITY_FMC*PORTS_ADC-1):0]			        clk_i_p									;
(* KEEP = "TRUE" *)wire [(QUANTITY_FMC*PORTS_ADC-1):0]			        clk_i_n									;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										clk_bufr_i								;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										s_clk_i									;	

(* DONT_TOUCH = "TRUE" *)wire [(QUANTITY_FMC*PORTS_ADC-1):0]			clk_q_p									;
(* DONT_TOUCH = "TRUE" *)wire [(QUANTITY_FMC*PORTS_ADC-1):0]			clk_q_n									;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										clk_bufr_q								;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										s_clk_q									;


wire [(QUANTITY_FMC*PORTS_ADC-1):0][(DATA_WIDTH_ADC-1):0]				data_i_p								;
wire [(QUANTITY_FMC*PORTS_ADC-1):0][(DATA_WIDTH_ADC-1):0]				data_i_n								;				
wire [(QUANTITY_FMC*PORTS_ADC-1):0][(DATA_WIDTH_ADC-1):0]				data_q_p								;	
wire [(QUANTITY_FMC*PORTS_ADC-1):0][(DATA_WIDTH_ADC-1):0]				data_q_n								;


wire [(QUANTITY_FMC*PORTS_ADC-1):0][(8*DATA_WIDTH_ADC-1):0]				data_i									;	//i7i6i5i4i3i2i1i0
wire [(QUANTITY_FMC*PORTS_ADC-1):0][(8*DATA_WIDTH_ADC-1):0]				data_q									;	//q7q6q5q4q3q2q1q0	

wire [(QUANTITY_FMC*PORTS_ADC-1):0][(8*DATA_WIDTH_ADC_CV-1):0]			data_i_cv								;
wire [(QUANTITY_FMC*PORTS_ADC-1):0][(8*DATA_WIDTH_ADC_CV-1):0]			data_q_cv								;

wire [(QUANTITY_FMC*PORTS_ADC-1):0][(8*DATA_WIDTH_ADC_CV-1):0]			data_i_cv_d								;
wire [(QUANTITY_FMC*PORTS_ADC-1):0][(8*DATA_WIDTH_ADC_CV-1):0]			data_q_cv_d								;

////////////////////////////////////////////////////////////////////////////
// Mapping inputs
////////////////////////////////////////////////////////////////////////////
	assign clk_i_p[0] 	= Z_ADC1_DCLKI_P	;
    assign clk_i_p[1] 	= Z_ADC2_DCLKI_P	;
    assign clk_i_p[2] 	= Z_ADC3_DCLKI_P	;
    assign clk_i_p[3] 	= Z_ADC4_DCLKI_P	;
    assign clk_i_p[4] 	= 	ADC1_DCLKI_P	;
    assign clk_i_p[5] 	= 	ADC2_DCLKI_P	;
    assign clk_i_p[6] 	= 	ADC3_DCLKI_P	;
    assign clk_i_p[7] 	= 	ADC4_DCLKI_P	;

	
	assign clk_i_n[0] 	= Z_ADC1_DCLKI_N	;
    assign clk_i_n[1] 	= Z_ADC2_DCLKI_N	;
    assign clk_i_n[2] 	= Z_ADC3_DCLKI_N	;
    assign clk_i_n[3] 	= Z_ADC4_DCLKI_N	;
    assign clk_i_n[4] 	= 	ADC1_DCLKI_N	;
    assign clk_i_n[5] 	= 	ADC2_DCLKI_N	;
    assign clk_i_n[6] 	= 	ADC3_DCLKI_N	;
    assign clk_i_n[7] 	= 	ADC4_DCLKI_N	;
	

	assign clk_q_p[0] 	= Z_ADC1_DCLKQ_P	;
    assign clk_q_p[1] 	= Z_ADC2_DCLKQ_P	;
    assign clk_q_p[2] 	= Z_ADC3_DCLKQ_P	;
    assign clk_q_p[3] 	= Z_ADC4_DCLKQ_P	;
    assign clk_q_p[4] 	= 	ADC1_DCLKQ_P	;
    assign clk_q_p[5] 	= 	ADC2_DCLKQ_P	;
    assign clk_q_p[6] 	= 	ADC3_DCLKQ_P	;
    assign clk_q_p[7] 	= 	ADC4_DCLKQ_P	;

	
	assign clk_q_n[0] 	= Z_ADC1_DCLKQ_N	;
    assign clk_q_n[1] 	= Z_ADC2_DCLKQ_N	;
    assign clk_q_n[2] 	= Z_ADC3_DCLKQ_N	;
    assign clk_q_n[3] 	= Z_ADC4_DCLKQ_N	;
    assign clk_q_n[4] 	= 	ADC1_DCLKQ_N	;
    assign clk_q_n[5] 	= 	ADC2_DCLKQ_N	;
    assign clk_q_n[6] 	= 	ADC3_DCLKQ_N	;
    assign clk_q_n[7] 	= 	ADC4_DCLKQ_N	;	
	
	
	
	
	

assign	data_i_p	= {	ADC4_I_DATA_P, 	 ADC3_I_DATA_P,   ADC2_I_DATA_P ,   ADC1_I_DATA_P, 
					  Z_ADC4_I_DATA_P, Z_ADC3_I_DATA_P, Z_ADC2_I_DATA_P , Z_ADC1_I_DATA_P};		
assign	data_i_n	= {	ADC4_I_DATA_N, 	 ADC3_I_DATA_N,   ADC2_I_DATA_N ,   ADC1_I_DATA_N, 
					  Z_ADC4_I_DATA_N, Z_ADC3_I_DATA_N, Z_ADC2_I_DATA_N , Z_ADC1_I_DATA_N};		
				
				
				
assign	data_q_p	= {	ADC4_Q_DATA_P, 	 ADC3_Q_DATA_P,   ADC2_Q_DATA_P ,   ADC1_Q_DATA_P, 
					  Z_ADC4_Q_DATA_P, Z_ADC3_Q_DATA_P, Z_ADC2_Q_DATA_P , Z_ADC1_Q_DATA_P};		
assign	data_q_n	= {	ADC4_Q_DATA_N, 	 ADC3_Q_DATA_N,   ADC2_Q_DATA_N ,   ADC1_Q_DATA_N, 
					  Z_ADC4_Q_DATA_N, Z_ADC3_Q_DATA_N, Z_ADC2_Q_DATA_N , Z_ADC1_Q_DATA_N};			
	
				
////////////////////////////////////////////////////////////////////////////
// IDELAY_CTRL_INTERFACE
////////////////////////////////////////////////////////////////////////////
generate
for (i=0;i<PORTS_ADC*QUANTITY_FMC*2;i=i+1) begin : adc_delay_locked
(* IODELAY_GROUP = "adc_group" *)				
   IDELAYCTRL IDELAYCTRL_inst (
      .RDY			(RDY_IODELAY_CTRL				[i]   ),       // 1-bit output: Ready output
      .REFCLK		(REF_CLK_IODELAY				      ), 		 // 1-bit input: Reference clock input
      .RST			(SYS_RST						      )        // 1-bit input: Active high reset input
	);
end 
endgenerate

////////////////////////////////////////////////////////////////////////////
// Clocks and resets
////////////////////////////////////////////////////////////////////////////
clock_adc
#(
	.PORTS_ADC		((PORTS_ADC*QUANTITY_FMC)		),
	.DDELAY_IDELAY_FIXED(DDELAY_IDELAY_FIXED_I      )							
) 
clock_adc_i_inst
(
	.CLK_P_I		(clk_i_p						),
	.CLK_N_I		(clk_i_n						),
	.CLK_O			(s_clk_i    					),
	.BUFMR_CE_OE	(BUFMR_CE_OE[7:0]				),	
	.CLK_BUFR_O		(clk_bufr_i						),
	.RST_I			(SYS_RST | SYS_RST_BUFR		    ),	
	.dbg_chipscope_clk   (SYS_CLK_ALIGN             ),
	.dbg_bufr_clk_bus(dbg_bufr_clk_bus[7:0]			)			
);


clock_adc
#(
	.PORTS_ADC		((PORTS_ADC*QUANTITY_FMC)		),
	.DDELAY_IDELAY_FIXED(DDELAY_IDELAY_FIXED_Q      )						
) 
clock_adc_q_inst
(
	.CLK_P_I		(clk_q_p						),
	.CLK_N_I		(clk_q_n						),
	.CLK_O			(s_clk_q    					),
	.BUFMR_CE_OE	(BUFMR_CE_OE[15:8]				),	
	.CLK_BUFR_O		(clk_bufr_q						),
	.RST_I			(SYS_RST | SYS_RST_BUFR		    ),	
	.dbg_chipscope_clk   (SYS_CLK_ALIGN             ),
	.dbg_bufr_clk_bus(dbg_bufr_clk_bus[15:8]		)
	
);


////////////////////////////////////////////////////////////////////////////
// data_input modules
////////////////////////////////////////////////////////////////////////////	
adc_phy_mult
#(
	.PORTS						(8							),
	.DATA_WIDTH_ADC				(DATA_WIDTH_ADC				),
	.PORTS_ADC					(PORTS_ADC					),
	.QUANTITY_FMC				(QUANTITY_FMC				),
	.TIME_LENGTH_IDELAY_CALIB	(TIME_LENGTH_IDELAY_CALIB	),
	.USE_CHIPSCOPE				(0							)		
)
adc_phy_mult_inst
(	
	// system_interface
	.CLK_BUFR_I					(clk_bufr_i					),
	.CLK_ADC_I					(s_clk_i					),
	.CLK_BUFR_Q					(clk_bufr_q	                ),
	.CLK_ADC_Q					(s_clk_q		            ),	
	.SYS_CLK					(SYS_CLK					),
	.SYS_RST					(SYS_RST					),
	.SYS_WR_EN_ADC				(SYS_WR_EN_ADC				),
	.SYS_RST_ILOGIC				(SYS_RST | SYS_RST_ILOGIC	),
	.ISERDES_RESYNC				(SYS_RST | SYS_RST_ILOGIC	),
	.ADC_CLB_COMPL				(ADC_CLB_COMPL				),
	// data_in 
	.DATA_I_P					(data_i_p					),
	.DATA_I_N					(data_i_n					),
	.DATA_Q_P					(data_q_p					),
	.DATA_Q_N					(data_q_n					),
	// data_out
	.DATA_O_I					(data_i						),			//i7i6i5i4i3i2i1i0
	.DATA_O_Q					(data_q						),			//q7q6q5q4q3q2q1q0
	// dbg_manual_calibration iodelay/bitslip
	.dbg_chipscope_clk          (SYS_CLK_ALIGN              ),
	.dbg_clk_i					(dbg_clk_i					),
	.dbg_control_pin			(dbg_control_pin			),
	.dbg_bitslip_i				(dbg_bitslip_i				),
	.dbg_bitslip_q				(dbg_bitslip_q				),
	.dbg_mux_lines				(dbg_mux_lines				),
	.dbg_i_dl_cnt_val_o			(dbg_i_dl_cnt_val_o			),
	.dbg_i_dl_ce				(dbg_i_dl_ce				),
	.dbg_i_dl_cnt_in			(dbg_i_dl_cnt_in			),
	.dbg_i_dl_in				(dbg_i_dl_in				),
	.dbg_i_dl_load_val			(dbg_i_dl_load_val			),
	.dbg_q_dl_cnt_val_o			(dbg_q_dl_cnt_val_o			),
	.dbg_q_dl_ce				(dbg_q_dl_ce				),
	.dbg_q_dl_cnt_in			(dbg_q_dl_cnt_in			),
	.dbg_q_dl_in				(dbg_q_dl_in				),
	.dbg_q_dl_load_val			(dbg_q_dl_load_val			),
	.dbg_switch_adc             (dbg_switch_adc             ),
	// Table idelay values 
    .bram_addr_adc_calib		(bram_addr_adc_calib        ),
    .bram_data_adc_calib		(bram_data_adc_calib        )		
);  



////////////////////////////////////////////////////////////////////////////
// Resynch ADC words
////////////////////////////////////////////////////////////////////////////
wire 	[(PORTS_ADC*QUANTITY_FMC-1):0]				s_empty_adc_fifo		;
wire 	[(PORTS_ADC*QUANTITY_FMC-1):0]				s_dav_adc_fifo			;
wire 	[(PORTS_ADC*QUANTITY_FMC-1):0]				s_dav_adc_fifo_d		;
wire	[(PORTS_ADC*QUANTITY_FMC-1):0] [191:0]		s_dout_adc_fifo			;
wire 	[(PORTS_ADC*QUANTITY_FMC-1):0]				s_full_adc_fifo		    ;


generate
for (i=0;i<PORTS_ADC*QUANTITY_FMC;i=i+1) begin : adc_fifo

adc_fifo
adc_fifo_i_inst
  (
	.rst 			(SYS_RST| SYS_RST_ILOGIC						),//: IN STD_LOGIC;
	.clk 			(SYS_CLK										),//: IN STD_LOGIC;
	.din 			({data_i[i], data_q [i]}						),//: IN STD_LOGIC_VECTOR(191 DOWNTO 0);   // i7i6i5i4i3i2i1i0_q7q6q5q4q3q2q1q0
	.wr_en 			(~s_full_adc_fifo   [i] & SYS_WR_EN_ADC			),//: IN STD_LOGIC;
	.rd_en 			(~s_empty_adc_fifo	[i] & SYS_WR_EN_ADC  		),//: IN STD_LOGIC;
	.dout 			(s_dout_adc_fifo	[i]				            ),//: OUT STD_LOGIC_VECTOR(191 DOWNTO 0);  // i7i6i5i4i3i2i1i0_q7q6q5q4q3q2q1q0
	.full 			(s_full_adc_fifo    [i]              	        ),//: OUT STD_LOGIC;
	.overflow 		(									            ),//: OUT STD_LOGIC;
	.empty 			(s_empty_adc_fifo	[i]	              			),//: OUT STD_LOGIC;
	.valid 			(s_dav_adc_fifo		[i]							),//: OUT STD_LOGIC;
	.underflow 		(												),//: OUT STD_LOGIC;
	.wr_rst_busy 	(												),//: OUT STD_LOGIC;
	.rd_rst_busy 	(												) //: OUT STD_LOGIC
  );
  
end 
endgenerate


////////////////////////////////////////////////////////////////////////////
// Mapping outputs
////////////////////////////////////////////////////////////////////////////
wire				[(PORTS_ADC	-1):0]      s_adc_dclk_rst											;
wire				[(PORTS_ADC	-1):0]      s_z_adc_dclk_rst										;

assign              s_adc_dclk_rst          = adc_dclk_rst [3:0];  
assign              s_z_adc_dclk_rst        = adc_dclk_rst [7:4];

generate
for (i=0;i<PORTS_ADC*QUANTITY_FMC;i=i+1) begin : mappings

	data_bit2data_bit
	#(
		.PORTS						(PORTS_ADC*QUANTITY_FMC		),
		.INPUT_DATA_WIDTH			(12							),  
		.OUTPUT_DATA_WIDTH			(16							)
	) 
	data_bit2data_bit_i
	(
		.data_in 					(s_dout_adc_fifo [i][191:96]),
		.data_out					(data_i_cv		 [i]		)
	);
	
	data_bit2data_bit
	#(
		.PORTS						(PORTS_ADC*QUANTITY_FMC		),
		.INPUT_DATA_WIDTH			(12							),  
		.OUTPUT_DATA_WIDTH			(16							)
	) 
	data_bit2data_bit_q
	(
		.data_in 					(s_dout_adc_fifo [i][95:0]  ),
		.data_out					(data_q_cv		 [i]		)
	);
end 
endgenerate


generate
if(USE_ALIGNMENT_ALGORITHM == "YES") begin
	adc_data_alignment_mult
	#(
		.CHANNELS							(PORTS_ADC*QUANTITY_FMC		),
		.PORTS_ADC							(PORTS_ADC					),	// 4  
		.QUANTITY_FMC						(QUANTITY_FMC				),
		.DATA_WIDTH_ADC						(DATA_WIDTH_ADC				),  // 4 
		.DATA_WIDTH_ADC_CV					(DATA_WIDTH_ADC_CV			)
	)
	adc_data_alignment_mult_inst
	(
		.rst								(SYS_RST| SYS_RST_ILOGIC	),
		.clk								(SYS_CLK					),
		.clk_inside							(SYS_CLK_ALIGN				),
		.align_cmpl							(ALIGN_DATA_CMPL			),
		.en_align							(en_align_data_adc			),
		
		.mux_qi								(mux_qi						),
		
		.adc_dvalid_i						(s_dav_adc_fifo				),	
		.adc_i_data_i						(data_i_cv		 			),
		.adc_q_data_i						(data_q_cv		 			),
		
		.adc_dvalid_o						(s_dav_adc_fifo_d			),	
		.adc_i_data_o						(data_i_cv_d	 			),
		.adc_q_data_o						(data_q_cv_d	 			),	
		
		.data_ddelay_i						(data_ddelay[63:32]			),
		.data_ddelay_q						(data_ddelay[31:0 ]			)
		
	);
end 
else begin
	assign data_i_cv_d		=	data_i_cv			;
	assign data_q_cv_d      =	data_q_cv	        ;
	assign s_dav_adc_fifo_d =	s_dav_adc_fifo	    ;
end 
endgenerate

////////////////////////////////////////////////////////////////////////////
// Port outputs
////////////////////////////////////////////////////////////////////////////

assign 	   SYS_DAV_ADC			  =  &s_dav_adc_fifo_d 		;

generate
for (i=0;i<PORTS_ADC*QUANTITY_FMC;i=i+1) begin : gen_outputs
	assign SYS_DATA_ADC_I	[i]   =  data_i_cv_d		[i]	;
	assign SYS_DATA_ADC_Q	[i]   =  data_q_cv_d		[i]	;
end 
endgenerate

generate
for (i=0;i<PORTS_ADC;i=i+1) begin : generate_adc_dclk_rst

 OBUFDS #(
      .IOSTANDARD	("LVDS"					), 				// Specify the output I/O standard
      .SLEW			("SLOW"					)           	// Specify the output slew rate
   ) OBUFDS_adc_inst (
      .O			(HMC_DCLKOUT_P		[i]	),     			// Diff_p output (connect directly to top-level port)
      .OB			(HMC_DCLKOUT_N		[i]	),   			// Diff_n output (connect directly to top-level port)
      .I			(s_adc_dclk_rst     [i]	)      			// Buffer input
   );

 OBUFDS #(
      .IOSTANDARD	("LVDS"					), 				// Specify the output I/O standard
      .SLEW			("SLOW"					)           	// Specify the output slew rate
   ) OBUFDS_z_adc_inst (
      .O			(Z_HMC_DCLKOUT_P	[i]	),     			// Diff_p output (connect directly to top-level port)
      .OB			(Z_HMC_DCLKOUT_N	[i]	),   			// Diff_n output (connect directly to top-level port)
      .I			(s_z_adc_dclk_rst	[i]	)      			// Buffer input
   );

end
endgenerate


////////////////////////////////////////////////////////////////////////////
// ChipScope
////////////////////////////////////////////////////////////////////////////
generate
	if (USE_CHIPSCOPE) begin: gen_chipscope

		//(* TIG = "TRUE" *) (* DONT_TOUCH = "TRUE" *)  (* mark_debug = "TRUE" *) reg  [(PORTS-1):0][(8-1):0]					cs_data_serdes_i			;

		always @(posedge SYS_CLK) begin
	

		end
	
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