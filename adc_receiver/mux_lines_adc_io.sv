`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// Device 		:   bpac_059
// Description  :	Switch ADC for manual setup
//
//
/////////////////////////////////////////////////////////////////////////////////
*/
module mux_lines_adc_io
#(
parameter 			PORTS								= 8,
parameter			DATA_WIDTH_ADC						= 12				
)
(
// system_interface
input	wire					 						clk_i						,
input	wire											rst_i						,
input	wire				 	 [(PORTS-1):0]			mux_cntrl					,	

input	wire											dbg_control_pin_i			,
output	reg					 	 [(PORTS-1):0]			dbg_control_pin_o			,

input	wire					 [(PORTS-1):0]				dbg_mux_lines_i				,							
output	reg					 	 [(PORTS-1):0][(PORTS-1):0]	dbg_mux_lines_o				,							

// idelay ports group in
input   wire 											i_i_dl_ce	    			,
input	wire		[4:0]								i_i_dl_cnt_in				,
input	wire 											i_i_dl_in	    			,
input	wire											i_i_dl_load_val				,
output	reg			[4:0]								o_i_dl_cnt_val_o			,	

input 	wire 											i_q_dl_ce	    			,
input	wire		[4:0]								i_q_dl_cnt_in				,
input	wire 											i_q_dl_in	    			,
input	wire											i_q_dl_load_val				,
output	reg			[4:0]								o_q_dl_cnt_val_o			,

// iodelay_group out
output  reg 		[(PORTS-1):0]						o_i_dl_ce	    			,
output	reg			[(PORTS-1):0][4:0]					o_i_dl_cnt_in				,
output	reg 		[(PORTS-1):0]						o_i_dl_in	    			,
output	reg			[(PORTS-1):0]						o_i_dl_load_val				,
input   wire		[(PORTS-1):0][4:0]					i_i_dl_cnt_val_o			,


output  reg 		[(PORTS-1):0]						o_q_dl_ce	    			,
output	reg			[(PORTS-1):0][4:0]					o_q_dl_cnt_in				,
output	reg 		[(PORTS-1):0]						o_q_dl_in	    			,
output	reg			[(PORTS-1):0]						o_q_dl_load_val				,
input   wire		[(PORTS-1):0][4:0]					i_q_dl_cnt_val_o			,

//  				
input 	wire											bitslip_i_i					,		
input 	wire											bitslip_q_i					,	

output 	reg			[(PORTS-1):0]						bitslip_i_o					,		
output 	reg			[(PORTS-1):0]						bitslip_q_o						

);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wires and regs
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////




///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Main mux process
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
always@(posedge clk_i)
begin
if(rst_i) begin
			o_i_dl_ce	        <= {PORTS{1'b0}};      
			o_i_dl_cnt_in	    <= {PORTS{5'd0}};    
			o_i_dl_in	        <= {PORTS{1'b0}};   
			o_i_dl_load_val		<= {PORTS{1'b0}};	
			o_q_dl_ce	        <= {PORTS{1'b0}};      
			o_q_dl_cnt_in	    <= {PORTS{5'd0}};  
			o_q_dl_in	        <= {PORTS{1'b0}};   
			o_q_dl_load_val		<= {PORTS{1'b0}};		
			bitslip_i_o			<= {PORTS{1'b0}};
			bitslip_q_o         <= {PORTS{1'b0}};
			o_i_dl_cnt_val_o	<= 5'd0			;
			o_q_dl_cnt_val_o	<= 5'd0			;

			dbg_control_pin_o	<= {PORTS{1'b0}};//{PORTS{1'b1}};
			dbg_mux_lines_o		<= {PORTS{8'd0}};					
			
			
			
end
else begin
	case(mux_cntrl)
		8'd0: begin
			o_i_dl_ce	        [0] <= i_i_dl_ce	  		;	      
			o_i_dl_cnt_in	    [0] <= i_i_dl_cnt_in		;	    
			o_i_dl_in	        [0] <= i_i_dl_in	  		;      
			o_i_dl_load_val		[0] <= i_i_dl_load_val		;		
			o_q_dl_ce	        [0] <= i_q_dl_ce	  		;	      
			o_q_dl_cnt_in	    [0] <= i_q_dl_cnt_in		;	    
			o_q_dl_in	        [0] <= i_q_dl_in	  		;      
			o_q_dl_load_val		[0] <= i_q_dl_load_val		;			
			bitslip_i_o			[0]	<= bitslip_i_i			;
			bitslip_q_o         [0] <= bitslip_q_i			;
			dbg_control_pin_o	[0]	<= dbg_control_pin_i	;	
			dbg_mux_lines_o		[0]	<= dbg_mux_lines_i		;			
			o_i_dl_cnt_val_o		<= i_i_dl_cnt_val_o [0] ;
			o_q_dl_cnt_val_o		<= i_q_dl_cnt_val_o [0] ;					
		end 	
	
		8'd1: begin
			o_i_dl_ce	        [1] <= i_i_dl_ce	  		;	      
			o_i_dl_cnt_in	    [1] <= i_i_dl_cnt_in		;	    
			o_i_dl_in	        [1] <= i_i_dl_in	  		;      
			o_i_dl_load_val		[1] <= i_i_dl_load_val		;		
			o_q_dl_ce	        [1] <= i_q_dl_ce	  		;	      
			o_q_dl_cnt_in	    [1] <= i_q_dl_cnt_in		;	    
			o_q_dl_in	        [1] <= i_q_dl_in	  		;      
			o_q_dl_load_val		[1] <= i_q_dl_load_val		;			
			bitslip_i_o			[1]	<= bitslip_i_i			;
			bitslip_q_o         [1] <= bitslip_q_i			;
			dbg_control_pin_o	[1]	<= dbg_control_pin_i	;	
			dbg_mux_lines_o		[1]	<= dbg_mux_lines_i		;	
			o_i_dl_cnt_val_o		<= i_i_dl_cnt_val_o [1] ;
			o_q_dl_cnt_val_o		<= i_q_dl_cnt_val_o [1] ;					
			
		end 		

		8'd2: begin
			o_i_dl_ce	        [2] <= i_i_dl_ce	  		;	      
			o_i_dl_cnt_in	    [2] <= i_i_dl_cnt_in		;	    
			o_i_dl_in	        [2] <= i_i_dl_in	  		;      
			o_i_dl_load_val		[2] <= i_i_dl_load_val		;		
			o_q_dl_ce	        [2] <= i_q_dl_ce	  		;	      
			o_q_dl_cnt_in	    [2] <= i_q_dl_cnt_in		;	    
			o_q_dl_in	        [2] <= i_q_dl_in	  		;      
			o_q_dl_load_val		[2] <= i_q_dl_load_val		;			
			bitslip_i_o			[2]	<= bitslip_i_i			;
			bitslip_q_o         [2] <= bitslip_q_i			;
			dbg_control_pin_o	[2]	<= dbg_control_pin_i	;	
			dbg_mux_lines_o		[2]	<= dbg_mux_lines_i		;	
			o_i_dl_cnt_val_o		<= i_i_dl_cnt_val_o [2] ;
			o_q_dl_cnt_val_o		<= i_q_dl_cnt_val_o [2] ;					
		end 		
		
		8'd3: begin
			o_i_dl_ce	        [3] <= i_i_dl_ce	  		;	      
			o_i_dl_cnt_in	    [3] <= i_i_dl_cnt_in		;	    
			o_i_dl_in	        [3] <= i_i_dl_in	  		;      
			o_i_dl_load_val		[3] <= i_i_dl_load_val		;		
			o_q_dl_ce	        [3] <= i_q_dl_ce	  		;	      
			o_q_dl_cnt_in	    [3] <= i_q_dl_cnt_in		;	    
			o_q_dl_in	        [3] <= i_q_dl_in	  		;      
			o_q_dl_load_val		[3] <= i_q_dl_load_val		;			
			bitslip_i_o			[3]	<= bitslip_i_i			;
			bitslip_q_o         [3] <= bitslip_q_i			;
			dbg_control_pin_o	[3]	<= dbg_control_pin_i	;	
			dbg_mux_lines_o		[3]	<= dbg_mux_lines_i		;	
			o_i_dl_cnt_val_o		<= i_i_dl_cnt_val_o [3] ;
			o_q_dl_cnt_val_o		<= i_q_dl_cnt_val_o [3] ;					
		end 			
		
		8'd4: begin
			o_i_dl_ce	        [4] <= i_i_dl_ce	  		;	      
			o_i_dl_cnt_in	    [4] <= i_i_dl_cnt_in		;	    
			o_i_dl_in	        [4] <= i_i_dl_in	  		;      
			o_i_dl_load_val		[4] <= i_i_dl_load_val		;		
			o_q_dl_ce	        [4] <= i_q_dl_ce	  		;	      
			o_q_dl_cnt_in	    [4] <= i_q_dl_cnt_in		;	    
			o_q_dl_in	        [4] <= i_q_dl_in	  		;      
			o_q_dl_load_val		[4] <= i_q_dl_load_val		;			
			bitslip_i_o			[4]	<= bitslip_i_i			;
			bitslip_q_o         [4] <= bitslip_q_i			;
			dbg_control_pin_o	[4]	<= dbg_control_pin_i	;	
			dbg_mux_lines_o		[4]	<= dbg_mux_lines_i		;	
			o_i_dl_cnt_val_o		<= i_i_dl_cnt_val_o [4] ;
			o_q_dl_cnt_val_o		<= i_q_dl_cnt_val_o [4] ;					
		end 				
		
		8'd5: begin
			o_i_dl_ce	        [5] <= i_i_dl_ce	  		;	      
			o_i_dl_cnt_in	    [5] <= i_i_dl_cnt_in		;	    
			o_i_dl_in	        [5] <= i_i_dl_in	  		;      
			o_i_dl_load_val		[5] <= i_i_dl_load_val		;		
			o_q_dl_ce	        [5] <= i_q_dl_ce	  		;	      
			o_q_dl_cnt_in	    [5] <= i_q_dl_cnt_in		;	    
			o_q_dl_in	        [5] <= i_q_dl_in	  		;      
			o_q_dl_load_val		[5] <= i_q_dl_load_val		;			
			bitslip_i_o			[5]	<= bitslip_i_i			;
			bitslip_q_o         [5] <= bitslip_q_i			;
			dbg_control_pin_o	[5]	<= dbg_control_pin_i	;	
			dbg_mux_lines_o		[5]	<= dbg_mux_lines_i		;	
			o_i_dl_cnt_val_o		<= i_i_dl_cnt_val_o [5] ;
			o_q_dl_cnt_val_o		<= i_q_dl_cnt_val_o [5] ;					
		end 				
		
		8'd6: begin
			o_i_dl_ce	        [6] <= i_i_dl_ce	  		;	      
			o_i_dl_cnt_in	    [6] <= i_i_dl_cnt_in		;	    
			o_i_dl_in	        [6] <= i_i_dl_in	  		;      
			o_i_dl_load_val		[6] <= i_i_dl_load_val		;		
			o_q_dl_ce	        [6] <= i_q_dl_ce	  		;	      
			o_q_dl_cnt_in	    [6] <= i_q_dl_cnt_in		;	    
			o_q_dl_in	        [6] <= i_q_dl_in	  		;      
			o_q_dl_load_val		[6] <= i_q_dl_load_val		;			
			bitslip_i_o			[6]	<= bitslip_i_i			;
			bitslip_q_o         [6] <= bitslip_q_i			;
			dbg_control_pin_o	[6]	<= dbg_control_pin_i	;	
			dbg_mux_lines_o		[6]	<= dbg_mux_lines_i		;	
			o_i_dl_cnt_val_o		<= i_i_dl_cnt_val_o [6] ;
			o_q_dl_cnt_val_o		<= i_q_dl_cnt_val_o [6] ;		
		end 

		8'd7: begin
			o_i_dl_ce	        [7] <= i_i_dl_ce	  		;	      
			o_i_dl_cnt_in	    [7] <= i_i_dl_cnt_in		;	    
			o_i_dl_in	        [7] <= i_i_dl_in	  		;      
			o_i_dl_load_val		[7] <= i_i_dl_load_val		;		
			o_q_dl_ce	        [7] <= i_q_dl_ce	  		;	      
			o_q_dl_cnt_in	    [7] <= i_q_dl_cnt_in		;	    
			o_q_dl_in	        [7] <= i_q_dl_in	  		;      
			o_q_dl_load_val		[7] <= i_q_dl_load_val		;			
			bitslip_i_o			[7]	<= bitslip_i_i			;
			bitslip_q_o         [7] <= bitslip_q_i			;
			dbg_control_pin_o	[7]	<= dbg_control_pin_i	;	
			dbg_mux_lines_o		[7]	<= dbg_mux_lines_i		;	
			o_i_dl_cnt_val_o		<= i_i_dl_cnt_val_o [7] ;
			o_q_dl_cnt_val_o		<= i_q_dl_cnt_val_o [7] ;					
		end 

		default: begin
			o_i_dl_ce	        <= {PORTS{1'b0}};      
			o_i_dl_cnt_in	    <= {PORTS{5'd0}};    
			o_i_dl_in	        <= {PORTS{1'b0}};   
			o_i_dl_load_val		<= {PORTS{1'b0}};	
			o_q_dl_ce	        <= {PORTS{1'b0}};      
			o_q_dl_cnt_in	    <= {PORTS{5'd0}};  
			o_q_dl_in	        <= {PORTS{1'b0}};   
			o_q_dl_load_val		<= {PORTS{1'b0}};		
			bitslip_i_o			<= {PORTS{1'b0}};
			bitslip_q_o         <= {PORTS{1'b0}};
			o_i_dl_cnt_val_o	<= 5'd0			;
			o_q_dl_cnt_val_o	<= 5'd0			;	
			dbg_control_pin_o	<= {PORTS{1'b0}};//{PORTS{1'b1}};
			dbg_mux_lines_o		<= {PORTS{8'd0}};				
			
		end
	endcase
end
end 
endmodule

`default_nettype wire
