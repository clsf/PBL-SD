module uart2b(clk, in, out, state_r, state_t, data_transmitted);
		 
input in, clk ; 
output out, data_transmitted; 	
output [1:0] state_r, state_t; 		
		
wire baud_rate, data_recived;
wire [15:0] data;		

baudrate_gen baudrate_gen_0(
.clk(clk), 
.tick(baud_rate));

receiver2b receiver2b_0(
.baud_rate(clk), // SUBSTITUIR PELO BAUD_RATE ANTES DE TESTAR NA PLACA
.in(in), 
.data(data), 
.data_recived(data_recived), 
.state_out(state_r));

transmitter2b transmitter2b_0(
.baud_rate(clk), // SUBSTITUIR PELO BAUD_RATE ANTES DE TESTAR NA PLACA
.out(out), 
.data(data), 
.start(data_recived), 
.data_transmitted(data_transmitted), 
.state_out(state_t));
		
endmodule 