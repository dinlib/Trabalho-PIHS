#include <stdio.h>
#include <stdlib.h>

void le_expressao(char expressao[]){
	asm(
		"movl 8(%esp), %ecx;"
		"movl $3, %eax;"
		"movl $2, %ebx;"
		"movl $200, %edx;"
		"int $0x80;"
		);
}

int main(){
	char expressao[200];
	char formato[10] = "%s";
	le_expressao(expressao);
	printf("%s", expressao);

	return 0;
}