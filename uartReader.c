#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <math.h>
#include <termios.h>

// Funcao pra teste de validade do binario
void printBinary(unsigned char byte) {
    for (int i = 7; i >= 0; i--) {
        printf("%d", (byte >> i) & 1);
    }
}

int main(){
    int numBytes = 3;
	int fd, len;
	int command, sensorInfo, address;
	char text[numBytes];// só salvo dois bytes(char) por vez
	int reading = 1;
	struct termios options; /* Serial ports setting */
	// Informando a porta, que é de leitura e escrita, sem delay
	fd = open("/dev/ttyS0", O_RDONLY);
	if (fd < 0) {
		perror("Error opening serial port");
		return -1;
	}

    /* Read current serial port settings */
	// tcgetattr(fd, &options);
	
	/* Set up serial port */
	/*A sigla "c_cflag" significa "control flag" ou "conjunto de flags de controle".
      B9600 ? velocidade?
      CS8 - usa 8 bits
    */
	options.c_cflag = B9600 | CS8 | CLOCAL | CREAD;
	//input flags
	options.c_iflag = IGNPAR;
	options.c_oflag = 0;
	options.c_lflag = 0;

	//limpa a entrada do buffer
	tcflush(fd, TCIFLUSH);
	//Aplica as configurações
	tcsetattr(fd, TCSANOW, &options);
    
	while(reading){
		/** ######### TRECHO PARA LEITURA ######### */
		///**
		//printf("O computador esperará 5 segundos para envio dos dados...\n");
		sleep(1);

		// Read from serial port 
		memset(text, 0, numBytes);
		len = read(fd, text, numBytes);

		if (len > 0) {
			printf("===================\n");
			printf("Recebi %d bytes\n", len);
			printf("Recebi as strings: %s\n", text);
			printf("\nValor:\n");
			printBinary(text[0]);
			printf("\nComando:\n");
			printBinary(text[1]);
			printf("\nSensor:\n");
			printBinary(text[2]);
			printf("\n");
		}
		
		sensorInfo = text[0];
		command = text[1];
		address = text[2];
		
		if (len > 0) {
			printf("Comando: %d\nValor: %d\nSensor: %c\n", command, sensorInfo, address);
		}
			
		// Saídas baseadas no comando recebido
		switch(command){
			case 1:
				printf("Código %d: Sensor %d com problema\n", command, address);
				break;
			case 2:
				printf("Código %d: Sensor %d funcionando normalmente\n", command, address);
				break;
			case 3:
				printf("Código %d: Medida de umidade do sensor %d: %d\n", command, address, sensorInfo); 
				break;
			case 4:
				printf("Código %d: Medida de temperatura do sensor %d: %d\n", command, address, sensorInfo); 
				break;
			case 5:
				printf("Código %d: Desativado monitoramento continuo de temperatura do sensor: %d\n", command, address); 
				break;
			case 6:
				printf("Código %d: Desativado monitoramento continuo de umidade do sensor: %d\n", command, address); 
				break;
		}	

		/** ######### FIM TRECHO PARA LEITURA ######### */
	}

	close(fd);// Fecha a porta
    return 0;
}
