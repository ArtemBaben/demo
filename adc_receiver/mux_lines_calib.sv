`timescale 1ns / 1ps
`default_nettype none
/*
//////////////////////////////////////////////////////////////////////////////////
// Company 		:  	RNIIRS
// Engineer		:  	Babenko Artem
// Device 		:   bpac_059
// Description  :	Top calibration module
//
//					-Control calibration ISERDES and IDELAY 
//					-Communicate with data_adc
//
//
//
/////////////////////////////////////////////////////////////////////////////////
*/
module mux_lines_calib_adc
#(
parameter 			PORTS								= 12			
)
(
// system_interface
input	wire					 						clk_i						,
input	wire											rst_i						,
input	wire				 	 [7:0]					mux_cntrl					,	

// serdes_data ports group in
input   wire		[(PORTS-1):0][7:0]					data_serdes_i_i				,
input   wire		[(PORTS-1):0][7:0]					data_serdes_q_i				,
// serdes_data ports group out
output  reg			 	 		 [7:0]					data_serdes_i_o				,
output  reg				 		 [7:0]					data_serdes_q_o				,

// idelay ports group in
input   wire 											i_i_dl_ce	    ,
input	wire		[4:0]								i_i_dl_cnt_in	,
input	wire 											i_i_dl_in	    ,
input	wire											i_i_dl_load_val	,
output	reg			[4:0]								o_i_dl_cnt_val_o,	

input 	wire 											i_q_dl_ce	    ,
input	wire		[4:0]								i_q_dl_cnt_in	,
input	wire 											i_q_dl_in	    ,
input	wire											i_q_dl_load_val	,
output	reg			[4:0]								o_q_dl_cnt_val_o,

// iodelay_group out
output  reg 		[(PORTS-1):0]						o_i_dl_ce	    ,
output	reg			[(PORTS-1):0][4:0]					o_i_dl_cnt_in	,
output	reg 		[(PORTS-1):0]						o_i_dl_in	    ,
output	reg			[(PORTS-1):0]						o_i_dl_load_val	,
input   wire		[(PORTS-1):0][4:0]					i_i_dl_cnt_val_o,


output  reg 		[(PORTS-1):0]						o_q_dl_ce	    ,
output	reg			[(PORTS-1):0][4:0]					o_q_dl_cnt_in	,
output	reg 		[(PORTS-1):0]						o_q_dl_in	    ,
output	reg			[(PORTS-1):0]						o_q_dl_load_val	,
input   wire		[(PORTS-1):0][4:0]					i_q_dl_cnt_val_o,

//  				
input 	wire											bitslip_i_i		,		
input 	wire											bitslip_q_i		,	

output 	reg			[(PORTS-1):0]						bitslip_i_o		,		
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
			data_serdes_i_o		<= {PORTS{1'b0}};
			data_serdes_q_o 	<= {PORTS{1'b0}};	
			o_i_dl_cnt_val_o	<= 5'd0			;
			o_q_dl_cnt_val_o	<= 5'd0			;
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
			data_serdes_i_o			<=	data_serdes_i_i [0]	;
			data_serdes_q_o 	    <=	data_serdes_q_i [0]	;
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
			data_serdes_i_o			<=	data_serdes_i_i [1]	;
			data_serdes_q_o 	    <=	data_serdes_q_i [1]	;
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
			data_serdes_i_o			<=	data_serdes_i_i [2]	;
			data_serdes_q_o 	    <=	data_serdes_q_i [2]	;
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
			data_serdes_i_o			<=	data_serdes_i_i [3]	;
			data_serdes_q_o 	    <=	data_serdes_q_i [3]	;
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
			data_serdes_i_o			<=	data_serdes_i_i [4]	;
			data_serdes_q_o 	    <=	data_serdes_q_i [4]	;
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
			data_serdes_i_o			<=	data_serdes_i_i [5]	;
			data_serdes_q_o 	    <=	data_serdes_q_i [5]	;
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
			data_serdes_i_o			<=	data_serdes_i_i [6]	;
			data_serdes_q_o 	    <=	data_serdes_q_i [6]	;
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
			data_serdes_i_o			<=	data_serdes_i_i [7]	;
			data_serdes_q_o 	    <=	data_serdes_q_i [7]	;
			o_i_dl_cnt_val_o		<= i_i_dl_cnt_val_o [7] ;
			o_q_dl_cnt_val_o		<= i_q_dl_cnt_val_o [7] ;					
		end 
		
		8'd8: begin
			o_i_dl_ce	        [8] <= i_i_dl_ce	  		;	      
			o_i_dl_cnt_in	    [8] <= i_i_dl_cnt_in		;	    
			o_i_dl_in	        [8] <= i_i_dl_in	  		;      
			o_i_dl_load_val		[8] <= i_i_dl_load_val		;		
			o_q_dl_ce	        [8] <= i_q_dl_ce	  		;	      
			o_q_dl_cnt_in	    [8] <= i_q_dl_cnt_in		;	    
			o_q_dl_in	        [8] <= i_q_dl_in	  		;      
			o_q_dl_load_val		[8] <= i_q_dl_load_val		;			
			bitslip_i_o			[8]	<= bitslip_i_i			;
			bitslip_q_o         [8] <= bitslip_q_i			;
			data_serdes_i_o			<=	data_serdes_i_i [8]	;
			data_serdes_q_o 	    <=	data_serdes_q_i [8]	;
			o_i_dl_cnt_val_o		<= i_i_dl_cnt_val_o [8] ;
			o_q_dl_cnt_val_o		<= i_q_dl_cnt_val_o [8] ;					
		end 

		8'd9: begin
			o_i_dl_ce	        [9] <= i_i_dl_ce	  		;	      
			o_i_dl_cnt_in	    [9] <= i_i_dl_cnt_in		;	    
			o_i_dl_in	        [9] <= i_i_dl_in	  		;      
			o_i_dl_load_val		[9] <= i_i_dl_load_val		;		
			o_q_dl_ce	        [9] <= i_q_dl_ce	  		;	      
			o_q_dl_cnt_in	    [9] <= i_q_dl_cnt_in		;	    
			o_q_dl_in	        [9] <= i_q_dl_in	  		;      
			o_q_dl_load_val		[9] <= i_q_dl_load_val		;			
			bitslip_i_o			[9]	<= bitslip_i_i			;
			bitslip_q_o         [9] <= bitslip_q_i			;
			data_serdes_i_o			<=	data_serdes_i_i [9]	;
			data_serdes_q_o 	    <=	data_serdes_q_i [9]	;
			o_i_dl_cnt_val_o		<= i_i_dl_cnt_val_o [9] ;
			o_q_dl_cnt_val_o		<= i_q_dl_cnt_val_o [9] ;					
		end 

		8'd10: begin
			o_i_dl_ce	        [10] <= i_i_dl_ce	  			;	      
			o_i_dl_cnt_in	    [10] <= i_i_dl_cnt_in			;	    
			o_i_dl_in	        [10] <= i_i_dl_in	  			;      
			o_i_dl_load_val		[10] <= i_i_dl_load_val			;		
			o_q_dl_ce	        [10] <= i_q_dl_ce	  			;	      
			o_q_dl_cnt_in	    [10] <= i_q_dl_cnt_in			;	    
			o_q_dl_in	        [10] <= i_q_dl_in	  			;      
			o_q_dl_load_val		[10] <= i_q_dl_load_val			;			
			bitslip_i_o			[10] <= bitslip_i_i				;
			bitslip_q_o         [10] <= bitslip_q_i				;
			data_serdes_i_o			 <=	data_serdes_i_i  [10]	;
			data_serdes_q_o 	     <=	data_serdes_q_i  [10]	;
			o_i_dl_cnt_val_o		 <= i_i_dl_cnt_val_o [10] 	;
			o_q_dl_cnt_val_o		 <= i_q_dl_cnt_val_o [10] 	;					
		end 

		8'd11: begin
			o_i_dl_ce	        [11] <= i_i_dl_ce	  			;	      
			o_i_dl_cnt_in	    [11] <= i_i_dl_cnt_in			;	    
			o_i_dl_in	        [11] <= i_i_dl_in	  			;      
			o_i_dl_load_val		[11] <= i_i_dl_load_val			;		
			o_q_dl_ce	        [11] <= i_q_dl_ce	  			;	      
			o_q_dl_cnt_in	    [11] <= i_q_dl_cnt_in			;	    
			o_q_dl_in	        [11] <= i_q_dl_in	  			;      
			o_q_dl_load_val		[11] <= i_q_dl_load_val			;			
			bitslip_i_o			[11] <= bitslip_i_i				;
			bitslip_q_o         [11] <= bitslip_q_i				;
			data_serdes_i_o			 <=	data_serdes_i_i  [11]	;
			data_serdes_q_o 	     <=	data_serdes_q_i  [11]	;
			o_i_dl_cnt_val_o		 <= i_i_dl_cnt_val_o [11] 	;
			o_q_dl_cnt_val_o		 <= i_q_dl_cnt_val_o [11] 	;					
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
			data_serdes_i_o		<= {PORTS{1'b0}};
			data_serdes_q_o 	<= {PORTS{1'b0}};	
			o_i_dl_cnt_val_o	<= 5'd0			;
			o_q_dl_cnt_val_o	<= 5'd0			;	
		end
	endcase
end
end 
endmodule

`default_nettype wire
