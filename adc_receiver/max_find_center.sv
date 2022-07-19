////////////////////////////////////////////////////////////////////
// find_zone_adc_line
// Author: Babenko Artem
////////////////////////////////////////////////////////////////////
module find_zone_adc_line
	# (
		parameter	PORTS 		= 32,
		parameter	DATA_WIDTH 	= 16 
	
	)				 
	(
		input										rst					,
		input										clk					,
		input  [(PORTS -1):0][20:0]	  				IDATA				,     	 
		input										IDAV				,
		output reg  	     [15:0 ]				MAX_VALUE			,	
		output reg			 [4:0  ]				MAX_VALUE_INDEX		,	
		output reg		  	     					MAX_DAV				,
		input  [15:0			  ]					MAX_CMP_VALUE							
		
	);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam IDLE 				= 8'b00000001;
localparam FIND_START  			= 8'b00000010;
localparam FIND_END				= 8'b00000100;
localparam SHR_VALUE_0	    	= 8'b00001000;
localparam SHR_VALUE_1	    	= 8'b00010000;
localparam SHR_VALUE_2	    	= 8'b00100000;
localparam LOAD_MAX				= 8'b01000000;
localparam END_PROCESS			= 8'b10000000;
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
genvar								i				;
reg			[7:0 ]					states			;	
reg									i_dav_reg		;
reg			[(PORTS -1):0][20:0]	i_data_reg		;
reg 		[7:0 ]					cnt_find		;
reg 		[20:0]					t_start			;
reg 		[20:0]					t_end			;

reg 		[4:0 ]					max_index_reg	;
reg 		[15:0]					max_value_reg	;

reg 		[4:0 ]					max_index_reg0	;
reg 		[4:0 ]					max_index_reg1	;



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Input ports
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
generate 	
for (i=0;i<PORTS;i=i+1) begin :input_regs 
	
	always@(posedge clk)
	if(rst)begin
		i_dav_reg	     <= 1'b0			;
		i_data_reg[i]	 <= 21'd0; 
	end
		else begin
			i_dav_reg	  <= IDAV		;		
			if(IDAV) 
			i_data_reg[i] <= IDATA[i]	;
			else ;
	end
end
endgenerate	


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Main automat
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
	always@(posedge clk)
	begin
		if(rst)	begin 
			states 						<= IDLE;
			cnt_find					<= 8'd0;
			
			MAX_DAV						<= 1'b0;
			MAX_VALUE_INDEX				<= 5'd0;
			MAX_VALUE					<= 16'd0;
			
			
			t_start						<= 21'd0;
			t_end						<= 21'd0;
			
			max_index_reg				<= 5'd0	;
            max_value_reg				<= 16'd0;
		end	
		else 	
		(* FSM_ENCODING="ONE_HOT", SAFE_IMPLEMENTATION="YES", SAFE_RECOVERY_STATE="IDLE" *)
		case(states)
			IDLE: begin
				if(i_dav_reg) states <= FIND_START; else states <= IDLE; 
				cnt_find			 <= 8'd0;		
			end
		
			FIND_START: begin
			
				MAX_DAV				<= 1'b0		 ;	
				cnt_find			<= cnt_find+1;		
			
				if(i_data_reg[cnt_find]		[15:0] > MAX_CMP_VALUE &&
				   i_data_reg[cnt_find+1]	[15:0] > MAX_CMP_VALUE &&	
				   i_data_reg[cnt_find+2]	[15:0] > MAX_CMP_VALUE &&
				   i_data_reg[cnt_find+3]	[15:0] > MAX_CMP_VALUE 					   
				) begin
					t_start <= i_data_reg[cnt_find]; 
					states  <= FIND_END;
				end
				else begin
				   if (cnt_find == 28) 
						states  <= LOAD_MAX		;
				   else 
						states  <= FIND_START	;
					
				end		
			
			end
				
			FIND_END: begin
				cnt_find			<= cnt_find+1;		
			
				if((i_data_reg[cnt_find]	[15:0] < MAX_CMP_VALUE &&
				   i_data_reg[cnt_find+1]	[15:0] < MAX_CMP_VALUE &&	
				   i_data_reg[cnt_find+2]	[15:0] < MAX_CMP_VALUE &&
				   i_data_reg[cnt_find+3]	[15:0] < MAX_CMP_VALUE) ||
				   (cnt_find == 28)
				) begin
					t_end	 <= i_data_reg[cnt_find]; 
					states   <= SHR_VALUE_0;
				end
				else begin
					states  <= FIND_END;
				end		
			
			end


			SHR_VALUE_0: begin
			// Center window value
					max_index_reg0	<= (t_end[20:16] - t_start[20:16]) 			;
					max_value_reg	<= t_start[15:0]							; 
					
					states 			<= SHR_VALUE_1				;						
			end

			SHR_VALUE_1: begin
			// Center window value
					max_index_reg1	<= max_index_reg0>>>1						;
					max_value_reg	<= t_start[15:0]							; 
					states 			<= SHR_VALUE_2								;						
			end			
			
			SHR_VALUE_2: begin
			// Center window value
					max_index_reg	<= t_start[20:16]+max_index_reg1			;
					max_value_reg	<= t_start[15:0]							; 
					states 			<= LOAD_MAX									;						
			end			

			
			LOAD_MAX: begin
					{MAX_VALUE_INDEX,MAX_VALUE} <= {max_index_reg, max_value_reg}	;			
					 MAX_DAV					<= 1'b1								;	
					states 						<= END_PROCESS						;					 
			end
			
			END_PROCESS:
					begin
						MAX_DAV					<= 1'b1								;	
						states 					<= IDLE								;	

					end		
			default:	
				states 		<= IDLE;
		endcase
	end	
endmodule 

