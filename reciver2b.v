module receiver2b(baud_rate, in, data, stateData, state_out);

input baud_rate, in;		
output [7:0]data; 
output stateData;	 
output [1:0]state_out;
         
reg [7:0]data;	
reg [7:0]buffer;          
reg [1:0]state;	
reg dataState = 1'b0;	

assign stateData = dataState;
assign state_out = state;

parameter START = 0, DATA = 1, STOP = 2;			 

integer counter = 0;		

always @ (posedge baud_rate) begin
	case (state)
	START:
		begin
			if(in) begin		
				dataState = 1'b0;	
				state <= START;
			end
			else				
				state <= DATA;
		end
	DATA:
		begin
			buffer[counter] = in;
			counter = counter + 1;
			if(counter > 7) begin
				state <= STOP;
			end
			else begin		    
				state <= DATA;				
			end	
		end
	STOP:
		begin
			data[7:0] <= buffer [7:0];  
			counter <= 0; 			
			dataState = 1'b1;
			state <= START;
		
		end
endcase
end
endmodule