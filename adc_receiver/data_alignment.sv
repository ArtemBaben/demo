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

module adc_data_alignment
#(
parameter											ADC_PORTS = 2	
)
(

input   wire										rst			,
input	wire										clk			,
	
input	wire										en_align	,
output	reg 										align_cmpl	,	

input	wire										adc_dvalid	,
input	wire		[(ADC_PORTS-1):0][15:0]			adc_i_data	,
input	wire		[(ADC_PORTS-1):0][15:0]			adc_q_data	,

output  reg											rd_en_fifo_i,       				
output  reg											rd_en_fifo_q,

input	wire										mux_qi		,
	
output	wire		[3:0]							ddelay_i	,
output	wire		[3:0]							ddelay_q	

);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam	IDLE			= 0		;
localparam	SAVE_DATA0		= 1		;
localparam  SAVE_DATA1		= 2		;
localparam  SAVE_DATA2		= 3		;
localparam  SAVE_DATA3		= 4		;
localparam	COMPARE_R0		= 5		;
localparam	COMPARE_R1		= 6		;
localparam	COMPARE_R2		= 7		;
localparam	COMPARE_R3		= 8		;
localparam	COMPARE_R4		= 9		;
localparam	COMPARE_R5		= 10	;                             
localparam	COMPARE_R6		= 11	;
localparam	COMPARE_R7		= 12	;

                              
localparam  CHK_RESULT		= 13	;
                              
localparam	END_ALIGN		= 14	;
localparam  DELAY_ADD		= 15	;





///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wires and regs
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg [7:0] [15:0]	 		adc_data_i_r		;
reg [7:0] [15:0]	 		adc_data_q_r		;

reg [4:0]					states				;
reg [7:0]					result_cmp			;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Alignment process
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

