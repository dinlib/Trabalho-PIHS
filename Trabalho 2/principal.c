#include <stdio.h>
#include <stdlib.h>


void le_expressao(char expressao[], char fim_string[]){
	asm(
		"movl 8(%esp), %ecx;"		// endereço da expressao para %ecx
		"movl 12(%esp), %edx;"		// endereço do fim de string  %edx
		"movl (%edx), %edx;"		// move o valor do fim de string para o %edx
		"pushl %edx;"				// salva %edx
		"pushl %ecx;"				// salva %ecx
		"movl $3, %eax;"			// função de leitura
		"movl $2, %ebx;"			// leitura do teclado
		"movl $200, %edx;"			// tamanho da expressao
		"int $0x80;"				// chama a função de leitura para ler para a variavel expressao que está com seu endereço em %ecx
									// Foi feita a leitura 
									// Agora é preciso acrescentar o fim de string na string lida
		"popl %ecx;"				// Recupera o valor do endereço da expressao caso ele foi alterado
		"determinastrutil:;"		// Começa a percorrer a expressao até encontrar o termino dela (espaço ou pula linha)
		"movl %ecx, %edi;"			
		"movl $-1,%ebx;"
		"volta:;"
		"addl $1, %ebx;	"
		"movb (%edi), %al;"
		"cmpb $'\n', %al;"
		"jz conclui;"
		"cmpb $' ', %al;"
		"jz conclui;"
		"addl $1, %edi;"
		"jmp volta;"
		"conclui:;"					// Quando encontrar o fim precisa inserir o fim de string na mesma
		"popl %edx;"				// recupera o valor do %edx que contem "\0" que representa o fim de string
		"movl %edx, (%edi);"		// move o fim de string para a posição correta
		);
}


int main(){
	char expressao[200];
	char fim_string[10] = "\0";
	le_expressao(expressao, fim_string);
	double resposta;
	calcexpress(expressao, &resposta);
	printf ("Resposta = %.2lf\n", resposta);
	return 0;
}