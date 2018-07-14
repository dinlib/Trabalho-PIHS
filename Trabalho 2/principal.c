#include <stdio.h>
#include <stdlib.h>


int main(){
	char expressao[200] = "10/10+5*5";
	double resposta;
	calcexpress(expressao, &resposta);
	printf ("Resposta = %.2lf\n", resposta);
	return 0;
}