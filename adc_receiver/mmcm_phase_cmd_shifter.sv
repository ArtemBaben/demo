`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// 
// Description  :	MMCM shift phase events
//
//
//
//
/////////////////////////////////////////////////////////////////////////////////
*/
module mmcm_phase_shifter
(
// system_interface
input	wire					 						clk_i						,
input	wire											rst_i						,

input	wire											clk_sys_cmp					,
input	wire											rst_sys						,
output	wire											result_mmcm_bufr_cmp		,
input	wire		[15:0]								dbg_bufr_clk_bus			,	
		
input   wire											ctrl_psen					,				
input   wire											ctrl_psincdec				,
output  wire											ctrl_psdone_event			,	

output	wire		[15:0]								cnt_psdone					,		
input  	wire											clr_ev_psdone				,			
output  wire											psclk						,					
output  wire											psen						,				
output  wire											psincdec					,				
input   wire											psdone					
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wires and regs
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire													main_channel_rise 			;  
wire													main_channel_fall			;
reg			[5:0]										states						;
reg			[15:0]										reg_full0					;
reg			[15:0]										reg_full1					;
reg			[15:0]										reg_full2					;
reg														rslt0						;
reg														rslt1						;
reg														rslt2						;
reg														result						;
wire													rst_sys_xpm					;
reg			[7:0]										cnt_pause					;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Localparam
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam	IDLE		=	2**0;
localparam	SAVE_R1		=	2**1;
localparam	SAVE_R2		=	2**2;
localparam	RSLT_CMP	=	2**3;
localparam	SOLUTION	=	2**4;
localparam	WAIT_PAUSE	=	2**5;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MMCM PS CONTROL
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign psclk 	= clk_i				;
assign psincdec	= ctrl_psincdec		;	  

detect_edge
	detect_edge_psen
    (
		.clk					(clk_i								),
		.reset					(rst_i								),
		.sig					(ctrl_psen							),
		.rise					(psen								),
		.fall					(									)
    );

event_counter
    #(
    .PORTS     	(1				),
    .CNT_W     	(16				),
    .EVNT_W    	(1				)	
    )
	event_counter_ps_done
    (
    .clk		(clk_i			),
    .reset_n	(!rst_i			),
    .evnt		(psdone			),
    .cnt		(cnt_psdone		),	
    .clr        (clr_ev_psdone	)
    );

	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//MMCM PS COMPARATOR
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

xpm_cdc_single 
	#(
		.DEST_SYNC_FF   			(3							),
		.SIM_ASSERT_CHK 			(0							),
		.SRC_INPUT_REG  			(1							) 
    
    ) xpm_cdc_single_rst_sys (  
		.src_clk  					(clk_i		 				),
		.src_in   					(rst_sys					),
		.dest_clk 					(clk_sys_cmp				),
		.dest_out 					(rst_sys_xpm				)
	); 	


detect_edge
	detect_edge_bufr_clk
    (
		.clk						(clk_sys_cmp				),
		.reset						(rst_sys_xpm				),
		.sig						(dbg_bufr_clk_bus[0]		), // input main channel
		.rise						(main_channel_rise			),
		.fall						(main_channel_fall			)
    );
	
	
always@(posedge clk_sys_cmp)
begin
if(rst_sys_xpm)
	begin
		states 		<= WAIT_PAUSE	;
		cnt_pause	<= 8'd0			;
		reg_full0	<= 16'd0		;	
		reg_full1   <= 16'd0		;
		reg_full2   <= 16'd0		;
		rslt0		<= 1'b0			;
		rslt1       <= 1'b0			;
		rslt2       <= 1'b0			;
		result      <= 1'b0			;
	end
else begin
	case(states)
	
		WAIT_PAUSE: begin
			
			cnt_pause <= cnt_pause + 1;	
			
			if(cnt_pause <= 16) 
				states <= WAIT_PAUSE;
			else 
				states <= IDLE;
		end 	
		
		IDLE: begin
			if(main_channel_rise) states <=  SAVE_R1;	
			else 				  states <=  IDLE	;  
			
			reg_full0 	<= dbg_bufr_clk_bus			; 	// 1
		end
			
		SAVE_R1: begin
			states 		<=  SAVE_R2					;	
			reg_full1 	<=  dbg_bufr_clk_bus		; 	// 0	
		end	
			
		
		SAVE_R2: begin
			states 		<=  RSLT_CMP				;	
			reg_full2 	<=  dbg_bufr_clk_bus		; 	// 0	
		end		
		
		RSLT_CMP: begin
			rslt0		<= 	&reg_full0				;
			rslt1		<= 	&reg_full1				;
			rslt2		<= 	~(|reg_full2)			;
			states		<=  SOLUTION				;
		end			
	
		SOLUTION: begin
			result		<= 	rslt0 && rslt1 && rslt2	;
			states		<= 	SOLUTION				;
		end	
		
		default:states		<= 	IDLE				; 	
	endcase
end 
end	

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//OUTPUT__PORTS
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

xpm_cdc_single 
	#(
		.DEST_SYNC_FF   			(3							),
		.SIM_ASSERT_CHK 			(0							),
		.SRC_INPUT_REG  			(1							) 
    
    ) xpm_cdc_single_result (  
		.src_clk  					(clk_sys_cmp 				),
		.src_in   					(result						),
		.dest_clk 					(clk_i						),
		.dest_out 					(result_mmcm_bufr_cmp		)
	); 	


//assign result_mmcm_bufr_cmp	= result;	



endmodule

`default_nettype wire
