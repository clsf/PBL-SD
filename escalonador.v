module escalonador (
clk,
data_received,
command_i, // o RECEIVER MANDA EM 1 ARRAY DE VITS SÓ
address_i,
response_sensor1,
data_sensor1,
response_sensor2,
data_sensor2,
response_sensor3,
data_sensor3,
response_sensor4,
data_sensor4,
response_sensor5,
data_sensor5,
response_sensor6,
data_sensor6,
response_sensor7,
data_sensor7,
response_sensor8,
data_sensor8,
done_sensors,
done_decoder,
command_sensor_o,
en_sensors_o,
response_sensor_o,
data_sensor_o,
address_sensor_o,
en_decoder_o,
state_o
);

input clk;

// Output do Receiver
input data_received;
input [7:0] command_i;
input [7:0] address_i;

// Outputs das Interfaces
input [7:0] response_sensor1;
input [7:0] data_sensor1;
input [7:0] response_sensor2;
input [7:0] data_sensor2;
input [7:0] response_sensor3;
input [7:0] data_sensor3;
input [7:0] response_sensor4;
input [7:0] data_sensor4;
input [7:0] response_sensor5;
input [7:0] data_sensor5;
input [7:0] response_sensor6;
input [7:0] data_sensor6;
input [7:0] response_sensor7;
input [7:0] data_sensor7;
input [7:0] response_sensor8;
input [7:0] data_sensor8;
input [7:0] done_sensors; // Cada interface manda um bit distinto

// Output do Decodificador
input done_decoder;

// Inputs das Interfaces
output [7:0] command_sensor_o;
output [7:0] en_sensors_o; // Cada interface recebe um bit distinto

// Inputs do Decodificador
output [7:0] response_sensor_o;
output [7:0] data_sensor_o;
output [7:0] address_sensor_o;
output en_decoder_o;

output [3:0] state_o;

reg [7:0] command;
reg [7:0] address;

reg en_decoder;
reg [3:0] state;
reg [7:0] en_sensors;
reg [7:0] data_sensor;
reg [7:0] command_sensor;
reg [7:0] response_sensor; // mudar para 6 bits
reg [7:0] address_sensor;
reg [7:0] temp_cont;
reg [7:0] umid_cont;

integer counter = 0;

parameter COMMAND = 0, TEMP_CONT_S1 = 1, UMID_CONT_S1 = 2;

assign response_sensor_o = response_sensor;
assign data_sensor_o = data_sensor;
assign address_sensor_o = address_sensor;
assign en_decoder_o = en_decoder;

assign command_sensor_o = command_sensor;
assign en_sensors_o = en_sensors;

assign state_o = state;

/*
decodificador(
.clk(),
.comandos(), 
.endereco(),
.data_sensor(), 
.data_transmitted(),
.i_done(),
.start_transmitter(), 
.d_done(), 
.data_transmitter(),
); 

interface0(
.i_Clock(), // clk
.i_En(), // start
.i_request(), // comando de requisição
.dht_data_int(), // Inout dht data
.o_data_int(), // Valor da respota
.o_data_response(), // Comando de Resposta
.o_done_i1() // Recebimento do dado
);*/
	


