module receiver_buffers(clk_115200hz, in, data, control, stateData);

input clk_115200hz, in;		// in = sinal vindo da raspberry	
output control;				// sinal de enable do decodificador
reg control = 1'b0;
output [7:0]data;           // registrador de dados que enviará os dados recebidos para o decodificador
reg [7:0]data;	
reg [7:0]buffer_endereco;             //buffer temporário para receber o endereço do sensor
reg [7:0]buffer_comando; 	//buffer temporário para receber o comando
reg [1:0]state;				// registrador de estados da maquina de estados
output stateData;	
assign stateData = dataState;
reg dataState = 1'b0;
	parameter START = 0, 
				 DATA = 1,
				 STOP = 2;			 

integer counter = 0;		
integer controle = 1;

always @ (posedge clk_115200hz) begin
case (state)
	START:
		begin
			if(in) begin		// in == 1 => idle
			   control = 1'b0;
				dataState = 1'b0;	 
				controle = 1;
				state <= START;
			end
			else					// in == 0 => start bit
				state <= DATA;
		end
	DATA:
		begin
			if(counter > 7) begin  // Se counter > 7 acabou a recepção
				control = 1'b0;
				state <= STOP;
			end
			else begin		    	// Se counter < 7 armazena o bit atual no buffer e incrementa counter
				if(controle == 1) begin
					buffer_endereco[counter] = in;
					counter = counter + 1;
				end 
				if (controle == 2) begin
					buffer_comando[counter] = in;
					counter = counter + 1;
				end
				state <= DATA;				
			end	
		end
	STOP:
		begin
		if(controle == 1) begin
			data[7:0] <= buffer_endereco [7:0];  // registrador data recebe o buffer que é passado para saída
			counter <= 0; 				// reseta counter
			control <= 1'b1; 	 		// seta o controle do decodificador em 1 
			dataState = 1'b1;
			controle <= 2;
			end 
		if (controle == 2) begin
			data[7:0] <= buffer_comando [7:0];  // registrador data recebe o buffer que é passado para saída
			counter <= 0; 				// reseta counter
			control <= 1'b1; 	 		// seta o controle do decodificador em 1 
			dataState = 1'b1;
			end
			state <= START;
		
		end
endcase
end
endmodule