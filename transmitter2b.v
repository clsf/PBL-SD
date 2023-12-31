module transmitter2b (baud_rate, out, data, start, data_transmitted, state_out);

input baud_rate, start;
input [0:15]data;
output out;
output data_transmitted;
output [1:0]state_out;

reg transmitted = 1'b0;
reg data_state;
reg out = 1'b1;
reg [1:0]state;

assign data_transmitted = transmitted;
assign state_out = state;

parameter IDLE = 0, START = 1, DATA = 2, STOP = 3;
					
integer counter = 15;

always @ (posedge baud_rate) begin
	case(state)
		IDLE:
			begin
				transmitted = 1'b0;
				if(start) begin
					state <= START;
				end
			end
		START:
			begin
				out = 1'b0; 
				state <= DATA;
			end
		DATA:
			begin
				out = data[counter];
				counter = counter - 1;
				if (counter == 7 | counter == -1) begin 
					state <= STOP;
				end
			end
		STOP:     
			begin	
				state <= START; 
				out = 1'b1;
				if (counter == -1) begin
					counter = 15; 
					transmitted = 1'b1;	
					state <= IDLE;
				end   	
			end
	endcase
end

endmodule 