////////////////////////////////////////////////////////////////////
// Calculation maximum module 
// Device 		:   bpac_057
// Author		: Babenko Artem
////////////////////////////////////////////////////////////////////
module calc_maximum
	# (
		parameter	PORTS 		= 32,
		parameter	DATA_WIDTH 	= 16 
	
	)				 
	(
		input										rst					,
		input										clk					,
		input  [(PORTS -1):0][20:0]	  				IDATA				,     	 // Set to 1'b1 for single port mode, 1'b0 for dual port mode.
		input										IDAV				,
		output reg  	     [15:0 ]				MAX_VALUE			,	
		output reg			 [4:0  ]				MAX_VALUE_INDEX		,	
		output 		  	     						MAX_DAV										
	);
		genvar										i					;
		reg    [(PORTS/2 -1):0] [20:0]				MAX_VALUE_r0		;
		reg    [(PORTS/4 -1):0] [20:0]				MAX_VALUE_r1		;
		reg    [(PORTS/8 -1):0] [20:0]				MAX_VALUE_r2		;
		reg    [(PORTS/16 -1):0][20:0]				MAX_VALUE_r3		;
		
		reg    [31:0]								ddelay				;


always@(posedge clk)
if(rst) begin
	ddelay <= 32'd0;
end
else begin
	ddelay[0]    <= IDAV		;
	ddelay[31:1] <= ddelay[30:0];
end

assign MAX_DAV  = ddelay[31];
		
		
// Generate tree for find maximum
generate
for (i=0;i<PORTS/2;i=i+1) begin	
        always @ (posedge clk)
        begin
		if(rst)
				MAX_VALUE_r0[i] <=	21'd0;
		else
                if((IDATA[2*i+1][15:0] > IDATA[2*i][15:0])) 					MAX_VALUE_r0[i] <= IDATA[2*i+1];
				else 															MAX_VALUE_r0[i] <= IDATA[2*i]  ;

        end
end	
endgenerate

generate
for (i=0;i<PORTS/4;i=i+1) begin	
        always @ (posedge clk)
        begin
		if(rst)
				MAX_VALUE_r1[i] <=	21'd0;
		else
                if((MAX_VALUE_r0[2*i+1][15:0] > MAX_VALUE_r0[2*i][15:0])) 		MAX_VALUE_r1[i] <= MAX_VALUE_r0[2*i+1];
				else 										  			  		MAX_VALUE_r1[i] <= MAX_VALUE_r0[2*i]  ;

        end  
end	
endgenerate

generate
for (i=0;i<PORTS/8;i=i+1) begin	
        always @ (posedge clk)
        begin
		if(rst)
				MAX_VALUE_r2[i] <=	21'd0;
		else
                if((MAX_VALUE_r1[2*i+1][15:0] > MAX_VALUE_r1[2*i][15:0])) 		MAX_VALUE_r2[i] <= MAX_VALUE_r1[2*i+1];
				else 										  					MAX_VALUE_r2[i] <= MAX_VALUE_r1[2*i]  ;

        end
end	
endgenerate

generate
for (i=0;i<PORTS/16;i=i+1) begin	
        always @ (posedge clk)
        begin
		if(rst)
				MAX_VALUE_r3[i] <=	21'd0;
		else
                if((MAX_VALUE_r2[2*i+1][15:0] > MAX_VALUE_r2[2*i][15:0])) 		MAX_VALUE_r3[i] <= MAX_VALUE_r2[2*i+1];
				else 										 			  		MAX_VALUE_r3[i] <= MAX_VALUE_r2[2*i]  ;

        end
end	
endgenerate

// Find maximum value
generate
for (i=0;i<PORTS/PORTS; i=i+1) begin	
        always @ (posedge clk)
        begin
		if(rst)
				MAX_VALUE <=	21'd0;
		else
                if((MAX_VALUE_r3[2*i+1][15:0] > MAX_VALUE_r3[2*i][15:0])) 		{MAX_VALUE_INDEX,MAX_VALUE}	 <= MAX_VALUE_r3[2*i+1];
				else 															{MAX_VALUE_INDEX,MAX_VALUE}	 <= MAX_VALUE_r3[2*i]  ;
        end
end	
endgenerate
endmodule 

