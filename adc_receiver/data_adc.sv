`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// Device 		:   bpac_059
// Description  :	Module ADC IDELAY ISERDES
//
/////////////////////////////////////////////////////////////////////////////////
*/
 
module data_adc
#(
parameter 			PORTS								= 8			,
parameter			ISERDES_BITS						= 8				, //8 OR 4 
parameter 			TDATA_WIDTH							= ISERDES_BITS	,
parameter			IDELAYE2_SETUP						= "YES"			, // YES || NO 
parameter			USE_CHIPSCOPE						= 0						    	
) 
(
// system_interface
input	wire					 						CLK_BUFR_I		,
input	wire					  						CLK_ADC_I		,
input	wire					 						CLK_BUFR_Q		,
input	wire					  						CLK_ADC_Q		,
input   wire											IDELAY_CLK		,
input	wire											SYS_CLK			,
input	wire											SYS_WR_EN_ADC	,
input	wire					  						RST_I			,

// iodelay_group
output	wire		[(PORTS-1):0][4:0] 					i_dl_cnt_val_o	,
input   wire 		[(PORTS-1):0]						i_dl_ce	        ,
input	wire		[(PORTS-1):0][4:0]					i_dl_cnt_in	    ,
input	wire 		[(PORTS-1):0]						i_dl_in	        ,
input	wire		[(PORTS-1):0]						i_dl_load_val	,

output	wire		[(PORTS-1):0][4:0] 					q_dl_cnt_val_o	,
input   wire 		[(PORTS-1):0]						q_dl_ce	        ,
input	wire		[(PORTS-1):0][4:0]					q_dl_cnt_in	    ,
input	wire 		[(PORTS-1):0]						q_dl_in	        ,
input	wire		[(PORTS-1):0]						q_dl_load_val	,

// SERDES
input	wire 		[(PORTS-1):0]						BITSIP_I		,
input	wire		[(PORTS-1):0]						BITSIP_Q		,
input   wire											ISERDES_RESYNC	,

// data 
input	wire		[(PORTS-1):0]						DATA_I_P		,
input	wire      	[(PORTS-1):0]						DATA_I_N		,
input	wire		[(PORTS-1):0]						DATA_Q_P		,
input	wire      	[(PORTS-1):0]						DATA_Q_N		,

output  reg         [(PORTS-1):0][(TDATA_WIDTH-1):0]	DATA_SERDES_I_CAL,
output  reg         [(PORTS-1):0][(TDATA_WIDTH-1):0]	DATA_SERDES_Q_CAL,

output	wire		[(TDATA_WIDTH-1):0][(PORTS-1):0]	DATA_O_I		,
output	wire		[(TDATA_WIDTH-1):0][(PORTS-1):0]	DATA_O_Q        ,

input	wire											dbg_chipscope_clk			
	

);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wires and regs
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
genvar													i					;
genvar													j					;
wire				[(PORTS-1):0]						data_i				;
wire				[(PORTS-1):0]						io_data_i			;
wire				[(PORTS-1):0]						data_q				;
wire				[(PORTS-1):0]						io_data_q			;


wire													clk_ser_i			;
wire													clk_ser_i_n			;
wire													clk_ser_i_div		;

wire													clk_ser_q			;
wire													clk_ser_q_n			;
wire													clk_ser_q_div		;

wire				[(PORTS-1):0][(TDATA_WIDTH-1):0]	data_serdes_i		;		
wire				[(PORTS-1):0][(TDATA_WIDTH-1):0]	data_serdes_q		;	

wire				[(TDATA_WIDTH-1):0][(PORTS-1):0]	data_serdes_i_group	;
wire				[(TDATA_WIDTH-1):0][(PORTS-1):0]	data_serdes_q_group	;

wire				[(PORTS-1):0]						s_bitslip_i			;
wire				[(PORTS-1):0]						s_bitslip_q			;

wire				[(PORTS-1):0]						s_bitslip_i_detect_edge;
wire				[(PORTS-1):0]						s_bitslip_q_detect_edge;

wire 				[(ISERDES_BITS/4-1):0]				almostempty_in_fifo_i ;
wire 				[(ISERDES_BITS/4-1):0]				almostfull_in_fifo_i  ;
wire 				[(ISERDES_BITS/4-1):0]				empty_in_fifo_i       ;
wire 				[(ISERDES_BITS/4-1):0]				full_in_fifo_i        ;
wire 				[(ISERDES_BITS/4-1):0]				almostempty_in_fifo_q ;
wire 				[(ISERDES_BITS/4-1):0]				almostfull_in_fifo_q  ;
wire 				[(ISERDES_BITS/4-1):0]				empty_in_fifo_q       ;
wire 				[(ISERDES_BITS/4-1):0]				full_in_fifo_q        ; 

wire 				[(PORTS-1):0][(TDATA_WIDTH/2-1):0] 	data_in_fifo_i_ch0	; 
wire 				[(PORTS-1):0][(TDATA_WIDTH/2-1):0] 	data_in_fifo_i_ch1	; 
wire 				[(PORTS-1):0][(TDATA_WIDTH/2-1):0] 	data_in_fifo_q_ch0	; 
wire 				[(PORTS-1):0][(TDATA_WIDTH/2-1):0] 	data_in_fifo_q_ch1	; 
wire 				[(PORTS-1):0][(TDATA_WIDTH-1):0] 	data_in_fifo_i		; 
wire 				[(PORTS-1):0][(TDATA_WIDTH-1):0] 	data_in_fifo_q		; 

wire				[(PORTS-1):0]						iserdes_reset_i      ;
wire				[(PORTS-1):0]						iserdes_reset_q      ;

wire				[1:0]								wr_en_infifo_i		;	
wire				[1:0]								wr_en_infifo_q		;	


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Assigns
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

assign clk_ser_i		= CLK_ADC_I		;					
assign clk_ser_i_n		= ~CLK_ADC_I	;						
assign clk_ser_i_div	= CLK_BUFR_I	;		

assign clk_ser_q		= CLK_ADC_Q		;					
assign clk_ser_q_n		= ~CLK_ADC_Q	;						
assign clk_ser_q_div	= CLK_BUFR_Q	;	

generate
for (i=0;i<PORTS;i=i+1) begin
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//IBUFDS
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   IBUFDS #(
      .DIFF_TERM			("TRUE"			),    	// Differential Termination
      .IBUF_LOW_PWR			("FALSE"		),    	// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD			("LVDS"			)     	// Specify the input I/O standard
   ) IBUFDS_I_inst (
      .O					(data_i	 [i]	),  	// Buffer output
      .I					(DATA_I_P[i]	),  	// Diff_p buffer input (connect directly to top-level port)
      .IB					(DATA_I_N[i]	) 		// Diff_n buffer input (connect directly to top-level port)
   );

   IBUFDS #(
      .DIFF_TERM			("TRUE"			),    	// Differential Termination
      .IBUF_LOW_PWR			("FALSE"		),    	// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD			("LVDS"			)     	// Specify the input I/O standard
   ) IBUFDS_Q_inst (
      .O					(data_q	 [i]	),  	// Buffer output
      .I					(DATA_Q_P[i]	),  	// Diff_p buffer input (connect directly to top-level port)
      .IB					(DATA_Q_N[i]	) 		// Diff_n buffer input (connect directly to top-level port)
   );
   
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//IDELAYE2
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////   
if (IDELAYE2_SETUP == "YES") begin

(* IODELAY_GROUP = "adc_group" *)
 IDELAYE2 #(
      .CINVCTRL_SEL			("FALSE"		),          // Enable dynamic clock inversion (FALSE, TRUE)
      .DELAY_SRC			("IDATAIN"		),          // Delay input (IDATAIN, DATAIN)
      .HIGH_PERFORMANCE_MODE("FALSE"		), 			// Reduced jitter ("TRUE"), Reduced power ("FALSE")
      .IDELAY_TYPE			("FIXED"		),          // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
      .IDELAY_VALUE			(23				),          // Input delay tap setting (0-31)
      .PIPE_SEL				("FALSE"		),          // Select pipelined mode, FALSE, TRUE
      .REFCLK_FREQUENCY		(200.0			),        	// IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
      .SIGNAL_PATTERN		("DATA"			)          	// DATA, CLOCK input signal
   )
   IDELAYE2_adc_i_inst (
      .CNTVALUEOUT			(i_dl_cnt_val_o[i]), 		 // 5-bit output: Counter value output
      .DATAOUT				(io_data_i	[i]	),         	 // 1-bit output: Delayed data output
      .C					(IDELAY_CLK		),           // 1-bit input: Clock input
      .CE					(i_dl_ce	[i]	),           // 1-bit input: Active high enable increment/decrement input
      .CINVCTRL				(1'b0			),       	 // 1-bit input: Dynamic clock inversion input
      .CNTVALUEIN			(i_dl_cnt_in[i]),   		 // 5-bit input: Counter value input
      .DATAIN				(1'b0			),           // 1-bit input: Internal delay data input
      .IDATAIN				(data_i		[i]	),         	 // 1-bit input: Data input from the I/O
      .INC					(i_dl_in	[i]	),           // 1-bit input: Increment / Decrement tap delay input
      .LD					(i_dl_load_val[i]),          // 1-bit input: Load IDELAY_VALUE input
      .LDPIPEEN				(1'b0			),		     // 1-bit input: Enable PIPELINE register to load data input
      .REGRST				(ISERDES_RESYNC	|| RST_I) 			 // 1-bit input: Active-high reset tap-delay input
   );
   
(* IODELAY_GROUP = "adc_group" *)
 IDELAYE2 #(
      .CINVCTRL_SEL			("FALSE"		),          // Enable dynamic clock inversion (FALSE, TRUE)
      .DELAY_SRC			("IDATAIN"		),          // Delay input (IDATAIN, DATAIN)
      .HIGH_PERFORMANCE_MODE("FALSE"		), 			// Reduced jitter ("TRUE"), Reduced power ("FALSE")
      .IDELAY_TYPE			("FIXED"		),          // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
      .IDELAY_VALUE			(23				),          // Input delay tap setting (0-31)
      .PIPE_SEL				("FALSE"		),          // Select pipelined mode, FALSE, TRUE
      .REFCLK_FREQUENCY		(200.0			),        	// IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
      .SIGNAL_PATTERN		("DATA"			)          	// DATA, CLOCK input signal
   )
   IDELAYE2_adc_q_inst (
      .CNTVALUEOUT			(q_dl_cnt_val_o[i]), 		 // 5-bit output: Counter value output
      .DATAOUT				(io_data_q	[i]	),         	 // 1-bit output: Delayed data output
      .C					(IDELAY_CLK	    ),           // 1-bit input: Clock input
      .CE					(q_dl_ce	[i]	),           // 1-bit input: Active high enable increment/decrement input
      .CINVCTRL				(1'b0			),       	 // 1-bit input: Dynamic clock inversion input
      .CNTVALUEIN			(q_dl_cnt_in[i]	),   		 // 5-bit input: Counter value input
      .DATAIN				(1'b0			),           // 1-bit input: Internal delay data input
      .IDATAIN				(data_q		[i]	),         	 // 1-bit input: Data input from the I/O
      .INC					(q_dl_in	[i]	),           	 // 1-bit input: Increment / Decrement tap delay input
      .LD					(q_dl_load_val[i]),          // 1-bit input: Load IDELAY_VALUE input
      .LDPIPEEN				(1'b0			),		     // 1-bit input: Enable PIPELINE register to load data input
      .REGRST				(ISERDES_RESYNC	|| RST_I)            // 1-bit input: Active-high reset tap-delay input
   );
end 
else 
begin

(* IODELAY_GROUP = "adc_group" *)
 IDELAYE2 #(
      .CINVCTRL_SEL			("FALSE"		),          // Enable dynamic clock inversion (FALSE, TRUE)
      .DELAY_SRC			("IDATAIN"		),          // Delay input (IDATAIN, DATAIN)
      .HIGH_PERFORMANCE_MODE("FALSE"		), 			// Reduced jitter ("TRUE"), Reduced power ("FALSE")
      .IDELAY_TYPE			("VAR_LOAD"		),          // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
      .IDELAY_VALUE			(14				),          // Input delay tap setting (0-31)
      .PIPE_SEL				("FALSE"		),          // Select pipelined mode, FALSE, TRUE
      .REFCLK_FREQUENCY		(200.0			),        	// IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
      .SIGNAL_PATTERN		("DATA"			)          	// DATA, CLOCK input signal
   )
   IDELAYE2_adc_i_inst (
      .CNTVALUEOUT			(				 ), 		 // 5-bit output: Counter value output
      .DATAOUT				(io_data_i	[i]	 ),          // 1-bit output: Delayed data output
      .C					(clk_ser_i_div   ),          // 1-bit input: Clock input
      .CE					(1'b0		  	 ),          // 1-bit input: Active high enable increment/decrement input
      .CINVCTRL				(1'b0			 ),       	 // 1-bit input: Dynamic clock inversion input
      .CNTVALUEIN			(5'd0			 ),   		 // 5-bit input: Counter value input
      .DATAIN				(1'b0			 ),          // 1-bit input: Internal delay data input
      .IDATAIN				(data_i		[i]	 ),          // 1-bit input: Data input from the I/O
      .INC					(1'b0			 ),          // 1-bit input: Increment / Decrement tap delay input
      .LD					(1'b0			 ),          // 1-bit input: Load IDELAY_VALUE input
      .LDPIPEEN				(1'b0			 ),		     // 1-bit input: Enable PIPELINE register to load data input
      .REGRST				(1'b0			 ) 			 // 1-bit input: Active-high reset tap-delay input
   );
   
assign i_dl_cnt_val_o[i] = 5'd0;   
   
(* IODELAY_GROUP = "adc_group" *)
 IDELAYE2 #(
      .CINVCTRL_SEL			("FALSE"		),          // Enable dynamic clock inversion (FALSE, TRUE)
      .DELAY_SRC			("IDATAIN"		),          // Delay input (IDATAIN, DATAIN)
      .HIGH_PERFORMANCE_MODE("FALSE"		), 			// Reduced jitter ("TRUE"), Reduced power ("FALSE")
      .IDELAY_TYPE			("VAR_LOAD"		),          // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
      .IDELAY_VALUE			(14				),          // Input delay tap setting (0-31)
      .PIPE_SEL				("FALSE"		),          // Select pipelined mode, FALSE, TRUE
      .REFCLK_FREQUENCY		(200.0			),        	// IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
      .SIGNAL_PATTERN		("DATA"			)          	// DATA, CLOCK input signal
   )
   IDELAYE2_adc_q_inst (
      .CNTVALUEOUT			(				), 		 	 // 5-bit output: Counter value output
      .DATAOUT				(io_data_q	[i]	),         	 // 1-bit output: Delayed data output
      .C					(clk_ser_q_div  ),           // 1-bit input: Clock input
      .CE					(1'b0			),           // 1-bit input: Active high enable increment/decrement input
      .CINVCTRL				(1'b0			),       	 // 1-bit input: Dynamic clock inversion input
      .CNTVALUEIN			(5'd0			),   		 // 5-bit input: Counter value input
      .DATAIN				(1'b0			),           // 1-bit input: Internal delay data input
      .IDATAIN				(data_q		[i]	),         	 // 1-bit input: Data input from the I/O
      .INC					(1'b0			),           // 1-bit input: Increment / Decrement tap delay input
      .LD					(1'b0			),           // 1-bit input: Load IDELAY_VALUE input
      .LDPIPEEN				(1'b0			),		     // 1-bit input: Enable PIPELINE register to load data input
      .REGRST				(1'b0			)            // 1-bit input: Active-high reset tap-delay input
   );

assign q_dl_cnt_val_o[i] = 5'd0;      
end 
 
	/////////////////////////////////////////////////////////////
	// create iserdes module
	/////////////////////////////////////////////////////////////
if (ISERDES_BITS == 4) begin: gen_4x_cascade
 ISERDESE2 #(
      .DATA_RATE			("DDR"								),          		// DDR, SDR
      .DATA_WIDTH			(4									),          		// Parallel data width (2-8,10,14)
      .DYN_CLKDIV_INV_EN	("FALSE"							),				    // Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
      .DYN_CLK_INV_EN		("FALSE"							),    				// Enable DYNCLKINVSEL inversion (FALSE, TRUE)
																					// INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
      .INIT_Q1				(1'b0								),
      .INIT_Q2				(1'b0								),
      .INIT_Q3				(1'b0								),
      .INIT_Q4				(1'b0								),
      .INTERFACE_TYPE		("NETWORKING"						),   				// MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
      .IOBDELAY				("IFD"								),          		// NONE, BOTH, IBUF, IFD
      .NUM_CE				(2									),          		// Number of clock enables (1,2)
      .OFB_USED				("FALSE"							),          		// Select OFB path (FALSE, TRUE)
      .SERDES_MODE			("MASTER"							),      			// MASTER, SLAVE
																					// SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
      .SRVAL_Q1				(1'b0								),
      .SRVAL_Q2				(1'b0								),
      .SRVAL_Q3				(1'b0								),
      .SRVAL_Q4				(1'b0								)
   )
   ISERDESE2_i_data_inst (
      .O					(									),                  // 1-bit output: Combinatorial output
																					// Q1 - Q8: 1-bit (each) output: Registered data outputs
      .Q1					(data_serdes_i	[i][0]				),
      .Q2					(data_serdes_i	[i][1]				),
      .Q3					(data_serdes_i	[i][2]				),
      .Q4					(data_serdes_i	[i][3]				),
      .Q5					(/*data_serdes_i	[i][4]	*/		),
      .Q6					(/*data_serdes_i	[i][5]	*/		),
      .Q7					(/*data_serdes_i	[i][6]	*/		),
      .Q8					(/*data_serdes_i	[i][7]	*/		),
																					// SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
      .SHIFTOUT1			(									),
      .SHIFTOUT2			(									),
      .BITSLIP				(s_bitslip_i				[i]		),           		// 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
																					// CLKDIV when asserted (active High). Subsequently, the data seen on the Q1
																					// to Q8 output ports will shift, as in a barrel-shifter operation, one
																					// position every time Bitslip is invoked (DDR operation is different from
																					// SDR).
      .CE1					(1'b1								),			 		// CE1, CE2: 1-bit (each) input: Data register clock enable inputs
      .CE2					(1'b1								),
      .CLKDIVP				(1'b0								),          		// 1-bit input: TBD
																					// Clocks: 1-bit (each) input: ISERDESE2 clock input ports
      .CLK					(clk_ser_i							),                  // 1-bit input: High-speed clock
      .CLKB					(clk_ser_i_n						),                 	// 1-bit input: High-speed secondary clock
      .CLKDIV				(clk_ser_i_div						),             		// 1-bit input: Divided clock
      .OCLK					(1'b0								),                 	// 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
																					// Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
      .DYNCLKDIVSEL			(1'b0								), 					// 1-bit input: Dynamic CLKDIV inversion
      .DYNCLKSEL			(1'b0								), 	     			// 1-bit input: Dynamic CLK/CLKB inversion
																					// Input Data: 1-bit (each) input: ISERDESE2 data input ports
      .D					(1'b0/*data_i		[i]*/			),                 	// 1-bit input: Data input
      .DDLY					(io_data_i	[i]						),                 	// 1-bit input: Serial data from IDELAYE2
      .OFB					(1'b0								),                 	// 1-bit input: Data feedback from OSERDESE2
      .OCLKB				(1'b0								),                 	// 1-bit input: High speed negative edge output clock
      .RST					(iserdes_reset_i[i]			        ),                 	// 1-bit input: Active high asynchronous reset
																					// SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
      .SHIFTIN1				(1'b0								),
      .SHIFTIN2				(1'b0								)
   );


  ISERDESE2 #(
      .DATA_RATE			("DDR"								),          		// DDR, SDR
      .DATA_WIDTH			(4									),          		// Parallel data width (2-8,10,14)
      .DYN_CLKDIV_INV_EN	("FALSE"							), 					// Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
      .DYN_CLK_INV_EN		("FALSE"							),    				// Enable DYNCLKINVSEL inversion (FALSE, TRUE)
																					// INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
      .INIT_Q1				(1'b0								),
      .INIT_Q2				(1'b0								),
      .INIT_Q3				(1'b0								),
      .INIT_Q4				(1'b0								),
      .INTERFACE_TYPE		("NETWORKING"						),   				// MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
      .IOBDELAY				("IFD"								),          		// NONE, BOTH, IBUF, IFD
      .NUM_CE				(2									),          		// Number of clock enables (1,2)
      .OFB_USED				("FALSE"							),          		// Select OFB path (FALSE, TRUE)
      .SERDES_MODE			("MASTER"							),      			// MASTER, SLAVE
																					// SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
      .SRVAL_Q1				(1'b0								),
      .SRVAL_Q2				(1'b0								),
      .SRVAL_Q3				(1'b0								),
      .SRVAL_Q4				(1'b0								)
   )
   ISERDESE2_q_data_inst (
      .O					(									),                  // 1-bit output: Combinatorial output
																					// Q1 - Q8: 1-bit (each) output: Registered data outputs
      .Q1					(data_serdes_q	[i][0]				),
      .Q2					(data_serdes_q	[i][1]				),
      .Q3					(data_serdes_q	[i][2]				),
      .Q4					(data_serdes_q	[i][3]				),
      .Q5					(/*data_serdes_q	[i][4]		*/	),
      .Q6					(/*data_serdes_q	[i][5]		*/	),
      .Q7					(/*data_serdes_q	[i][6]		*/	),
      .Q8					(/*data_serdes_q	[i][7]		*/	),
																					// SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
      .SHIFTOUT1			(									),
      .SHIFTOUT2			(									),
      .BITSLIP				(s_bitslip_q 				[i]		),           		// 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
																					// CLKDIV when asserted (active High). Subsequently, the data seen on the Q1
																					// to Q8 output ports will shift, as in a barrel-shifter operation, one
																					// position every time Bitslip is invoked (DDR operation is different from
																					// SDR).
      .CE1					(1'b1								),			 		// CE1, CE2: 1-bit (each) input: Data register clock enable inputs
      .CE2					(1'b1								),
      .CLKDIVP				(1'b0								),          		// 1-bit input: TBD
																					// Clocks: 1-bit (each) input: ISERDESE2 clock input ports
      .CLK					(clk_ser_q							),                  // 1-bit input: High-speed clock
      .CLKB					(clk_ser_q_n						),                 	// 1-bit input: High-speed secondary clock
      .CLKDIV				(clk_ser_q_div						),             		// 1-bit input: Divided clock
      .OCLK					(1'b0								),                 	// 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
																					// Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
      .DYNCLKDIVSEL			(1'b0								), 					// 1-bit input: Dynamic CLKDIV inversion
      .DYNCLKSEL			(1'b0								), 	     			// 1-bit input: Dynamic CLK/CLKB inversion
																					// Input Data: 1-bit (each) input: ISERDESE2 data input ports
      .D					(1'b0/*data_q		[i]*/			),                 	// 1-bit input: Data input
      .DDLY					(io_data_q	[i]						),                 	// 1-bit input: Serial data from IDELAYE2
      .OFB					(1'b0								),                 	// 1-bit input: Data feedback from OSERDESE2
      .OCLKB				(1'b0								),                 	// 1-bit input: High speed negative edge output clock
      .RST					(iserdes_reset_q[i]			        ),                 	// 1-bit input: Active high asynchronous reset
																					// SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
      .SHIFTIN1				(1'b0								),
      .SHIFTIN2				(1'b0								)
   ); 
end   
else begin: gen_8x_cascade
  ISERDESE2 #(
      .DATA_RATE			("DDR"								),          		// DDR, SDR
      .DATA_WIDTH			(8									),          		// Parallel data width (2-8,10,14)
      .DYN_CLKDIV_INV_EN	("FALSE"							),				    // Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
      .DYN_CLK_INV_EN		("FALSE"							),    				// Enable DYNCLKINVSEL inversion (FALSE, TRUE)
																					// INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
      .INIT_Q1				(1'b0								),
      .INIT_Q2				(1'b0								),
      .INIT_Q3				(1'b0								),
      .INIT_Q4				(1'b0								),
      .INTERFACE_TYPE		("NETWORKING"						),   				// MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
      .IOBDELAY				("IFD"								),          		// NONE, BOTH, IBUF, IFD
      .NUM_CE				(2									),          		// Number of clock enables (1,2)
      .OFB_USED				("FALSE"							),          		// Select OFB path (FALSE, TRUE)
      .SERDES_MODE			("MASTER"							),      			// MASTER, SLAVE
																					// SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
      .SRVAL_Q1				(1'b0								),
      .SRVAL_Q2				(1'b0								),
      .SRVAL_Q3				(1'b0								),
      .SRVAL_Q4				(1'b0								)
   )
   ISERDESE2_i_data_inst (
      .O					(									),                  // 1-bit output: Combinatorial output
																					// Q1 - Q8: 1-bit (each) output: Registered data outputs
      .Q1					(data_serdes_i	[i][0]				),
      .Q2					(data_serdes_i	[i][1]				),
      .Q3					(data_serdes_i	[i][2]				),
      .Q4					(data_serdes_i	[i][3]				),
      .Q5					(data_serdes_i	[i][4]				),
      .Q6					(data_serdes_i	[i][5]				),
      .Q7					(data_serdes_i	[i][6]				),
      .Q8					(data_serdes_i	[i][7]				),
																					// SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
      .SHIFTOUT1			(									),
      .SHIFTOUT2			(									),
      .BITSLIP				(s_bitslip_i	[i]					),           		// 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
																					// CLKDIV when asserted (active High). Subsequently, the data seen on the Q1
																					// to Q8 output ports will shift, as in a barrel-shifter operation, one
																					// position every time Bitslip is invoked (DDR operation is different from
																					// SDR).
      .CE1					(1'b1								),			 		// CE1, CE2: 1-bit (each) input: Data register clock enable inputs
      .CE2					(1'b1								),
      .CLKDIVP				(1'b0								),          		// 1-bit input: TBD
																					// Clocks: 1-bit (each) input: ISERDESE2 clock input ports
      .CLK					(clk_ser_i							),                  // 1-bit input: High-speed clock
      .CLKB					(clk_ser_i_n						),                 	// 1-bit input: High-speed secondary clock
      .CLKDIV				(clk_ser_i_div						),             		// 1-bit input: Divided clock
      .OCLK					(1'b0								),                 	// 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
																					// Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
      .DYNCLKDIVSEL			(1'b0								), 					// 1-bit input: Dynamic CLKDIV inversion
      .DYNCLKSEL			(1'b0								), 	     			// 1-bit input: Dynamic CLK/CLKB inversion
																					// Input Data: 1-bit (each) input: ISERDESE2 data input ports
      .D					(1'b0/*data_i		[i]*/			),                 	// 1-bit input: Data input
      .DDLY					(io_data_i	[i]						),                 	// 1-bit input: Serial data from IDELAYE2
      .OFB					(1'b0								),                 	// 1-bit input: Data feedback from OSERDESE2
      .OCLKB				(1'b0								),                 	// 1-bit input: High speed negative edge output clock
      .RST					(iserdes_reset_i[i]			        ),                 	// 1-bit input: Active high asynchronous reset
																					// SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
      .SHIFTIN1				(1'b0								),
      .SHIFTIN2				(1'b0								)
   );


  ISERDESE2 #(
      .DATA_RATE			("DDR"								),          		// DDR, SDR
      .DATA_WIDTH			(8									),          		// Parallel data width (2-8,10,14)
      .DYN_CLKDIV_INV_EN	("FALSE"							), 					// Enable DYNCLKDIVINVSEL inversion (FALSE, TRUE)
      .DYN_CLK_INV_EN		("FALSE"							),    				// Enable DYNCLKINVSEL inversion (FALSE, TRUE)
																					// INIT_Q1 - INIT_Q4: Initial value on the Q outputs (0/1)
      .INIT_Q1				(1'b0								),
      .INIT_Q2				(1'b0								),
      .INIT_Q3				(1'b0								),
      .INIT_Q4				(1'b0								),
      .INTERFACE_TYPE		("NETWORKING"						),   				// MEMORY, MEMORY_DDR3, MEMORY_QDR, NETWORKING, OVERSAMPLE
      .IOBDELAY				("IFD"								),          		// NONE, BOTH, IBUF, IFD
      .NUM_CE				(2									),          		// Number of clock enables (1,2)
      .OFB_USED				("FALSE"							),          		// Select OFB path (FALSE, TRUE)
      .SERDES_MODE			("MASTER"							),      			// MASTER, SLAVE
																					// SRVAL_Q1 - SRVAL_Q4: Q output values when SR is used (0/1)
      .SRVAL_Q1				(1'b0								),
      .SRVAL_Q2				(1'b0								),
      .SRVAL_Q3				(1'b0								),
      .SRVAL_Q4				(1'b0								)
   )
   ISERDESE2_q_data_inst (
      .O					(									),                  // 1-bit output: Combinatorial output
																					// Q1 - Q8: 1-bit (each) output: Registered data outputs
      .Q1					(data_serdes_q	[i][0]				),
      .Q2					(data_serdes_q	[i][1]				),
      .Q3					(data_serdes_q	[i][2]				),
      .Q4					(data_serdes_q	[i][3]				),
      .Q5					(data_serdes_q	[i][4]				),
      .Q6					(data_serdes_q	[i][5]				),
      .Q7					(data_serdes_q	[i][6]				),
      .Q8					(data_serdes_q	[i][7]				),
																					// SHIFTOUT1, SHIFTOUT2: 1-bit (each) output: Data width expansion output ports
      .SHIFTOUT1			(									),
      .SHIFTOUT2			(									),
      .BITSLIP				(s_bitslip_q    [i]					),           		// 1-bit input: The BITSLIP pin performs a Bitslip operation synchronous to
																					// CLKDIV when asserted (active High). Subsequently, the data seen on the Q1
																					// to Q8 output ports will shift, as in a barrel-shifter operation, one
																					// position every time Bitslip is invoked (DDR operation is different from
																					// SDR).
      .CE1					(1'b1								),			 		// CE1, CE2: 1-bit (each) input: Data register clock enable inputs
      .CE2					(1'b1								),
      .CLKDIVP				(1'b0								),          		// 1-bit input: TBD
																					// Clocks: 1-bit (each) input: ISERDESE2 clock input ports
      .CLK					(clk_ser_q							),                  // 1-bit input: High-speed clock
      .CLKB					(clk_ser_q_n						),                 	// 1-bit input: High-speed secondary clock
      .CLKDIV				(clk_ser_q_div						),             		// 1-bit input: Divided clock
      .OCLK					(1'b0								),                 	// 1-bit input: High speed output clock used when INTERFACE_TYPE="MEMORY" 
																					// Dynamic Clock Inversions: 1-bit (each) input: Dynamic clock inversion pins to switch clock polarity
      .DYNCLKDIVSEL			(1'b0								), 					// 1-bit input: Dynamic CLKDIV inversion
      .DYNCLKSEL			(1'b0								), 	     			// 1-bit input: Dynamic CLK/CLKB inversion
																					// Input Data: 1-bit (each) input: ISERDESE2 data input ports
      .D					(1'b0/*data_q		[i]*/			),                 	// 1-bit input: Data input
      .DDLY					(io_data_q	[i]						),                 	// 1-bit input: Serial data from IDELAYE2
      .OFB					(1'b0								),                 	// 1-bit input: Data feedback from OSERDESE2
      .OCLKB				(1'b0								),                 	// 1-bit input: High speed negative edge output clock
      .RST					(iserdes_reset_q[i]			        ),                 	// 1-bit input: Active high asynchronous reset
																					// SHIFTIN1, SHIFTIN2: 1-bit (each) input: Data width expansion input ports
      .SHIFTIN1				(1'b0								),
      .SHIFTIN2				(1'b0								)
   );   
end	  

   xpm_cdc_single 
	#(
      .DEST_SYNC_FF   				(3												),
      .INIT_SYNC_FF                 (1                                              ),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK 				(1												),
      .SRC_INPUT_REG  				(1												) 
    
    ) xpm_cdc_single_bitslip_i (  
      .src_clk  					(SYS_CLK										),
      .src_in   					(BITSIP_I[i]									),
      .dest_clk 					(clk_ser_i_div									),
      .dest_out 					(s_bitslip_i[i]									)
	); 
	
   xpm_cdc_single 
	#(
      .DEST_SYNC_FF   				(3												),
      .INIT_SYNC_FF                 (1                                              ),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK 				(1												),
      .SRC_INPUT_REG  				(1												) 
    
    ) xpm_cdc_single_bitslip_q (  
      .src_clk  					(SYS_CLK										),
      .src_in   					(BITSIP_Q[i]									),
      .dest_clk 					(clk_ser_q_div									),
      .dest_out 					(s_bitslip_q[i]									)
	); 
	
   xpm_cdc_single 
	#(
      .DEST_SYNC_FF   				(3												),
      .INIT_SYNC_FF                 (1                                              ),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK 				(1												),
      .SRC_INPUT_REG  				(1												) 
    
    ) xpm_cdc_single_iserdes_rst_i (  
      .src_clk  					(SYS_CLK										),
      .src_in   					(ISERDES_RESYNC || RST_I						),
      .dest_clk 					(clk_ser_i_div									),
      .dest_out 					(iserdes_reset_i [i]							)
	); 
	
   xpm_cdc_single 
	#(
      .DEST_SYNC_FF   				(3												),
      .INIT_SYNC_FF                 (1                                              ),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK 				(1												),
      .SRC_INPUT_REG  				(1												) 
    
    ) xpm_cdc_single_iserdes_rst_q (  
      .src_clk  					(SYS_CLK										),
      .src_in   					(ISERDES_RESYNC	|| RST_I       					),
      .dest_clk 					(clk_ser_q_div									),
      .dest_out 					(iserdes_reset_q [i]							)
	); 
end   
endgenerate

	/////////////////////////////////////////////////////////////
	// create ADC IN_FIFO 
	/////////////////////////////////////////////////////////////
generate	
if (ISERDES_BITS == 4) begin: gen_4x_cascade_infifo	

    IN_FIFO #(
      .ALMOST_EMPTY_VALUE		(1							),          		// Almost empty offset (1-2)
      .ALMOST_FULL_VALUE		(1							),          		// Almost full offset (1-2)
      .ARRAY_MODE				("ARRAY_MODE_4_X_8"			), 					// ARRAY_MODE_4_X_8, ARRAY_MODE_4_X_4
      .SYNCHRONOUS_MODE			("FALSE"					)       			// Clock synchronous (FALSE)
    )
    IN_FIFO_adc_i_inst (
      // FIFO Status Flags: 1-bit (each) output: Flags and other FIFO status outputs
      .ALMOSTEMPTY				(almostempty_in_fifo_i  [0]	), 					// 1-bit output: Almost empty
      .ALMOSTFULL				(almostfull_in_fifo_i	[0]	),   				// 1-bit output: Almost full
      .EMPTY					(empty_in_fifo_i		[0]	),             		// 1-bit output: Empty
      .FULL						(full_in_fifo_i 		[0]	),               	// 1-bit output: Full
      // Q0-Q9: 8-bit (each) output: FIFO Outputs
      .Q0						(data_in_fifo_i			[0]	),                   // 8-bit output: Channel 0
      .Q1						(data_in_fifo_i			[1]	),                   // 8-bit output: Channel 1
      .Q2						(data_in_fifo_i			[2]	),                   // 8-bit output: Channel 2
      .Q3						(data_in_fifo_i			[3]	),                   // 8-bit output: Channel 3
      .Q4						(data_in_fifo_i			[4]	),                   // 8-bit output: Channel 4
      .Q5						(							),                   // 8-bit output: Channel 5
      .Q6						(							),                   // 8-bit output: Channel 6
      .Q7						(data_in_fifo_i			[5]	),                   // 8-bit output: Channel 7
      .Q8						(data_in_fifo_i			[6] ),                   // 8-bit output: Channel 8
      .Q9						(data_in_fifo_i			[7] ),                   // 8-bit output: Channel 9
      // D0-D9: 4-bit (each) input: FIFO inputs
      .D0						(data_serdes_i			[0]	),                   // 4-bit input: Channel 0
      .D1						(data_serdes_i			[1]	),                   // 4-bit input: Channel 1
      .D2						(data_serdes_i			[2]	),                   // 4-bit input: Channel 2
      .D3						(data_serdes_i			[3]	),                   // 4-bit input: Channel 3
      .D4						(data_serdes_i			[4]	),                   // 4-bit input: Channel 4
      .D5						(8'd0						),                   // 8-bit input: Channel 5
      .D6						(8'd0						),                   // 8-bit input: Channel 6
      .D7						(data_serdes_i			[5]	),                   // 4-bit input: Channel 7
      .D8						(data_serdes_i			[6]	),                   // 4-bit input: Channel 8
      .D9						(data_serdes_i			[7]	),                   // 4-bit input: Channel 9
      // FIFO Control Signals: 1-bit (each) input: Clocks, Resets and Enables
      .RDCLK					(SYS_CLK					),             		 // 1-bit input: Read clock
      .RDEN						(!empty_in_fifo_i	[0]		),               	 // 1-bit input: Read enable
      .RESET					(iserdes_reset_i    [0]  	),            		 // 1-bit input: Reset
      .WRCLK					(clk_ser_i_div				),            		 // 1-bit input: Write clock
      .WREN						(!full_in_fifo_i	[0]		)                	 // 1-bit input: Write enable
   );
   
    IN_FIFO #(
      .ALMOST_EMPTY_VALUE		(1							),          		// Almost empty offset (1-2)
      .ALMOST_FULL_VALUE		(1							),          		// Almost full offset (1-2)
      .ARRAY_MODE				("ARRAY_MODE_4_X_8"			), 					// ARRAY_MODE_4_X_8, ARRAY_MODE_4_X_4
      .SYNCHRONOUS_MODE			("FALSE"					)       			// Clock synchronous (FALSE)
    )
    IN_FIFO_adc_q_inst (
      // FIFO Status Flags: 1-bit (each) output: Flags and other FIFO status outputs
      .ALMOSTEMPTY				(almostempty_in_fifo_q  [0]	), 					// 1-bit output: Almost empty
      .ALMOSTFULL				(almostfull_in_fifo_q	[0]	),   				// 1-bit output: Almost full
      .EMPTY					(empty_in_fifo_q		[0]	),             		// 1-bit output: Empty
      .FULL						(full_in_fifo_q 		[0]	),               	// 1-bit output: Full
      // Q0-Q9: 8-bit (each) output: FIFO Outputs
      .Q0						(data_in_fifo_q			[0]	),                   // 8-bit output: Channel 0
      .Q1						(data_in_fifo_q			[1]	),                   // 8-bit output: Channel 1
      .Q2						(data_in_fifo_q			[2]	),                   // 8-bit output: Channel 2
      .Q3						(data_in_fifo_q			[3]	),                   // 8-bit output: Channel 3
      .Q4						(							),                   // 8-bit output: Channel 4
      .Q5						(							),                   // 8-bit output: Channel 5
      .Q6						(data_in_fifo_q			[4]	),                   // 8-bit output: Channel 6
      .Q7						(data_in_fifo_q			[5]	),                   // 8-bit output: Channel 7
      .Q8						(data_in_fifo_q			[6]								),                   // 8-bit output: Channel 8
      .Q9						(data_in_fifo_q			[7]								),                   // 8-bit output: Channel 9
      // D0-D9: 4-bit (each) input: FIFO inputs
      .D0						(data_serdes_q			[0]	),                   // 4-bit input: Channel 0
      .D1						(data_serdes_q			[1]	),                   // 4-bit input: Channel 1
      .D2						(data_serdes_q			[2]	),                   // 4-bit input: Channel 2
      .D3						(data_serdes_q			[3]	),                   // 4-bit input: Channel 3
      .D4						(data_serdes_q			[4]	),                   // 4-bit input: Channel 4
      .D5						(8'd0						),                   // 8-bit input: Channel 5
      .D6						(8'd0						),                   // 8-bit input: Channel 6
      .D7						(data_serdes_q			[5]	),                   // 4-bit input: Channel 7
      .D8						(data_serdes_q			[6]	),                   // 4-bit input: Channel 8
      .D9						(data_serdes_q			[7]	),                   // 4-bit input: Channel 9
      // FIFO Control Signals: 1-bit (each) input: Clocks, Resets and Enables
      .RDCLK					(SYS_CLK					),             		 // 1-bit input: Read clock
      .RDEN						(!empty_in_fifo_q	[0]		),               	 // 1-bit input: Read enable
      .RESET					(iserdes_reset_q    [0]  	),            		 // 1-bit input: Reset
      .WRCLK					(clk_ser_q_div				),            		 // 1-bit input: Write clock
      .WREN						(!full_in_fifo_q	[0]		)                	 // 1-bit input: Write enable
   );     
end 
else begin:  gen_8x_cascade_infifo	  
    IN_FIFO #(
      .ALMOST_EMPTY_VALUE		(1								),          		// Almost empty offset (1-2)
      .ALMOST_FULL_VALUE		(1								),          		// Almost full offset (1-2)
      .ARRAY_MODE				("ARRAY_MODE_4_X_4"				), 					// ARRAY_MODE_4_X_8, ARRAY_MODE_4_X_4
      .SYNCHRONOUS_MODE			("FALSE"						)       			// Clock synchronous (FALSE)
    )
    IN_FIFO_adc_i0_inst (
      // FIFO Status Flags: 1-bit (each) output: Flags and other FIFO status outputs
      .ALMOSTEMPTY				(almostempty_in_fifo_i  [0]		), 					// 1-bit output: Almost empty
      .ALMOSTFULL				(almostfull_in_fifo_i	[0]		),   				// 1-bit output: Almost full
      .EMPTY					(empty_in_fifo_i		[0]		),             		// 1-bit output: Empty
      .FULL						(full_in_fifo_i 		[0]		),               	// 1-bit output: Full
      // Q0-Q9: 8-bit (each) output: FIFO Outputs
      .Q0						(data_in_fifo_i_ch0	[0]/*[3:0]*/),                   // 8-bit output: Channel 0
      .Q1						(data_in_fifo_i_ch1	[0]/*[7:4]*/),                   // 8-bit output: Channel 1
      .Q2						(data_in_fifo_i_ch0	[1]/*[3:0]*/),                   // 8-bit output: Channel 2
      .Q3						(data_in_fifo_i_ch1	[1]/*[7:4]*/),                   // 8-bit output: Channel 3
      .Q4						(data_in_fifo_i_ch0	[2]/*[3:0]*/),                   // 8-bit output: Channel 4
      .Q5						({data_in_fifo_i_ch1[8][3:0],data_in_fifo_i_ch0[8][3:0]}), // 8-bit output: Channel 5
      .Q6						({data_in_fifo_i_ch1[9][3:0],data_in_fifo_i_ch0[9][3:0]}), // 8-bit output: Channel 6
      .Q7						(data_in_fifo_i_ch1	[2]/*[7:4]*/),                   // 8-bit output: Channel 7
      .Q8						(data_in_fifo_i_ch0	[3]/*[3:0]*/),                   // 8-bit output: Channel 8
      .Q9						(data_in_fifo_i_ch1	[3]/*[7:4]*/),                   // 8-bit output: Channel 9
      // D0-D9: 4-bit (each) input: FIFO inputs
      .D0						(data_serdes_i		[0][3:0]	),                   // 4-bit input: Channel 0
      .D1						(data_serdes_i		[0][7:4]	),                   // 4-bit input: Channel 1
      .D2						(data_serdes_i		[1][3:0]	),                   // 4-bit input: Channel 2
      .D3						(data_serdes_i		[1][7:4]	),                   // 4-bit input: Channel 3
      .D4						(data_serdes_i		[2][3:0]	),                   // 4-bit input: Channel 4
      .D5						({data_serdes_i[8][7:4],data_serdes_i[8][3:0]} 	),   // 8-bit input: Channel 5
      .D6						({data_serdes_i[9][7:4],data_serdes_i[9][3:0]}	),   // 8-bit input: Channel 6
      .D7						(data_serdes_i		[2][7:4]	),                   // 4-bit input: Channel 7
      .D8						(data_serdes_i		[3][3:0]	),                   // 4-bit input: Channel 8
      .D9						(data_serdes_i		[3][7:4]	),                   // 4-bit input: Channel 9
      // FIFO Control Signals: 1-bit (each) input: Clocks, Resets and Enables
      .RDCLK					(SYS_CLK						),             		 // 1-bit input: Read clock
      .RDEN						(!empty_in_fifo_i	[0]	
								&!empty_in_fifo_i	[1]
								&!empty_in_fifo_q	[0]
								&!empty_in_fifo_q	[1]
								& SYS_WR_EN_ADC					),               	 // 1-bit input: Read enable
      .RESET					(iserdes_reset_i    [0]    		),            		 // 1-bit input: Reset
      .WRCLK					(clk_ser_i_div					),            		 // 1-bit input: Write clock
      .WREN						(!full_in_fifo_i	[0]			
								& wr_en_infifo_i    [0]			)                	 // 1-bit input: Write enable
   );
   
    IN_FIFO #(
      .ALMOST_EMPTY_VALUE		(1								),          		// Almost empty offset (1-2)
      .ALMOST_FULL_VALUE		(1								),          		// Almost full offset (1-2)
      .ARRAY_MODE				("ARRAY_MODE_4_X_4"				), 					// ARRAY_MODE_4_X_8, ARRAY_MODE_4_X_4
      .SYNCHRONOUS_MODE			("FALSE"						)       			// Clock synchronous (FALSE)
    )
    IN_FIFO_adc_i1_inst (
      // FIFO Status Flags: 1-bit (each) output: Flags and other FIFO status outputs
      .ALMOSTEMPTY				(almostempty_in_fifo_i  [1]		), 					// 1-bit output: Almost empty
      .ALMOSTFULL				(almostfull_in_fifo_i	[1]		),   				// 1-bit output: Almost full
      .EMPTY					(empty_in_fifo_i		[1]		),             		// 1-bit output: Empty
      .FULL						(full_in_fifo_i 		[1]		),               	// 1-bit output: Full
      // Q0-Q9: 8-bit (each) output: FIFO Outputs
      .Q0						(data_in_fifo_i_ch0	[4]/*[3:0]*/),                   // 8-bit output: Channel 0
      .Q1						(data_in_fifo_i_ch1	[4]/*[7:4]*/),                   // 8-bit output: Channel 1
      .Q2						(data_in_fifo_i_ch0	[5]/*[3:0]*/),                   // 8-bit output: Channel 2
      .Q3						(data_in_fifo_i_ch1	[5]/*[7:4]*/),                   // 8-bit output: Channel 3
      .Q4						(data_in_fifo_i_ch0	[6]/*[3:0]*/),                   // 8-bit output: Channel 4
      .Q5						({data_in_fifo_i_ch1[10][3:0],data_in_fifo_i_ch0[10][3:0]}), // 8-bit output: Channel 5
      .Q6						({data_in_fifo_i_ch1[11][3:0],data_in_fifo_i_ch0[11][3:0]}), // 8-bit output: Channel 6
      .Q7						(data_in_fifo_i_ch1	[6]/*[7:4]*/),                   // 8-bit output: Channel 7
      .Q8						(data_in_fifo_i_ch0	[7]/*[3:0]*/),                   // 8-bit output: Channel 8
      .Q9						(data_in_fifo_i_ch1	[7]/*[7:4]*/),                   // 8-bit output: Channel 9
      // D0-D9: 4-bit (each) input: FIFO inputs
      .D0						(data_serdes_i		[4][3:0]	),                   // 4-bit input: Channel 0
      .D1						(data_serdes_i		[4][7:4]	),                   // 4-bit input: Channel 1
      .D2						(data_serdes_i		[5][3:0]	),                   // 4-bit input: Channel 2
      .D3						(data_serdes_i		[5][7:4]	),                   // 4-bit input: Channel 3
      .D4						(data_serdes_i		[6][3:0]	),                   // 4-bit input: Channel 4
      .D5						({data_serdes_i[10][7:4],data_serdes_i[10][3:0]}),   // 8-bit input: Channel 5
      .D6						({data_serdes_i[11][7:4],data_serdes_i[11][3:0]}),   // 8-bit input: Channel 6
      .D7						(data_serdes_i		[6][7:4]	),                   // 4-bit input: Channel 7
      .D8						(data_serdes_i		[7][3:0]	),                   // 4-bit input: Channel 8
      .D9						(data_serdes_i		[7][7:4]	),                   // 4-bit input: Channel 9
      // FIFO Control Signals: 1-bit (each) input: Clocks, Resets and Enables
      .RDCLK					(SYS_CLK						),             		 // 1-bit input: Read clock
      .RDEN						(!empty_in_fifo_i	[0]	
								&!empty_in_fifo_i	[1]
								&!empty_in_fifo_q	[0]
								&!empty_in_fifo_q	[1]
								& SYS_WR_EN_ADC					),               	 // 1-bit input: Read enable
      .RESET					(iserdes_reset_i    [0]    		),            		 // 1-bit input: Reset
      .WRCLK					(clk_ser_i_div					),            		 // 1-bit input: Write clock
      .WREN						(!full_in_fifo_i	[1]			
								& wr_en_infifo_i    [1]			)                	 // 1-bit input: Write enable
   );  
   
    IN_FIFO #(
      .ALMOST_EMPTY_VALUE		(1								),          		// Almost empty offset (1-2)
      .ALMOST_FULL_VALUE		(1								),          		// Almost full offset (1-2)
      .ARRAY_MODE				("ARRAY_MODE_4_X_4"				), 					// ARRAY_MODE_4_X_8, ARRAY_MODE_4_X_4
      .SYNCHRONOUS_MODE			("FALSE"						)       			// Clock synchronous (FALSE)
    )
    IN_FIFO_adc_q0_inst (
      // FIFO Status Flags: 1-bit (each) output: Flags and other FIFO status outputs
      .ALMOSTEMPTY				(almostempty_in_fifo_q  [0]		), 					// 1-bit output: Almost empty
      .ALMOSTFULL				(almostfull_in_fifo_q	[0]		),   				// 1-bit output: Almost full
      .EMPTY					(empty_in_fifo_q		[0]		),             		// 1-bit output: Empty
      .FULL						(full_in_fifo_q 		[0]		),               	// 1-bit output: Full
      // Q0-Q9: 8-bit (each) output: FIFO Outputs
      .Q0						(data_in_fifo_q_ch0	[0]/*[3:0]*/),                   // 8-bit output: Channel 0
      .Q1						(data_in_fifo_q_ch1	[0]/*[7:4]*/),                   // 8-bit output: Channel 1
      .Q2						(data_in_fifo_q_ch0	[1]/*[3:0]*/),                   // 8-bit output: Channel 2
      .Q3						(data_in_fifo_q_ch1	[1]/*[7:4]*/),                   // 8-bit output: Channel 3
      .Q4						(data_in_fifo_q_ch0	[2]/*[3:0]*/),                   // 8-bit output: Channel 4
      .Q5						({data_in_fifo_q_ch1[8][3:0],data_in_fifo_q_ch0[8][3:0]}), // 8-bit output: Channel 5
      .Q6						({data_in_fifo_q_ch1[9][3:0],data_in_fifo_q_ch0[9][3:0]}), // 8-bit output: Channel 6
      .Q7						(data_in_fifo_q_ch1	[2]/*[7:4]*/),                   // 8-bit output: Channel 7
      .Q8						(data_in_fifo_q_ch0	[3]/*[3:0]*/),                   // 8-bit output: Channel 8
      .Q9						(data_in_fifo_q_ch1	[3]/*[7:4]*/),                   // 8-bit output: Channel 9
      // D0-D9: 4-bit (each) input: FIFO inputs
      .D0						(data_serdes_q		[0][3:0]	),                   // 4-bit input: Channel 0
      .D1						(data_serdes_q		[0][7:4]	),                   // 4-bit input: Channel 1
      .D2						(data_serdes_q		[1][3:0]	),                   // 4-bit input: Channel 2
      .D3						(data_serdes_q		[1][7:4]	),                   // 4-bit input: Channel 3
      .D4						(data_serdes_q		[2][3:0]	),                   // 4-bit input: Channel 4
      .D5						({data_serdes_q[8][7:4],data_serdes_q[8][3:0]} 	),   // 8-bit input: Channel 5
      .D6						({data_serdes_q[9][7:4],data_serdes_q[9][3:0]}	),   // 8-bit input: Channel 6
      .D7						(data_serdes_q		[2][7:4]	),                   // 4-bit input: Channel 7
      .D8						(data_serdes_q		[3][3:0]	),                   // 4-bit input: Channel 8
      .D9						(data_serdes_q		[3][7:4]	),                   // 4-bit input: Channel 9
      // FIFO Control Signals: 1-bit (each) input: Clocks, Resets and Enables
      .RDCLK					(SYS_CLK						),             		 // 1-bit input: Read clock
      .RDEN						(!empty_in_fifo_i	[0]	
								&!empty_in_fifo_i	[1]
								&!empty_in_fifo_q	[0]
								&!empty_in_fifo_q	[1]
								& SYS_WR_EN_ADC					),               	 // 1-bit input: Read enable
      .RESET					(iserdes_reset_q    [0]    		),            		 // 1-bit input: Reset
      .WRCLK					(clk_ser_q_div					),            		 // 1-bit input: Write clock
      .WREN						(!full_in_fifo_q	[0]			
								& wr_en_infifo_q    [0]			)                	 // 1-bit input: Write enable
   );  

    IN_FIFO #(
      .ALMOST_EMPTY_VALUE		(1								),          		// Almost empty offset (1-2)
      .ALMOST_FULL_VALUE		(1								),          		// Almost full offset (1-2)
      .ARRAY_MODE				("ARRAY_MODE_4_X_4"				), 					// ARRAY_MODE_4_X_8, ARRAY_MODE_4_X_4
      .SYNCHRONOUS_MODE			("FALSE"						)       			// Clock synchronous (FALSE)
    )
    IN_FIFO_adc_q1_inst (
      // FIFO Status Flags: 1-bit (each) output: Flags and other FIFO status outputs
      .ALMOSTEMPTY				(almostempty_in_fifo_q  [1]		), 					// 1-bit output: Almost empty
      .ALMOSTFULL				(almostfull_in_fifo_q	[1]		),   				// 1-bit output: Almost full
      .EMPTY					(empty_in_fifo_q		[1]		),             		// 1-bit output: Empty
      .FULL						(full_in_fifo_q 		[1]		),               	// 1-bit output: Full
      // Q0-Q9: 8-bit (each) output: FIFO Outputs
      .Q0						(data_in_fifo_q_ch0	[4]/*[3:0]*/),                   // 8-bit output: Channel 0
      .Q1						(data_in_fifo_q_ch1	[4]/*[7:4]*/),                   // 8-bit output: Channel 1
      .Q2						(data_in_fifo_q_ch0	[5]/*[3:0]*/),                   // 8-bit output: Channel 2
      .Q3						(data_in_fifo_q_ch1	[5]/*[7:4]*/),                   // 8-bit output: Channel 3
      .Q4						(data_in_fifo_q_ch0	[6]/*[3:0]*/),                   // 8-bit output: Channel 4
      .Q5						({data_in_fifo_q_ch1[10][3:0],data_in_fifo_q_ch0[10][3:0]}), // 8-bit output: Channel 5
      .Q6						({data_in_fifo_q_ch1[11][3:0],data_in_fifo_q_ch0[11][3:0]}), // 8-bit output: Channel 6
      .Q7						(data_in_fifo_q_ch1	[6]/*[7:4]*/),                   // 8-bit output: Channel 7
      .Q8						(data_in_fifo_q_ch0	[7]/*[3:0]*/),                   // 8-bit output: Channel 8
      .Q9						(data_in_fifo_q_ch1	[7]/*[7:4]*/),                   // 8-bit output: Channel 9
      // D0-D9: 4-bit (each) input: FIFO inputs
      .D0						(data_serdes_q		[4][3:0]	),                   // 4-bit input: Channel 0
      .D1						(data_serdes_q		[4][7:4]	),                   // 4-bit input: Channel 1
      .D2						(data_serdes_q		[5][3:0]	),                   // 4-bit input: Channel 2
      .D3						(data_serdes_q		[5][7:4]	),                   // 4-bit input: Channel 3
      .D4						(data_serdes_q		[6][3:0]	),                   // 4-bit input: Channel 4
      .D5						({data_serdes_q[10][7:4],data_serdes_q[10][3:0]} 	),  // 8-bit input: Channel 5
      .D6						({data_serdes_q[11][7:4],data_serdes_q[11][3:0]}	),  // 8-bit input: Channel 6
      .D7						(data_serdes_q		[6][7:4]	),                   // 4-bit input: Channel 7
      .D8						(data_serdes_q		[7][3:0]	),                   // 4-bit input: Channel 8
      .D9						(data_serdes_q		[7][7:4]	),                   // 4-bit input: Channel 9
      // FIFO Control Signals: 1-bit (each) input: Clocks, Resets and Enables
      .RDCLK					(SYS_CLK						),             		 // 1-bit input: Read clock
      .RDEN						(!empty_in_fifo_i	[0]	
								&!empty_in_fifo_i	[1]
								&!empty_in_fifo_q	[0]
								&!empty_in_fifo_q	[1]
								& SYS_WR_EN_ADC					),               	 // 1-bit input: Read enable
      .RESET					(iserdes_reset_q    [0]    		),            		 // 1-bit input: Reset
      .WRCLK					(clk_ser_q_div					),            		 // 1-bit input: Write clock
      .WREN						(!full_in_fifo_q	[1]			
								& wr_en_infifo_q  	[1]			)                	 // 1-bit input: Write enable
   );     
   
 for (i=0;i<PORTS;i=i+1) begin  
	assign data_in_fifo_i[i]	= 	{data_in_fifo_i_ch1[i][3:0],data_in_fifo_i_ch0[i][3:0]};   
	assign data_in_fifo_q[i]	= 	{data_in_fifo_q_ch1[i][3:0],data_in_fifo_q_ch0[i][3:0]};   
 end   
 
for (i=0;i<2;i=i+1) begin 
   xpm_cdc_single 
	#(
      .DEST_SYNC_FF   				(3												),
      .INIT_SYNC_FF                 (1                                              ),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK 				(1												),
      .SRC_INPUT_REG  				(1												) 
    
    ) xpm_cdc_single_wr_en_infifo_i (  
      .src_clk  					(SYS_CLK										),
      .src_in   					(SYS_WR_EN_ADC			      					),
      .dest_clk 					(clk_ser_i_div									),
      .dest_out 					(wr_en_infifo_i  [i]							)
	); 
	
   xpm_cdc_single 
	#(
      .DEST_SYNC_FF   				(3												),
      .INIT_SYNC_FF                 (1                                              ),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK 				(1												),
      .SRC_INPUT_REG  				(1												) 
    
    ) xpm_cdc_single_wr_en_infifo_q (  
      .src_clk  					(SYS_CLK										),
      .src_in   					(SYS_WR_EN_ADC			      					),
      .dest_clk 					(clk_ser_q_div									),
      .dest_out 					(wr_en_infifo_q  [i]							)
	); 	
end


end   
endgenerate	  

////////////////////////////////////////////////////////////////////////////
// Data_out Remapping
////////////////////////////////////////////////////////////////////////////
generate	
	for (i=0;i<TDATA_WIDTH;i=i+1) begin : remapping_iserdes_data_infifo	
			for (j=0;j<PORTS;j=j+1) begin : remapping_data_serdes_i_group
				assign data_serdes_i_group[i][j] = data_in_fifo_i[j][i]; 	
				assign data_serdes_q_group[i][j] = data_in_fifo_q[j][i]; 
			end
	end	
endgenerate


generate	
	for (i=0;i<TDATA_WIDTH;i=i+1) begin : remapping_iserdes_data	
		assign DATA_O_I[i] = data_serdes_i_group[7-i]; 
		assign DATA_O_Q[i] = data_serdes_q_group[7-i]; 			
	end	
endgenerate

generate	
	for (i=0;i<PORTS;i=i+1) begin : remapping_iserdes_data_cal	
		
		always@(posedge SYS_CLK)
		if(RST_I) begin
			DATA_SERDES_I_CAL [i] <= 8'hff;
            DATA_SERDES_Q_CAL [i] <= 8'hff;
		end
		else begin
			DATA_SERDES_I_CAL [i] <= data_in_fifo_i[i];	//data_serdes_i[i];
            DATA_SERDES_Q_CAL [i] <= data_in_fifo_q[i];	//data_serdes_q[i];
		end 		
	end	
endgenerate


////////////////////////////////////////////////////////////////////////////
// ChipScope
////////////////////////////////////////////////////////////////////////////
generate
	if (USE_CHIPSCOPE) begin: gen_chipscope

		(* TIG = "TRUE" *) (* DONT_TOUCH = "TRUE" 	*) (* mark_debug = "TRUE" *) reg  [(PORTS-1):0][(8-1):0]				cs_data_serdes_i			;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "TRUE" 	*) (* mark_debug = "TRUE" *) reg  [(PORTS-1):0][(8-1):0]				cs_data_serdes_q			;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "TRUE" 	*) (* mark_debug = "TRUE" *) reg  [(TDATA_WIDTH-1):0][(PORTS-1):0]		cs_data_out_i				;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "TRUE" 	*) (* mark_debug = "TRUE" *) reg  [(TDATA_WIDTH-1):0][(PORTS-1):0]		cs_data_out_q				;		
		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(2-1):0]								cs_empty_in_fifo_i			;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(2-1):0]								cs_full_in_fifo_i			;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(2-1):0]								cs_empty_in_fifo_q			;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(2-1):0]								cs_full_in_fifo_q			;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg              							cs_SYS_WR_EN				;	
		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  										cs_ISERDES_RESYNC			;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(2-1):0]								cs_almostempty_in_fifo_i	;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(2-1):0]								cs_almostfull_in_fifo_i		;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(2-1):0]								cs_almostempty_in_fifo_q	;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(2-1):0]								cs_almostfull_in_fifo_q		;		
		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(PORTS-1):0]							cs_iserdes_reset_i	        ;
		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(PORTS-1):0]							cs_iserdes_reset_q  		;		

		for (i=0;i<PORTS;i=i+1) begin : cs_data_serdes_debug
						always @(posedge dbg_chipscope_clk) begin
								cs_data_serdes_i[i] <= data_serdes_i[i];
								cs_data_serdes_q[i] <= data_serdes_q[i];
								
								cs_iserdes_reset_i[i] <= iserdes_reset_i[i];
								cs_iserdes_reset_q[i] <= iserdes_reset_q[i];
						end
		end	

        for (i=0;i<TDATA_WIDTH;i=i+1) begin : cs_remapping_iserdes_data	
						always @(posedge SYS_CLK) begin
								cs_data_out_i[i] <= data_serdes_i_group[7-i];
								cs_data_out_q[i] <= data_serdes_q_group[7-i]; 
						end		
		end	

		always @(posedge SYS_CLK) begin
			cs_empty_in_fifo_i[0]    <= empty_in_fifo_i[0] 					;
			cs_full_in_fifo_i [0]    <= full_in_fifo_i[0] 					;
			cs_empty_in_fifo_i[1]    <= empty_in_fifo_i[1] 					;
			cs_full_in_fifo_i [1]    <= full_in_fifo_i[1] 					;
			
			cs_empty_in_fifo_q[0]    <= empty_in_fifo_q[0] 					;
			cs_full_in_fifo_q [0]    <= full_in_fifo_q[0] 					;
			cs_empty_in_fifo_q[1]    <= empty_in_fifo_q[1]					;
			cs_full_in_fifo_q [1]    <= full_in_fifo_q[1]					;    

			cs_SYS_WR_EN			 <= SYS_WR_EN_ADC						;
			cs_ISERDES_RESYNC		 <= ISERDES_RESYNC						;
			
			cs_almostempty_in_fifo_i  	[0]	<= almostempty_in_fifo_i  	[0]	;			
			cs_almostfull_in_fifo_i		[0]	<= almostfull_in_fifo_i		[0]	;		
			cs_almostempty_in_fifo_i  	[1]	<= almostempty_in_fifo_i  	[1]	;			
			cs_almostfull_in_fifo_i		[1]	<= almostfull_in_fifo_i		[1]	;				
			
			cs_almostempty_in_fifo_q  	[0]	<= almostempty_in_fifo_q  	[0]	;			
			cs_almostfull_in_fifo_q		[0]	<= almostfull_in_fifo_q		[0]	;		
			cs_almostempty_in_fifo_q  	[1]	<= almostempty_in_fifo_q  	[1]	;			
			cs_almostfull_in_fifo_q		[1]	<= almostfull_in_fifo_q		[1]	;				

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
