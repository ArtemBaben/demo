`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// Device 		:   bpac_059
// Description  :	Idelay calibration module
//
/////////////////////////////////////////////////////////////////////////////////
*/

module idelay_calibration_adc
#(
parameter										TIME_LENGTH 		= 8096,
parameter										ENABLE_IDELAY_CALIB	= 1,
parameter	[4:0][7:0]							PATTERN_DATA		= { 8'h52, 	8'h94, 	8'ha5, 	8'h29, 	8'h4a},			
parameter	[4:0][7:0]							PATTERN_DATA_INV	= {	8'had,	8'h6b,	8'h5a,	8'hd6,	8'hb5},
parameter										USE_DEBUG			= 1																						
)
(
// system_interface
input	wire					 				clk_i			,
input	wire									rst_i			,
input	wire									en_calib_idelay	,	
output  reg										calibration_done_i,	
output  reg										calibration_not_done_i,
output  reg										calibration_done_q,
output  reg										calibration_not_done_q,


input	wire									USE_INV_I			,
input	wire									USE_INV_Q			,


// iodelay_group
input	wire		[4:0] 						i_dl_cnt_val_o	,
output  reg 									i_dl_ce	        ,
output	reg			[4:0]						i_dl_cnt_in	    ,
output	wire 									i_dl_in	        ,
output	reg										i_dl_load_val	,
				
input	wire		[4:0] 						q_dl_cnt_val_o	,
output  reg 									q_dl_ce	        ,
output	reg			[4:0]						q_dl_cnt_in	    ,
output	wire 									q_dl_in	        ,
output	reg										q_dl_load_val	,
				
// data 				
input	wire		[7:0]						data_serdes_i	,
input	wire		[7:0]						data_serdes_q	,
output	wire		[31:0][23:0]				o_idelay_value_counter_good_i,
output	wire		[31:0][23:0]				o_idelay_value_counter_good_q,		
output	wire		               				o_idelay_value_dav	

);





///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
localparam IDLE 				= 6'b000001;
localparam LOAD_VAR 			= 6'b000010;
localparam CALC_MAX				= 6'b000100;
localparam END_CALIB_PROCESS	= 6'b001000;
localparam LOAD_MAX_IDELAY		= 6'b010000;
localparam WAIT_MAX_COUNT		= 6'b100000;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wires and regs
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
genvar											i								;
reg					[15:0]						cnt_time						;
reg					[5:0 ]						states							;
reg												reset_time_counter				;
reg					[7:0]						data_serdes_i_r					;
reg					[7:0]						data_serdes_q_r					;
reg					[15:0]						cnt_good_data_i					;
reg					[15:0]                      cnt_good_data_q     			;
reg					[31:0][20:0]				idelay_value_counter_good_i		;
reg					[31:0][20:0]				idelay_value_counter_good_q		;
reg												max_detector_en					;
wire                [15:0]                      max_value_i		                ;
wire                [15:0]                      max_value_q		                ;
reg												max_count_begin					;
wire											rise_max_count_begin			;
wire				[4:0]						max_value_i_index				;
wire				[4:0]						max_value_q_index				;
wire											s_max_dav_i						;
wire											s_max_dav_q						;

generate 
if (ENABLE_IDELAY_CALIB) begin: generate_auto_idelay_calib_algorithm
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Calibration_algorithm
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Time counter
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always@(posedge clk_i)
	begin
		if(rst_i) begin
		idelay_value_counter_good_i		<= {32{21'd0}}	;
		idelay_value_counter_good_q		<= {32{21'd0}}	;
		end
		else begin
		if(en_calib_idelay) begin
			if(cnt_time == (TIME_LENGTH-1)) begin
					case({i_dl_cnt_in, q_dl_cnt_in})
					({5'd0,5'd0}):	 begin
										idelay_value_counter_good_i[0] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[0] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end                                                 
					({5'd1,5'd1}):	 begin                                               
										idelay_value_counter_good_i[1] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[1] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end				                                 
					({5'd2,5'd2}):	 begin                                               
										idelay_value_counter_good_i[2] <= {i_dl_cnt_in, cnt_good_data_i};
										idelay_value_counter_good_q[2] <= {q_dl_cnt_in, cnt_good_data_q};
									end							                     
					({5'd3,5'd3}):	 begin                                               
										idelay_value_counter_good_i[3] <= {i_dl_cnt_in, cnt_good_data_i};
										idelay_value_counter_good_q[3] <= {q_dl_cnt_in, cnt_good_data_q};
									end		                                         
					({5'd4,5'd4}):	 begin                                               
										idelay_value_counter_good_i[4] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[4] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end		                                         
					({5'd5,5'd5}):	 begin                                               
										idelay_value_counter_good_i[5] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[5] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end		                                         
					({5'd6,5'd6}):	 begin                                               
										idelay_value_counter_good_i[6] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[6] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end		                                         
					({5'd7,5'd7}):	 begin                                               
										idelay_value_counter_good_i[7] <= {i_dl_cnt_in, cnt_good_data_i};
										idelay_value_counter_good_q[7] <= {q_dl_cnt_in, cnt_good_data_q};
									end		                                         
					({5'd8,5'd8}):	 begin                                               
										idelay_value_counter_good_i[8] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[8] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end
					({5'd9,5'd9}):	 begin                                               
										idelay_value_counter_good_i[9] <= {i_dl_cnt_in, cnt_good_data_i};
										idelay_value_counter_good_q[9] <= {q_dl_cnt_in, cnt_good_data_q};
									end
					({5'd10,5'd10}): begin                                               
										idelay_value_counter_good_i[10] <= {i_dl_cnt_in, cnt_good_data_i};
										idelay_value_counter_good_q[10] <= {q_dl_cnt_in, cnt_good_data_q};
									end
					({5'd11,5'd11}): begin                                               
										idelay_value_counter_good_i[11] <= {i_dl_cnt_in, cnt_good_data_i};
										idelay_value_counter_good_q[11] <= {q_dl_cnt_in, cnt_good_data_q};
									end                                            
					({5'd12,5'd12}): begin                                                
										idelay_value_counter_good_i[12] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[12] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end                                            
					({5'd13,5'd13}): begin                                                
										idelay_value_counter_good_i[13] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[13] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end
					({5'd14,5'd14}): begin                                               
										idelay_value_counter_good_i[14] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[14] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end                                            
					({5'd15,5'd15}): begin                                                
										idelay_value_counter_good_i[15] <= {i_dl_cnt_in, cnt_good_data_i};
										idelay_value_counter_good_q[15] <= {q_dl_cnt_in, cnt_good_data_q};
									end                                            
					({5'd16,5'd16}): begin                                                
										idelay_value_counter_good_i[16] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[16] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end                                            
					({5'd17,5'd17}): begin                                                
										idelay_value_counter_good_i[17] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[17] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end                                            
					({5'd18,5'd18}): begin                                                
										idelay_value_counter_good_i[18] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[18] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end                                            
					({5'd19,5'd19}): begin                                                
										idelay_value_counter_good_i[19] <= {i_dl_cnt_in, cnt_good_data_i};
										idelay_value_counter_good_q[19] <= {q_dl_cnt_in, cnt_good_data_q};
									end                                            
					({5'd20,5'd20}): begin                                                
										idelay_value_counter_good_i[20] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[20] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end	                                           
					({5'd21,5'd21}): begin                                                
										idelay_value_counter_good_i[21] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[21] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end	                                           
					({5'd22,5'd22}): begin                                                
										idelay_value_counter_good_i[22] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[22] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end	                                           
					({5'd23,5'd23}): begin                                                
										idelay_value_counter_good_i[23] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[23] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end	                                           
					({5'd24,5'd24}): begin                                                
										idelay_value_counter_good_i[24] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[24] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end	                                           
					({5'd25,5'd25}): begin                                                
										idelay_value_counter_good_i[25] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[25] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end	                                           
					({5'd26,5'd26}): begin                                                
										idelay_value_counter_good_i[26] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[26] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end	                                           
					({5'd27,5'd27}): begin                                                
										idelay_value_counter_good_i[27] <= {i_dl_cnt_in, cnt_good_data_i};
										idelay_value_counter_good_q[27] <= {q_dl_cnt_in, cnt_good_data_q};
									end	                                           
					({5'd28,5'd28}): begin                                                
										idelay_value_counter_good_i[28] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[28] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end	                                           
					({5'd29,5'd29}): begin                                                
										idelay_value_counter_good_i[29] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[29] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end								               
					({5'd30,5'd30}): begin                                                
										idelay_value_counter_good_i[30] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[30] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end                                            
					({5'd31,5'd31}): begin                                                
										idelay_value_counter_good_i[31] <= {i_dl_cnt_in, cnt_good_data_i}; 
										idelay_value_counter_good_q[31] <= {q_dl_cnt_in, cnt_good_data_q}; 
									end
					default:		begin
	                                	idelay_value_counter_good_i		<= {32{21'd0}}	;
			                            idelay_value_counter_good_q		<= {32{21'd0}}	;
									end 
									
					endcase
				end		 			
		end	
		else begin
			idelay_value_counter_good_i		<= {32{21'd0}}	;
			idelay_value_counter_good_q		<= {32{21'd0}}	;
		end
		end
	end		
	

	// cnt_time_process
	always@(posedge clk_i)
	begin: cnt_time_process
		if(rst_i) begin
			cnt_time	<= 16'd0;
		end
		else begin 
				if(en_calib_idelay) begin
					if(reset_time_counter) cnt_time <= 16'd0; else cnt_time <= cnt_time + 1;
				end
				else
					cnt_time 						<= 16'd0;
			end
		end
		
	// max_detector_process
	always@(posedge clk_i)
	begin: max_detector_process
		if(rst_i) begin
			max_detector_en	<= 1'b0;
		end
		else begin 
				if(en_calib_idelay) begin
					if(i_dl_cnt_in == 31) max_detector_en <= 1'b1; 
				end
				else
					max_detector_en	<= 1'b0;
			end
	end
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// IDELAY setup
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	always@(posedge clk_i)
	begin
		if(rst_i)	begin 
			states 						<= IDLE;
			q_dl_ce						<= 1'b0;
			i_dl_ce						<= 1'b0;
			i_dl_load_val				<= 1'b0;
			q_dl_load_val				<= 1'b0;		
			q_dl_cnt_in					<= 5'd0;
			i_dl_cnt_in             	<= 5'd0;		
			reset_time_counter			<= 1'b0;
			max_count_begin				<= 1'b0;
			calibration_done_i			<= 1'b0;
			calibration_not_done_i		<= 1'b0;
			calibration_done_q			<= 1'b0;
			calibration_not_done_q		<= 1'b0;
		end	
		else 	
		(* FSM_ENCODING="ONE_HOT", SAFE_IMPLEMENTATION="YES", SAFE_RECOVERY_STATE="IDLE" *)
		case(states)
			IDLE: begin
				if(cnt_time == TIME_LENGTH) states <= LOAD_VAR; else     
				// Pins
				i_dl_load_val			<= 1'b0;
				q_dl_load_val			<= 1'b0;
				reset_time_counter		<= 1'b0;
				max_count_begin			<= 1'b0;
				calibration_done_i		<= 1'b0;
				calibration_not_done_i	<= 1'b0;
				calibration_done_q		<= 1'b0;
				calibration_not_done_q	<= 1'b0;
			end
		
			LOAD_VAR: begin
				// Pins
				i_dl_load_val			<= 1'b1;
				q_dl_load_val			<= 1'b1;
				reset_time_counter		<= 1'b1;
				q_dl_cnt_in				<= q_dl_cnt_in+1;
				i_dl_cnt_in             <= i_dl_cnt_in+1;
				if(max_detector_en		  ) begin reset_time_counter <= 1'b1;  states <= CALC_MAX; end else  begin states <= IDLE; end 			
				//states 					<= IDLE;
			end
				
			CALC_MAX: begin
				max_count_begin 		<= 1'b1;
				states					<= WAIT_MAX_COUNT; 
			end


			WAIT_MAX_COUNT: begin
				if(s_max_dav_q && s_max_dav_i) 
					states 					<= LOAD_MAX_IDELAY;
				else
					states 					<= WAIT_MAX_COUNT;
			end


			
			LOAD_MAX_IDELAY: begin
				// Pins
				i_dl_load_val			<= 1'b1;
				q_dl_load_val			<= 1'b1;
				i_dl_cnt_in				<= max_value_i_index;
				q_dl_cnt_in             <= max_value_q_index;
				states 					<= END_CALIB_PROCESS;
	
			end
			
			END_CALIB_PROCESS: begin
				i_dl_load_val			<= 1'b0;
				q_dl_load_val			<= 1'b0;
				q_dl_cnt_in				<= 5'd0;
				i_dl_cnt_in            	<= 5'd0;	

				
				max_count_begin 		<= 1'b0;		
			
				if(!max_detector_en) 			
				states 					<= IDLE;
				else 	
				states 					<= END_CALIB_PROCESS;
				
				if(max_value_i > TIME_LENGTH/6)
						begin
							calibration_done_i		<= 1'b1;
							calibration_not_done_i	<= 1'b0;
						end	
				else 
						begin
							calibration_done_i		<= 1'b0;
							calibration_not_done_i	<= 1'b1;				
						end
			
				if(max_value_q > TIME_LENGTH/6)
						begin
							calibration_done_q		<= 1'b1;
							calibration_not_done_q	<= 1'b0;
						end	
				else 
						begin
							calibration_done_q		<= 1'b0;
							calibration_not_done_q	<= 1'b1;				
						end			
			end
	
			default:	
				states 		<= IDLE;
		endcase
	end	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Input data registers
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	always@(posedge clk_i)
	begin
		if(rst_i) begin 
			data_serdes_i_r 			<= 8'd0			;
			data_serdes_q_r 			<= 8'd0			;	
		end
		else begin
			data_serdes_i_r				<= data_serdes_i;	
			data_serdes_q_r				<= data_serdes_q;
		end
	end	


	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Strobe pulse data pattern
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	reg [3:0] cnt_strobe_pulse_pattern_data		;
	reg 	  strobe_pulse_pattern_data			;
	reg       begin_store_data                  ;
	
	always@(posedge clk_i)
	begin
		if(rst_i) begin 
			cnt_strobe_pulse_pattern_data 	<= 4'd0;
			strobe_pulse_pattern_data		<= 1'b0;			
		end
		else begin
			if(begin_store_data					 ) begin
				strobe_pulse_pattern_data 	 <= 1'b1;
				cnt_strobe_pulse_pattern_data<= 4'd1; 
			end	
			else begin
				if(cnt_strobe_pulse_pattern_data == 4) begin
					strobe_pulse_pattern_data 	 <= 1'b1; 
					cnt_strobe_pulse_pattern_data<= 4'd0;
				end			
				else begin
					strobe_pulse_pattern_data	 <= 1'b0; 	
					cnt_strobe_pulse_pattern_data<=cnt_strobe_pulse_pattern_data+1;						
				end			
			end
		end
	end		
	
	reg [15:0] cnt_strbs							;
	reg [7:0]  first_data_i                         ;
	reg [7:0]  first_data_q                         ;
		
	always@(posedge clk_i)
	begin
		if(rst_i) begin 
			cnt_strbs						<= 16'd0;
			begin_store_data 				<= 1'b0;
		end
		else begin
			cnt_strbs <= cnt_strbs + 1;	
			if(reset_time_counter) cnt_strbs <= 16'd0;
			if(cnt_strbs == 0) begin_store_data <= 1'b1; else begin_store_data <= 1'b0; 			
		end
	end		
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Calibration_process
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	always@(posedge clk_i)
	begin: calib_idelay
	if(rst_i) begin
			cnt_good_data_i 		<=	16'd0	;
			cnt_good_data_q 		<=	16'd0	;
	end
	else begin
		if(en_calib_idelay) begin
			if(reset_time_counter) begin
				cnt_good_data_i 	<= 	16'd0	;
				cnt_good_data_q 	<= 	16'd0	;		
			end
			else begin
				if(strobe_pulse_pattern_data) begin
					if(first_data_i == data_serdes_i_r) cnt_good_data_i 	<= 	cnt_good_data_i+1; else ;
					if(first_data_q == data_serdes_q_r) cnt_good_data_q 	<= 	cnt_good_data_q+1; else ;				
				end
			end
		end
		end
	end
	
always@(posedge clk_i)
begin
if(begin_store_data) begin
if(USE_INV_I)	begin 		
		case(data_serdes_i_r) 
			PATTERN_DATA_INV[0] : first_data_i <= PATTERN_DATA_INV[0] ;
			PATTERN_DATA_INV[1] :	first_data_i <= PATTERN_DATA_INV[1] ;
			PATTERN_DATA_INV[2] :	first_data_i <= PATTERN_DATA_INV[2] ;
			PATTERN_DATA_INV[3] :	first_data_i <= PATTERN_DATA_INV[3] ;
			PATTERN_DATA_INV[4] :	first_data_i <= PATTERN_DATA_INV[4] ;
			//PATTERN_DATA_INV[5] :	first_data_i <= PATTERN_DATA_INV[5] ;
			//PATTERN_DATA_INV[6] :	first_data_i <= PATTERN_DATA_INV[6] ;
			//PATTERN_DATA_INV[7] :	first_data_i <= PATTERN_DATA_INV[7] ;
			//PATTERN_DATA_INV[8] :	first_data_i <= PATTERN_DATA_INV[8] ;
			//PATTERN_DATA_INV[9] :	first_data_i <= PATTERN_DATA_INV[9] ;			
			//PATTERN_DATA_INV[10]:	first_data_i <= PATTERN_DATA_INV[10];			
			default				  :	first_data_i <= 8'd0				  ; 	
		endcase
end
else
begin
		case(data_serdes_i_r) 
			PATTERN_DATA	[0] :	first_data_i <= PATTERN_DATA[0] ;
			PATTERN_DATA	[1] :	first_data_i <= PATTERN_DATA[1] ;
			PATTERN_DATA	[2] :	first_data_i <= PATTERN_DATA[2] ;
			PATTERN_DATA	[3] :	first_data_i <= PATTERN_DATA[3] ;
			PATTERN_DATA	[4] :	first_data_i <= PATTERN_DATA[4] ;
			//PATTERN_DATA	[5] :	first_data_i <= PATTERN_DATA[5] ;
			//PATTERN_DATA	[6] :	first_data_i <= PATTERN_DATA[6] ;
			//PATTERN_DATA	[7] :	first_data_i <= PATTERN_DATA[7] ;
			//PATTERN_DATA	[8] :	first_data_i <= PATTERN_DATA[8] ;
			//PATTERN_DATA	[9] :	first_data_i <= PATTERN_DATA[9] ;				
			//PATTERN_DATA	[10]:	first_data_i <= PATTERN_DATA[10];				
			default				  :	first_data_i <= 8'd0		    ; 
		endcase	
end
			
if(USE_INV_Q)	begin 	
		case(data_serdes_q_r) 
			PATTERN_DATA_INV[0] : first_data_q <= PATTERN_DATA_INV[0] ;
			PATTERN_DATA_INV[1] :	first_data_q <= PATTERN_DATA_INV[1] ;
			PATTERN_DATA_INV[2] :	first_data_q <= PATTERN_DATA_INV[2] ;
			PATTERN_DATA_INV[3] :	first_data_q <= PATTERN_DATA_INV[3] ;
			PATTERN_DATA_INV[4] :	first_data_q <= PATTERN_DATA_INV[4] ;
			//PATTERN_DATA_INV[5] :	first_data_q <= PATTERN_DATA_INV[5] ;
			//PATTERN_DATA_INV[6] :	first_data_q <= PATTERN_DATA_INV[6] ;
			//PATTERN_DATA_INV[7] :	first_data_q <= PATTERN_DATA_INV[7] ;
			//PATTERN_DATA_INV[8] :	first_data_q <= PATTERN_DATA_INV[8] ;
			//PATTERN_DATA_INV[9] :	first_data_q <= PATTERN_DATA_INV[9] ;			
			//PATTERN_DATA_INV[10]:	first_data_q <= PATTERN_DATA_INV[10];			
			default				  :	first_data_q <= 8'd0				  ; 	
		endcase
end	
else
begin
		case(data_serdes_q_r) 
			PATTERN_DATA	[0] :	first_data_q <= PATTERN_DATA[0] ;
			PATTERN_DATA	[1] :	first_data_q <= PATTERN_DATA[1] ;
			PATTERN_DATA	[2] :	first_data_q <= PATTERN_DATA[2] ;
			PATTERN_DATA	[3] :	first_data_q <= PATTERN_DATA[3] ;
			PATTERN_DATA	[4] :	first_data_q <= PATTERN_DATA[4] ;
			//PATTERN_DATA	[5] :	first_data_q <= PATTERN_DATA[5] ;
			//PATTERN_DATA	[6] :	first_data_q <= PATTERN_DATA[6] ;
			//PATTERN_DATA	[7] :	first_data_q <= PATTERN_DATA[7] ;
			//PATTERN_DATA	[8] :	first_data_q <= PATTERN_DATA[8] ;
			//PATTERN_DATA	[9] :	first_data_q <= PATTERN_DATA[9] ;				
			//PATTERN_DATA	[10]:	first_data_q <= PATTERN_DATA[10];				
			default				  :	first_data_q <= 8'd0		    ; 
		endcase	
end
end
end
	
	
/*
calc_maximum
	# (
		.PORTS 					(32												),
		.DATA_WIDTH 			(16												) 
	)
calc_maximum_inst_I	
	(
		.rst					(rst_i											),
		.clk					(clk_i											),
		.IDATA					(idelay_value_counter_good_i					),  
		.IDAV					(max_count_begin								),
		.MAX_VALUE				(max_value_i									),	 
		.MAX_VALUE_INDEX		(max_value_i_index								),
		.MAX_DAV				(s_max_dav_i									)							
	);
	
	
calc_maximum
	# (
		.PORTS 					(32												),
		.DATA_WIDTH 			(16												) 
	)
calc_maximum_inst_Q	
	(
		.rst					(rst_i											),
		.clk					(clk_i											),
		.IDATA					(idelay_value_counter_good_q					),  
		.IDAV					(max_count_begin								),
		.MAX_VALUE				(max_value_q									),	 
		.MAX_VALUE_INDEX		(max_value_q_index								),
		.MAX_DAV				(s_max_dav_q									)							
	);	
	
*/


find_zone_adc_line
	# (
		.PORTS 					(32												),
		.DATA_WIDTH 			(16												) 
	)
calc_maximum_inst_I	
	(
		.rst					(rst_i											),
		.clk					(clk_i											),
		.IDATA					(idelay_value_counter_good_i					),  
		.IDAV					(rise_max_count_begin							),
		.MAX_VALUE				(max_value_i									),	 
		.MAX_VALUE_INDEX		(max_value_i_index								),
		.MAX_DAV				(s_max_dav_i									),
		.MAX_CMP_VALUE          (TIME_LENGTH/6                                  )  								
	);
	
find_zone_adc_line
	# (
		.PORTS 					(32												),
		.DATA_WIDTH 			(16												) 
	)
calc_maximum_inst_Q	
	(
		.rst					(rst_i											),
		.clk					(clk_i											),
		.IDATA					(idelay_value_counter_good_q					),  
		.IDAV					(rise_max_count_begin							),
		.MAX_VALUE				(max_value_q									),	 
		.MAX_VALUE_INDEX		(max_value_q_index								),
		.MAX_DAV				(s_max_dav_q									),
		.MAX_CMP_VALUE          (TIME_LENGTH/6                                  )  							
	);	
	
end
else
begin: no_autocalib_algorithm
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//No Calibration_algorithm
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign  i_dl_in				=	1'b0;
assign  q_dl_in				=	1'b0;


always@(posedge clk_i)
if(rst_i) begin
	i_dl_ce	   				<= 1'b0;  	
	i_dl_cnt_in	    		<= 5'd0;
	i_dl_load_val   		<= 1'd0;
	q_dl_ce	        		<= 1'b0;
	q_dl_cnt_in	    		<= 5'd0;
	q_dl_load_val   		<= 1'd0;
	calibration_done_i		<= 1'd1;
	calibration_not_done_i	<= 1'd0;
	calibration_done_q		<= 1'd1;
	calibration_not_done_q	<= 1'd0;		
end
else begin
	calibration_done_i		<= 1'd1;
	calibration_not_done_i	<= 1'd0;
	calibration_done_q		<= 1'd1;
	calibration_not_done_q	<= 1'd0;
	i_dl_ce	   				<= 1'b0;  	
	i_dl_cnt_in	    		<= 5'd0;
	i_dl_load_val   		<= 1'd0;
	q_dl_ce	        		<= 1'b0;
	q_dl_cnt_in	    		<= 5'd0;
	q_dl_load_val   		<= 1'd0;
	
end
end

endgenerate

generate
if(USE_DEBUG == 1) begin
(* TIG = "TRUE" *) (* KEEP = "TRUE" *) (* mark_debug = "TRUE" *) reg	[31:0][15:0]	cs_idelay_value_counter_good_i		;
(* TIG = "TRUE" *) (* KEEP = "TRUE" *) (* mark_debug = "TRUE" *) reg	[31:0][15:0]	cs_idelay_value_counter_good_q		; 

always@(posedge clk_i)
begin
	cs_idelay_value_counter_good_i	<= idelay_value_counter_good_i	;
	cs_idelay_value_counter_good_q  <= idelay_value_counter_good_q	;
end
end
endgenerate

generate
for (i=0;i<32;i=i+1) begin
	// generate output table delays
	assign o_idelay_value_counter_good_i	[i]	=	{3'b000,idelay_value_counter_good_i[i]}	;
	assign o_idelay_value_counter_good_q	[i]	=	{3'b000,idelay_value_counter_good_q[i]}	;	
	assign o_idelay_value_dav					=	rise_max_count_begin					;	

end
endgenerate

// detect_
detect_edge
	detect_edge_max_count_begin
    (
		.clk					(clk_i								),
		.reset					(rst_i								),
		.sig					(max_count_begin					),
		.rise					(rise_max_count_begin				),
		.fall					(									)
    );	

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
