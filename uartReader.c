#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>


// Funcao que converte de binario para decimal
int binaryToDecimal(unsigned char *binary) {
    int decimal = 0;
    int length = strlen(binary);

    for (int i = 0; i < length; i++) {
        if (binary[i] == '1') {
            decimal += 1 << (length - 1 - i);
        }
    }

    return decimal;
}

// Funcao que converte de decimal para binario
void decimalToBinary(char decimalChar, char binary[9]) {
    int decimal = decimalChar - '0'; // Converte o caractere decimal em um inteiro

    for (int i = 7; i >= 0; i--) {
        binary[i] = (decimal % 2) + '0'; // Converte o bit para '0' ou '1'
        decimal /= 2;
    }

    binary[8] = '\0'; // Adiciona o caractere nulo para formar uma string
}

// Funcao pra teste de validade do binario
void printBinary(unsigned char byte) {
    for (int i = 7; i >= 0; i--) {
        printf("%d", (byte >> i) & 1);
    }
}

int main(){
    int numBytes = 3;
	int fd, len;
	int command, sensorInfo;
	char text[numBytes];// só salvo dois bytes(char) por vez
	char address;
	char binaryCommand[9];
	char binarySensorInfo[9];
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
		//printf("===================\n");
		//printf("Recebi %d bytes\n", len);
		//printf("Recebi as strings: %s\n", text);

		// Converte os valores convertidos em ascii pela uart para binario
		decimalToBinary(text[1], binaryCommand);
		decimalToBinary(text[2], binarySensorInfo);
		// Converte a variavel dos dados em binario para int
		command = binaryToDecimal(binaryCommand);
		sensorInfo = binaryToDecimal(binarySensorInfo);
		// Pega o valor de endereco de text
		address = text[0];

		// Saídas baseadas no comando recebido
		switch(command){
			case 1:
				printf("Código %d: Sensor %c com problema\n", command, address);
				break;
			case 2:
				printf("Código %d: Sensor %c funcionando normalmente\n", command, address);
				break;
			case 3:
				printf("Código %d: Medida de umidade do sensor %c: %d\n", command, address, sensorInfo);
				break; 
			case 4:
				printf("Código %d: Medida de temperatura do sensor %c: %d\n", command, address, sensorInfo);
				break; 
			case 5:
				printf("Código %d: Desativado monitoramento continuo de temperatura do sensor: %c\n", command, address);
				break; 
			case 6:
				printf("Código %d: Desativado monitoramento continuo de umidade do sensor: %c\n", command, address);
				break; 
		}
		
		/** ######### FIM TRECHO PARA LEITURA ######### */
	}

	close(fd);// Fecha a porta
    return 0;
}
