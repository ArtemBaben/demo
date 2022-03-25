`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// Device 		:   bpac_059
// Description  :	Module ADC Data_alignment	
//
// Hystory		: 	
//
/////////////////////////////////////////////////////////////////////////////////
*/

module adc_data_alignment_mult
#(
parameter			CHANNELS				= 8		,
parameter 			PORTS_ADC				= 2		,	// 4  
parameter			QUANTITY_FMC			= 4		,
parameter 			DATA_WIDTH_ADC			= 12	,  	// 4 
parameter			DATA_WIDTH_ADC_CV		= 16		

)
(

input	wire								rst				,
input	wire								clk				,
input	wire								clk_inside		,

input	wire								en_align		,
output	wire		[(CHANNELS-1):0]		align_cmpl		,


input	wire		[(CHANNELS-1):0]		mux_qi			,
input	wire		[(CHANNELS-1):0]		adc_dvalid_i	,
input	wire		[(CHANNELS-1):0][127:0]	adc_i_data_i	,
input	wire		[(CHANNELS-1):0][127:0]	adc_q_data_i	,

output	wire		[(CHANNELS-1):0]		adc_dvalid_o	,
output	wire		[(CHANNELS-1):0][127:0]	adc_i_data_o	,
output	wire		[(CHANNELS-1):0][127:0]	adc_q_data_o	,


output	wire		[(CHANNELS-1):0][3:0]	data_ddelay_i	,
output	wire		[(CHANNELS-1):0][3:0]	data_ddelay_q	

);


////////////////////////////////////////////////////////////////
// Wires and regs
////////////////////////////////////////////////////////////////

wire [(QUANTITY_FMC*PORTS_ADC-1):0]										sh_rd_en_fifo_i							;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										s_full_i_sh								;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										s_empty_i_sh							;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										s_valid_sh_i							;
wire [(QUANTITY_FMC*PORTS_ADC-1):0][(2*DATA_WIDTH_ADC_CV-1):0]			data_i_sh								;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										sh_rd_en_fifo_q							;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										s_full_q_sh								;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										s_empty_q_sh							;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										s_valid_sh_q							;
wire [(QUANTITY_FMC*PORTS_ADC-1):0][(2*DATA_WIDTH_ADC_CV-1):0]			data_q_sh								;

wire [(QUANTITY_FMC*PORTS_ADC-1):0]										s_full_i_sh_o							;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										s_empty_i_sh_o							;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										s_full_q_sh_o							;
wire [(QUANTITY_FMC*PORTS_ADC-1):0]										s_empty_q_sh_o							;


wire [(CHANNELS-1):0]													adc_i_sh_dvalid							;
wire [(CHANNELS-1):0]													adc_q_sh_dvalid							;
wire [(CHANNELS-1):0][127:0]											adc_i_sh_data							;
wire [(CHANNELS-1):0][127:0]											adc_q_sh_data							;

genvar																	i										;




////////////////////////////////////////////////////////////////
// Generate input_fifo channels
////////////////////////////////////////////////////////////////
	generate
		for (i=0;i<PORTS_ADC*QUANTITY_FMC;i=i+1) begin : fifo_shifter
		
		fifo_shifter 
		fifo_shifter_inst_i
		(
			.rst 			(rst				),		//: IN STD_LOGIC;
			.wr_clk			(clk				),		//: IN STD_LOGIC;	
			.rd_clk			(clk_inside			),	
			.din 			(adc_i_data_i	[i]	),		//: IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			.wr_en 			(adc_dvalid_i	[i]	
							&&
							!s_full_i_sh	[i]	),		//: IN STD_LOGIC;	
			.rd_en 			(sh_rd_en_fifo_i[i] 
							&&
							!s_empty_i_sh	[i]	),		//: IN STD_LOGIC;
			.dout 			(data_i_sh		[i]	),		//: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			.full 			(s_full_i_sh	[i]	),		//: OUT STD_LOGIC;
			.empty 			(s_empty_i_sh	[i]	),		//: OUT STD_LOGIC;
			.valid 			(s_valid_sh_i	[i]	),		//: OUT STD_LOGIC
			.wr_rst_busy	(					),		//: OUT STD_LOGIC
			.rd_rst_busy	(					)		//: OUT STD_LOGIC
		);
		
		fifo_shifter 
		fifo_shifter_inst_q
		(
			.rst 			(rst				),		//: IN STD_LOGIC;
			.wr_clk			(clk				),		//: IN STD_LOGIC;	
			.rd_clk			(clk_inside			),		
			.din 			(adc_q_data_i	[i]	),		//: IN STD_LOGIC_VECTOR(127 DOWNTO 0);
			.wr_en 			(adc_dvalid_i	[i]	
							&&
							!s_full_q_sh	[i]	),		//: IN STD_LOGIC;	
			.rd_en 			(sh_rd_en_fifo_q[i] 
							&&
							!s_empty_q_sh	[i]	),		//: IN STD_LOGIC;
			.dout 			(data_q_sh		[i]	),		//: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			.full 			(s_full_q_sh	[i]	),		//: OUT STD_LOGIC;
			.empty 			(s_empty_q_sh	[i]	),		//: OUT STD_LOGIC;
			.valid 			(s_valid_sh_q	[i]	),		//: OUT STD_LOGIC
			.wr_rst_busy	(					),		//: OUT STD_LOGIC
			.rd_rst_busy	(					)		//: OUT STD_LOGIC
		);
		
		end 
	endgenerate

	
////////////////////////////////////////////////////////////////
// Generate data alignment channels
////////////////////////////////////////////////////////////////
	generate
		for(i=0;i<CHANNELS;i=i+1)
		begin
			adc_data_alignment
			adc_data_alignment_inst
			(
				.rst			(rst				),
				.clk			(clk_inside			),
				.en_align		(en_align			),
				.align_cmpl		(align_cmpl		[i]	),
				.adc_dvalid		(s_valid_sh_i	[i] 
				                 &&
				                 s_valid_sh_q	[i] ),		
				.adc_i_data		(data_i_sh		[i]	),
				.adc_q_data		(data_q_sh		[i]	),
				.rd_en_fifo_i	(sh_rd_en_fifo_i[i]	),       				
				.rd_en_fifo_q	(sh_rd_en_fifo_q[i]	),
				.mux_qi			(mux_qi			[i]	),
				.ddelay_i		(data_ddelay_i	[i]	),
				.ddelay_q		(data_ddelay_q	[i]	)
			);
		end
	endgenerate

	
	
////////////////////////////////////////////////////////////////
// Generate output_fifo channels
////////////////////////////////////////////////////////////////	
	generate
		for (i=0;i<PORTS_ADC*QUANTITY_FMC;i=i+1) begin : fifo_shifter_out
		
		fifo_shifter32x128 
		fifo_shifter_out_i
		(
			.rst 			(rst				),		//: IN STD_LOGIC;
			.wr_clk			(clk_inside			),		//: IN STD_LOGIC;	
			.rd_clk			(clk				),	
			.din 			(data_i_sh		[i]	),		//: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			.wr_en 			(s_valid_sh_i	[i]		
							&&
							!s_full_i_sh_o	[i]	),		//: IN STD_LOGIC;	
			.rd_en 			(!s_empty_i_sh_o[i]	),		//: IN STD_LOGIC;
			.dout 			(adc_i_sh_data	[i]	),		//: OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			.full 			(s_full_i_sh_o	[i]	),		//: OUT STD_LOGIC;
			.empty 			(s_empty_i_sh_o	[i]	),		//: OUT STD_LOGIC;
			.valid 			(adc_i_sh_dvalid[i]	),		//: OUT STD_LOGIC
			.wr_rst_busy	(					),		//: OUT STD_LOGIC
			.rd_rst_busy	(					)		//: OUT STD_LOGIC
		);
		
		
		fifo_shifter32x128 
		fifo_shifter_out_q
		(
			.rst 			(rst				),		//: IN STD_LOGIC;
			.wr_clk			(clk_inside			),		//: IN STD_LOGIC;	
			.rd_clk			(clk				),	
			.din 			(data_q_sh		[i]	),		//: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			.wr_en 			(s_valid_sh_q	[i]	
							&&
							!s_full_q_sh_o	[i]	),		//: IN STD_LOGIC;	
			.rd_en 			(!s_empty_q_sh_o[i]	),		//: IN STD_LOGIC;
			.dout 			(adc_q_sh_data	[i]	),		//: OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
			.full 			(s_full_q_sh_o	[i]	),		//: OUT STD_LOGIC;
			.empty 			(s_empty_q_sh_o	[i]	),		//: OUT STD_LOGIC;
			.valid 			(adc_q_sh_dvalid[i]	),		//: OUT STD_LOGIC
			.wr_rst_busy	(					),		//: OUT STD_LOGIC
			.rd_rst_busy	(					)		//: OUT STD_LOGIC
		);
		
		end 
	endgenerate


////////////////////////////////////////////////////////////////
// Generate output ports
////////////////////////////////////////////////////////////////	
	generate
		for (i=0;i<PORTS_ADC*QUANTITY_FMC;i=i+1) begin : fifo_signal_output
			assign adc_dvalid_o[i]	= adc_q_sh_dvalid[i] && adc_i_sh_dvalid[i]	;
			assign adc_i_data_o[i]	= adc_i_sh_data	 [i]						;
			assign adc_q_data_o[i]	= adc_q_sh_data	 [i]						;	
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
