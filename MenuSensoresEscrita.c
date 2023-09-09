#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

void printMenuSensor(){
    printf("\n==== SENSORES ====\n");
    printf("\nDigite o sensor que deseja monitorar [1,8]: ");
}

void printMenuComando(){
    printf("\n==== COMANDOS ====\n");
    printf("\n[1]Situacao atual\n");
    printf("[2]Temperatura atual\n");
    printf("[3]Umidade atual\n");
    printf("[4]Sensoriamento continuo temperatura\n");
    printf("[5]Sensoriamento continuo Umidade\n");
    printf("[6]Desativar Sensoriamento continuo temperatura\n");
    printf("[7]Desativar Sensoriamento continuo umidade\n");
    printf("Opcao: \n");
}

int main (){
    int sensor;
    int comando;
    int continuar = 1;
    char byte1Sensor[255];
    char byte2Comando[255];
    struct termios options;
    int fd, len1,len2;

    // Configuracoes
    fd = open("/dev/ttyS0", O_WRONLY);
     if(fd<0){
    	printf("erro");
        return -1;
    }

    /*A sigla "c_cflag" significa "control flag" ou "conjunto de flags de controle".
      B9600 ? velocidade?
      CS8 - usa 8 bits
    */
   options.c_cflag = B9600 | CS8 | CLOCAL| CREAD;
   //cfsetspeed(&options, B9600);

   //input flags
   options.c_iflag  = IGNPAR;

    //limpa a entrada do buffer
   tcflush(fd, TCIFLUSH);
   //Aplica as configurações
   tcsetattr(fd, TCSANOW, &options);

    while (continuar==1){
        printMenuSensor();
        scanf("%d", &sensor);

        if(sensor >= 1 && sensor <= 8){
                printMenuComando();
                scanf("%d", &comando);

                if(comando >= 1 && comando <= 7){
                    int tamanhoMaximo1 = sizeof(byte1Sensor);
                    int tamanhoMaximo2 = sizeof(byte2Comando);
                    snprintf(byte1Sensor, tamanhoMaximo1, "%d", sensor);
                    snprintf(byte2Comando, tamanhoMaximo2, "%d", comando);
                   // printf("sensor: %s\n", byte1Sensor);
                   // printf("comando: %s\n", byte2Comando);

                    len1 = strlen(byte1Sensor);
                    printf("Tamanho byte 1: %d\n", len1);
                    len1 = write(fd, byte1Sensor, len1);
                    printf("Primeiro byte enviado:  %d \n", len1);
                    sleep(0.5);
                    len2 = strlen(byte2Comando);
                    printf("Tamanho byte 2: %d\n", len2);
                    len2 = write(fd, byte2Comando, len2);
                   printf("Segundo byte enviado:  %d \n", len2);
                    sleep(0.5);

                }else{
                    printf("\nOpcao de comando invalida!\n");
                }
        }else{
            printf("Opcao invalida!");
        }

    }
    close(fd);
}