always @ (posedge clk) begin
	if (data_received == 1) begin
		command <= command_i;
		address <= address_i;
	end
	case (state)
		COMMAND:
			begin
				if (command == 8'b00110001 | command == 8'b00110010 | command == 8'b00110011) begin // Se não for nada relacionado a monitoramento continuo
					if (counter == 0) begin // Etapa 1: Inicia a comunicação com a interface do sensor no endereço passado
						case (address)
							8'b00110001 : en_sensors[0] <= 1; // Inicia a comunicação com a interface 1
							8'b00110010 : en_sensors[1] <= 1; 
							8'b00110011 : en_sensors[2] <= 1;
							8'b00110100 : en_sensors[3] <= 1;
							8'b00110101 : en_sensors[4] <= 1; // [...]
							8'b00110110 : en_sensors[5] <= 1;
							8'b00110111 : en_sensors[6] <= 1;
							8'b00111000 : en_sensors[7] <= 1; // Inicia a comunicação com  interface 2
						endcase
						address_sensor <= address;
						command_sensor <= command;
						counter <= counter + 1;
					end 
					else if (counter == 1) begin // Etapa 2: Direciona quais dados vão para o decodifcador e habilita ele
						en_sensors <= 8'b00000000;
						case (done_sensors) // Verifica se alguma das interfaces terminou de enviar os dados
							8'b00000001: 
								begin
									data_sensor <= data_sensor1; 
									response_sensor <= response_sensor1;
									en_decoder <= 1;
									counter <= counter + 1;
								end
							8'b00000010: 
								begin
									data_sensor <= data_sensor2;
									response_sensor <= response_sensor2;
									en_decoder <= 1;
									counter <= counter + 1;
								end
							8'b00000100: 
								begin
									data_sensor <= data_sensor3;
									response_sensor <= response_sensor3;
									en_decoder <= 1;
									counter <= counter + 1;
								end
							8'b00001000: 
								begin
									data_sensor <= data_sensor4;
									response_sensor <= response_sensor4;
									en_decoder <= 1;
									counter <= counter + 1;
								end
							8'b00010000: 
								begin
									data_sensor <= data_sensor5;
									response_sensor <= response_sensor5;
									en_decoder <= 1;
									counter <= counter + 1;
								end
							8'b00100000: 
								begin
									data_sensor <= data_sensor6;
									response_sensor <= response_sensor6;
									en_decoder <= 1;
									counter <= counter + 1;
								end
							8'b01000000: 
								begin
									data_sensor <= data_sensor7;
									response_sensor <= response_sensor7;
									en_decoder <= 1;
									counter <= counter + 1;
								end
							8'b10000000: 
								begin
									data_sensor <= data_sensor8;
									response_sensor <= response_sensor8;
									en_decoder <= 1;
									counter <= counter + 1;
								end
						endcase
					end
					else if (counter == 2) begin // Etapa 3: Desabilita o decodificador e espera os dados serem transmitidos para ir pro proximo estado.
						en_decoder <= 0;
						if (done_decoder) begin
							counter <= 0;
							command <= 8'b00000000;
							state <= TEMP_CONT_S1;
						end
					end
				end
				else if (command == 8'b00110100 | command == 8'b00110101 | command == 8'b00110110 | command == 8'b00110111) begin
					case (command)
						8'b00110100: // Habilitar o monitorialmento continuo da temperatura
							begin
								case (address)
									8'b00110001 : temp_cont[0] <= 1; // Habilita o monitorialmento continuo da temperatura do sensor 1
									8'b00110010 : temp_cont[1] <= 1;
									8'b00110011 : temp_cont[2] <= 1;
									8'b00110100 : temp_cont[3] <= 1;
									8'b00110101 : temp_cont[4] <= 1; // [...]
									8'b00110110 : temp_cont[5] <= 1;
									8'b00110111 : temp_cont[6] <= 1;
									8'b00111000 : temp_cont[7] <= 1; // Habilita o monitorialmento continuo da temperatura do sensor 8
								endcase
							end
						8'b00110101: // Habilitar o monitorialmento continuo da umidade
							begin
								case (address)
									8'b00110001 : umid_cont[0] <= 1; // Habilita o monitorialmento continuo da umidade do sensor 1
									8'b00110010 : umid_cont[1] <= 1;
									8'b00110011 : umid_cont[2] <= 1;
									8'b00110100 : umid_cont[3] <= 1;
									8'b00110101 : umid_cont[4] <= 1; // [...]
									8'b00110110 : umid_cont[5] <= 1;
									8'b00110111 : umid_cont[6] <= 1;
									8'b00111000 : umid_cont[7] <= 1; // Habilita o monitorialmento continuo da umidade do sensor 8
								endcase
							end
						8'b00110110: // Desabilitar o monitorialmento continuo da temperatura
							begin
								case (address)
									8'b00110001 : temp_cont[0] <= 0; // Desabilita o monitorialmento continuo da temperatura do sensor 1
									8'b00110010 : temp_cont[1] <= 0;
									8'b00110011 : temp_cont[2] <= 0;
									8'b00110100 : temp_cont[3] <= 0;
									8'b00110101 : temp_cont[4] <= 0; // [...]
									8'b00110110 : temp_cont[5] <= 0;
									8'b00110111 : temp_cont[6] <= 0;
									8'b00111000 : temp_cont[7] <= 0; // Desabilita o monitorialmento continuo da temperatura do sensor 8
								endcase
							end
						8'b00110111: // Desabilitar o monitorialmento continuo da umidade
							begin
								case (address)
									8'b00110001 : umid_cont[0] <= 0; // Desabilita o monitorialmento continuo da umidade do sensor 1
									8'b00110010 : umid_cont[1] <= 0;
									8'b00110011 : umid_cont[2] <= 0;
									8'b00110100 : umid_cont[3] <= 0;
									8'b00110101 : umid_cont[4] <= 0; // [...]
									8'b00110110 : umid_cont[5] <= 0;
									8'b00110111 : umid_cont[6] <= 0;
									8'b00111000 : umid_cont[7] <= 0; // Desabilita o monitorialmento continuo da umidade do sensor 8
								endcase
							end
					endcase
					command <= 8'b00000000;
					state <= TEMP_CONT_S1;
				end
			end
			
		TEMP_CONT_S1:
			begin
				if (temp_cont[0] == 1) begin
					if (counter == 0) begin
						address_sensor <= 8'b00110001;
						command_sensor <= 8'b00110010;
						en_sensors[0] <= 1;
						counter <= counter + 1;
					end
					else if (counter == 1) begin
						en_sensors[0] <= 0;
						if (done_sensors[0]) begin
							data_sensor <= data_sensor1; 
							response_sensor <= response_sensor1;
							en_decoder <= 1;
							counter <= counter + 1;
						end
					end
					else if (counter == 2) begin
						en_decoder <= 0;
						if (done_decoder) begin
							command <= 8'b00000000;
							counter <= 0;
							state <= UMID_CONT_S1;
						end
					end
				end
				else begin
					state <= UMID_CONT_S1;
				end
			end
			
		UMID_CONT_S1:
			begin
				if (umid_cont[0] == 1) begin
					if (counter == 0) begin
						address_sensor <= 8'b00110001;
						command_sensor <= 8'b00110011;
						en_sensors[0] <= 1;
						counter <= counter + 1;
					end
					else if (counter == 1) begin
						en_sensors[0] <= 0;
						if (done_sensors[0]) begin
							data_sensor <= data_sensor1; 
							response_sensor <= response_sensor1;
							en_decoder <= 1;
							counter <= counter + 1;
						end
					end
					else if (counter == 2) begin
						en_decoder <= 0;
						if (done_decoder) begin
							command <= 8'b00000000;
							counter <= 0;
							state <= COMMAND;
						end
					end
				end
				else begin
					state <= COMMAND;
				end
			end
	endcase
end

endmodule