always@(posedge clk)
	begin 
		if(rst) begin
			states 				<= IDLE	;
			adc_data_i_r		<= 'd0	;
			adc_data_q_r		<= 'd0	;
			result_cmp			<= 'd0  ;
			rd_en_fifo_i		<= 1'b0	;	
			rd_en_fifo_q		<= 1'b0	;	
			
			adc_data_i_r		<= {128{1'b0}};
			adc_data_q_r		<= {128{1'b0}};
			
			align_cmpl			<= 1'b0 ;
			
		end
		else begin
			case(states)
				IDLE: begin
				
					rd_en_fifo_i		<= 1'b1	;	
					rd_en_fifo_q		<= 1'b1	;					
				
					if(en_align) 
						begin
							states <= SAVE_DATA0;
						end
					else	
						begin
							states   <= IDLE	   ;				
						end					
				end		
			
				SAVE_DATA0: begin
					if(adc_dvalid) begin
							adc_data_i_r[0]		<= adc_i_data[0]	;
							adc_data_q_r[0]		<= adc_q_data[0]	;
							adc_data_i_r[1]		<= adc_i_data[1]	;
							adc_data_q_r[1]		<= adc_q_data[1]	;							
							states 				<= SAVE_DATA1	;
					end
					else begin
							states 				<= SAVE_DATA0	;

					end 		
							rd_en_fifo_i		<= 1'b1	;	
							rd_en_fifo_q		<= 1'b1	;
							
										
				end					

				SAVE_DATA1: begin
					if(adc_dvalid) begin		
							adc_data_i_r[2]		<= adc_i_data[0]	;
							adc_data_q_r[2]		<= adc_q_data[0]	;
							adc_data_i_r[3]		<= adc_i_data[1]	;
							adc_data_q_r[3]		<= adc_q_data[1]	;	
							states 				<= SAVE_DATA2	;
					end
					else
						begin		
							states 				<= SAVE_DATA1	;
						end
				
							
				end			
				
				SAVE_DATA2: begin
					if(adc_dvalid) begin		
							adc_data_i_r[4]		<= adc_i_data[0]	;
							adc_data_q_r[4]		<= adc_q_data[0]	;
							adc_data_i_r[5]		<= adc_i_data[1]	;
							adc_data_q_r[5]		<= adc_q_data[1]	;	
							states 				<= SAVE_DATA3	;
					end
					else
						begin		
							states 				<= SAVE_DATA2	;
						end
				
							
				end		

				SAVE_DATA3: begin
					if(adc_dvalid) begin		
							adc_data_i_r[6]		<= adc_i_data[0]	;
							adc_data_q_r[6]		<= adc_q_data[0]	;
							adc_data_i_r[7]		<= adc_i_data[1]	;
							adc_data_q_r[7]		<= adc_q_data[1]	;	
							states 				<= COMPARE_R0		;
					end
					else
						begin		
							states 				<= SAVE_DATA3	;
						end
				
							
				end	
				
			
				COMPARE_R0: begin
					if(	(adc_data_i_r[0] == 16'hffef && adc_data_q_r[0] == 16'hfff7) ||
						(adc_data_i_r[0] == 16'h0010 && adc_data_q_r[0] == 16'h0008) )
						result_cmp[0] <= 1'b1; 
					else
						result_cmp[0] <= 1'b0; 
					
					states			<= COMPARE_R1	;
				end		

				COMPARE_R1: begin
					if(	(adc_data_i_r[1] == 16'hffef && adc_data_q_r[1] == 16'hfff7) ||
						(adc_data_i_r[1] == 16'h0010 && adc_data_q_r[1] == 16'h0008) )
						result_cmp[1] <= 1'b1; 
					else
						result_cmp[1] <= 1'b0; 
					
					states			<= COMPARE_R2	;
				end	

				COMPARE_R2: begin
					if(	(adc_data_i_r[2] == 16'hffef && adc_data_q_r[2] == 16'hfff7) ||
						(adc_data_i_r[2] == 16'h0010 && adc_data_q_r[2] == 16'h0008) )
						result_cmp[2] <= 1'b1; 
					else
						result_cmp[2] <= 1'b0; 
					
					states			<= COMPARE_R3	;
				end	

				COMPARE_R3: begin
					if(	(adc_data_i_r[3] == 16'hffef && adc_data_q_r[3] == 16'hfff7) ||
						(adc_data_i_r[3] == 16'h0010 && adc_data_q_r[3] == 16'h0008) )
						result_cmp[3] <= 1'b1; 
					else
						result_cmp[3] <= 1'b0; 
					
					states			<= COMPARE_R4	;
				end	

				COMPARE_R4: begin
					if(	(adc_data_i_r[4] == 16'hffef && adc_data_q_r[4] == 16'hfff7) ||
						(adc_data_i_r[4] == 16'h0010 && adc_data_q_r[4] == 16'h0008) )
						result_cmp[4] <= 1'b1; 
					else
						result_cmp[4] <= 1'b0; 
					
					states			<= COMPARE_R5	;
				end					
				
				COMPARE_R5: begin
					if(	(adc_data_i_r[5] == 16'hffef && adc_data_q_r[5] == 16'hfff7) ||
						(adc_data_i_r[5] == 16'h0010 && adc_data_q_r[5] == 16'h0008) )
						result_cmp[5] <= 1'b1; 
					else
						result_cmp[5] <= 1'b0; 
					
					states			<= COMPARE_R6	;
				end							
				
				
				COMPARE_R6: begin
					if(	(adc_data_i_r[6] == 16'hffef && adc_data_q_r[6] == 16'hfff7) ||
						(adc_data_i_r[6] == 16'h0010 && adc_data_q_r[6] == 16'h0008) )
						result_cmp[6] <= 1'b1; 
					else
						result_cmp[6] <= 1'b0; 
					
					states			<= COMPARE_R7	;
				end					

				
				COMPARE_R7: begin
					if(	(adc_data_i_r[7] == 16'hffef && adc_data_q_r[7] == 16'hfff7) ||
						(adc_data_i_r[7] == 16'h0010 && adc_data_q_r[7] == 16'h0008) )
						result_cmp[7] <= 1'b1; 
					else
						result_cmp[7] <= 1'b0; 
					
					states			<= CHK_RESULT	;
				end	

			
				CHK_RESULT: begin
					if(&result_cmp) 	
						states <= END_ALIGN;	
					else 
						states <= DELAY_ADD;						
				end	

				DELAY_ADD: begin
				
				if(mux_qi)
					begin
						rd_en_fifo_i		<= 1'b1			;	
						rd_en_fifo_q		<= 1'b0			;						
					end
				else 	
					begin
						rd_en_fifo_i		<= 1'b0			;	
						rd_en_fifo_q		<= 1'b1			;						
					end 
					
				states 				<= IDLE	;
				
				end					
				
				END_ALIGN: begin

					align_cmpl			<= 1'b1			;	
					states 				<= END_ALIGN	;
				
				end					
			
				default: states 		<= IDLE; 
			endcase			
		end
	end


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Counter ddelay
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
reg [3:0] counter_ddelay_i;	
reg [3:0] counter_ddelay_q;		
	
always@(posedge clk)
	begin 
		if(rst) begin
			counter_ddelay_i	<= 4'd0;
			counter_ddelay_q	<= 4'd0;			
		end
	else
		begin	
			if(~rd_en_fifo_i)	counter_ddelay_i	<= counter_ddelay_i + 1;
			if(~rd_en_fifo_q)	counter_ddelay_q	<= counter_ddelay_q + 1;			
		end
	end


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//output ports
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
assign  ddelay_i	=	counter_ddelay_i	;
assign  ddelay_q	=	counter_ddelay_q	;


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
