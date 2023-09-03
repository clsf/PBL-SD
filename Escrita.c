#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

/*char* comunicacao(){
    char botao [255];
    printf("Desligar / Ligar o led? [l/d]");
    scanf("%s", botao);
    return botao;
}*/

int printMenuInicial(int opcao){
    print("==== MONITORAMENTO DE SENSORES ====\n");
    print("[1]Iniciar");
    print("[2]Sair\n");
    scanf("Opção: %i\n",opcao);

}

char printMenuSensor(char sensor){
    print("==== SENSORES ====\n");
    print("[1]Sensor[1]\n");
    print("[2]Sensor\n");
    print("[3]Sensor\n");
    print("[4]Sensor\n");
    print("[5]Sensor\n");
    print("[6]Sensor\n");
    print("[7]Sensor\n");
    print("[8]Sensor\n");
    scanf("Digite o sensor que deseja enviar algum comando: %s\n",sensor);
    return string;
}

char printComandos(char comando){
    print("==== COMANDOS ====\n");
    print("[1]Situação atual\n");
    print("[2]Temperatura atual\n");
    print("[3]Umidade atual\n");
    print("[4]Sensoriamento contínuo temperatura\n");
    print("[5]Sensoriamento contínuo Umidade\n");
    print("[6]Desativar Sensoriamento contínuo temperatura\n");
    print("[7]Desativar Sensoriamento contínuo umidade\n");
    scanf("Digite o comando que deseja enviar para o sensor: %s\n",comando);
    return opcao;
}




void printBinary(unsigned char byte){
	for (int i = 7; i >= 0; i--) {
		printf("%d", (byte>>i) & 1);
	}
}

int main(){

    int fd, sensor, len1,len2;
    char comando, opcao;
    char byte1[255];
    char byte2[255];
    struct termios options;



    /*Abre a porta
        as flags: O_RDWR para ler e escrever
        O_NDELAY: Chamada retorna imediatamente, mesmo que sem dados
        O_NOCTTy Flag responsável por fazer com que não exista nenhum controle de modem
    */

    opcao = 1;

    while (opcao == 1){
    fd = open("/dev/ttyS0", O_RDWR | O_NDELAY | O_NOCTTY );

    if(fd<0){
    	printf("erro");
        return -1;
    }


    //Para ler as configurações da porta atual:
    //tcgetattr(fd, &options);

    /*A sigla "c_cflag" significa "control flag" ou "conjunto de flags de controle".
      B9600 ? velocidade?
      CS8 - usa 8 bits
    */
   options.c_cflag = B9600 | CS8 | CLOCAL| CREAD;
   //cfsetspeed(&options, B9600);

   //input flags
   options.c_iflag  = IGNPAR;
   //output flags
   options.c_oflag =0;
   options.c_lflag =0;

   //limpa a entrada do buffer
   tcflush(fd, TCIFLUSH);
   //Aplica as configurações
   tcsetattr(fd, TCSANOW, &options);

   /*Menus das opções*/
   opcao = printMenuInicial(opcao);
   sensor =  printMenuSensor(sensor);
   comando = printComandos(comando);

   /*Atribuindo aos char, os valores dos bytes lidos*/
   byte1 = sensor;
   byte2 = comando;

   /* enviando e mostrando os bytes desejados seguindo a ordem de primeiro o sensor e depois o comando */
   len = strlen(sensor);
   printf("Tamanho byte 1: %d\n", len1);

   unsigned char *ptr = sensor;
   for (int i = 0; i < sizeof(char); i++) {
   	printf("Byte %d: ", i+1);
   	printBinary(ptr[i]);
   	printf("\n");
   }

   len1 = write(fd, sensor, len1);
   printf("Primeiro byte enviado:  %d \n", len1);

    printf("%d", len);
    sleep(0.5);

    len2 = strlen(comando);
   printf("Tamanho byte 1: %d\n", len2);

   *ptr = comando;
   for (int i = 0; i < sizeof(char); i++) {
   	printf("Byte %d: ", i+1);
   	printBinary(ptr[i]);
   	printf("\n");
   }

   len2 = write(fd, comando, len2);
   printf("Segundo byte enviado:  %d \n", len2);

    printf("%d", len2);
    sleep(0.5);




    }
   close(fd);
}
