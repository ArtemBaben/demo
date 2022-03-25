`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// Device 		:   bpac_059	
// Description  :	Module create parallel CLK for ADC 	
//
/////////////////////////////////////////////////////////////////////////////////
*/
 
module clock_adc
#(
parameter 			PORTS_ADC						= 8,
parameter			BUFR_DIVIDE						= "4", 
parameter           IDELAY_USED                     = "NO",
parameter           DDELAY_IDELAY_FIXED             = 5,
parameter			USE_CHIPSCOPE					= 0						
) 
(
input	wire		[(PORTS_ADC-1):0]				CLK_P_I		,
input	wire      	[(PORTS_ADC-1):0]				CLK_N_I		,
input	wire										RST_I		,
output	wire		[(PORTS_ADC-1):0]				CLK_O		,
input	wire		[(PORTS_ADC-1):0]				BUFMR_CE_OE	,
output	wire		[(PORTS_ADC-1):0]				CLK_BUFR_O  ,

input	wire										dbg_chipscope_clk,
output	wire		[(PORTS_ADC-1):0]				dbg_bufr_clk_bus		
);

genvar													i		        ;
/*(* KEEP = "TRUE" *)*/ wire[(PORTS_ADC-1):0]			clk_i	        ;
wire				[(PORTS_ADC-1):0]					bufmrce_clk_o	;
wire				[(PORTS_ADC-1):0]					bufio_clk_o     ;
wire				[(PORTS_ADC-1):0]					bufr_clk_o      ;
wire                [(PORTS_ADC-1):0]                   clk_in_int_delay;


generate
for (i=0;i<PORTS_ADC;i=i+1) begin

   IBUFDS #(
      .DIFF_TERM	("TRUE"			),    	// Differential Termination
      .IBUF_LOW_PWR	("FALSE"		),    	// Low power="TRUE", Highest performance="FALSE" 
      .IOSTANDARD	("LVDS"			)     	// Specify the input I/O standard
   ) IBUFDS_inst (
      .O			(clk_i	[i]		),  	// Buffer output
      .I			(CLK_P_I[i]		),  	// Diff_p buffer input (connect directly to top-level port)
      .IB			(CLK_N_I[i]		) 		// Diff_n buffer input (connect directly to top-level port)
   );

if(IDELAY_USED == "YES")
begin

  // delay the input clock
      (* IODELAY_GROUP = "adc_group" *)
      IDELAYE2
         # (
            .CINVCTRL_SEL           ("FALSE"),            // TRUE, FALSE
            .DELAY_SRC              ("IDATAIN"),        // IDATAIN, DATAIN
            .HIGH_PERFORMANCE_MODE  ("FALSE"),             // TRUE, FALSE
            .IDELAY_TYPE            ("FIXED"),          // FIXED, VARIABLE, or VAR_LOADABLE
            .IDELAY_VALUE           (DDELAY_IDELAY_FIXED[i]),                // 0 to 31
            .REFCLK_FREQUENCY       (200.0),
            .PIPE_SEL               ("FALSE"),
            .SIGNAL_PATTERN         ("CLOCK"))           // CLOCK, DATA
         idelaye2_clk
           (
            .DATAOUT                (clk_in_int_delay[i]),  // Delayed clock
            .DATAIN                 (1'b0),              // Data from FPGA logic
            .C                      (1'b0),
            .CE                     (1'b0),
            .INC                    (1'b0),
            .IDATAIN                (clk_i	[i] ),
            .LD                     (RST_I      ),
            .LDPIPEEN               (1'b0),
            .REGRST                 (1'b0),
            .CNTVALUEIN             (5'b00000),
            .CNTVALUEOUT            (),
            .CINVCTRL               (1'b0)
         );
end
else begin
        assign clk_in_int_delay[i] = clk_i	[i] ;			

end
   
   BUFIO BUFIO_inst (
      .O			(bufio_clk_o	 [i]), 		// 1-bit output: Clock output (connect to I/O clock loads).
      .I			(clk_in_int_delay[i])  		// 1-bit input: Clock input (connect to an IBUF or BUFMR).
   );
 
   BUFR #(
      .BUFR_DIVIDE	(BUFR_DIVIDE	),		// Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
      .SIM_DEVICE	("7SERIES"		) 		// Must be set to "7SERIES" 
   )
   BUFR_inst (
      .O			(bufr_clk_o	[i]		                            ), 		// 1-bit output: Clock output port
      .CE			(BUFMR_CE_OE[i]                                 ), 		// 1-bit input: Active high, clock enable (Divided modes only)
      .CLR			(RST_I			                                ), 		// 1-bit input: Active high, asynchronous clear (Divided modes only)
      .I			(clk_in_int_delay[i]                            )  		// 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
   );

assign CLK_O        [i] = bufio_clk_o	[i]		 ;	
assign CLK_BUFR_O   [i]	= bufr_clk_o	[i]      ;

end
endgenerate



	xpm_cdc_array_single #(
	  .DEST_SYNC_FF   				(3												), 
	  .SIM_ASSERT_CHK 				(0												), 
	  .SRC_INPUT_REG  				(0												), 
	  .WIDTH          				(PORTS_ADC										)  
	) xpm_cdc_array_bufr_registers (

	  .src_clk  					(1'b0         									),  
	  .src_in   					(bufr_clk_o										),
	  .dest_clk 					(dbg_chipscope_clk								), 
	  .dest_out 					(dbg_bufr_clk_bus								)
	);	
	




////////////////////////////////////////////////////////////////////////////
// ChipScope
////////////////////////////////////////////////////////////////////////////
generate
	if (USE_CHIPSCOPE) begin: gen_chipscope

		(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(PORTS_ADC-1):0]							cs_bufr_clk_o	        ;
		//(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(PORTS_ADC-1):0]							cs_BUFMR_CE_OE  		;
		//(* TIG = "TRUE" *) (* DONT_TOUCH = "FALSE" 	*) (* mark_debug = "TRUE" *) reg  [(PORTS_ADC-1):0]							cs_RST_I          		;			

		
		for (i=0;i<PORTS_ADC;i=i+1) begin : cs_bufio_signal

						always @(posedge dbg_chipscope_clk) begin
								cs_bufr_clk_o [i]  <= bufr_clk_o[i]  ;
								//cs_BUFMR_CE_OE [i] <= BUFMR_CE_OE[i];
								//cs_RST_I           <= RST_I         ; 
						end
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
