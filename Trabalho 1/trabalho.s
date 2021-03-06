.section .data

telaabertura:	.asciz	"Programa que interpreta e calcula expressoes matematicas\n"

mostraResultado: .asciz "\nResultado da expressão: %.2f\n"

exemplo: .asciz "\nOperadores disponíveis: +,-,*,/ \nExemplos funções: seno(x), cosseno(x), tangente(x), raiz(x), pow(x,y), log(x) \nNão suporta parenteses"

pedeexpressao:	.asciz	"\n\nEntre com a expressao matematica => ";

trataerrolista:	.asciz	"\nErro na ordem da lista de tokkens.\n"

titulomostra:	.asciz	"\nLista de Tokens:\n"

mostraToken:	.asciz	"\nToken = %s\n"
mostraF:	.asciz	"\nFloat = %.2f\n"
mostraC:	.asciz	"\nCaracter = %c\n"
mostraS:	.asciz	"\nExpressao = %s\n"

NULL:		.int	0

tpow:		.asciz	"pow("
tseno:		.asciz	"seno("
tcoseno:	.asciz	"cosseno("
ttangente:	.asciz	"tangente("
traiz:		.asciz	"raiz("
tlog:		.asciz  "log("

valorD:		.int	0
valorF:		.double	0.0
menos_um: .double -1.0

msgerro1:	.asciz	"\nSimbolo Indefinido! Pos = %d\n"
msgerro2:	.asciz	"\nFalta Fecha Parentes! Pos = %d\n"
msgerro3:	.asciz	"\nFecha Parentese em Excesso! Pos = %d\n"
msgerro4:	.asciz	"\nFuncao Inexistente! Pos = %d\n"
msgerro5:	.asciz	"\nFormato Numerico Incorreto! Pos = %d\n"
msgerro6:	.asciz	"\nFalta Operador Apos Numero! Pos = %d\n"

formatoS:	.asciz	"%s"

listatoken:	.int	0
tipotoken:	.int	0

contapar:	.int	0	# para ontar abre e fecha parenteses
poscar:		.int	0	# anotar a posicao do caracter

contaponto:	.int	0

.section .bss

.lcomm express, 200	# para armazenar expressoes ate 200 caracteres
.lcomm telem, 20	# tipo(4), valor(8), anterior(4) e posterior(4)
.lcomm token, 20	# para armazenar um elemento da lista


.section .text
# Função de redução das listas, primeiro resolve as potencias, em seguida * e /, por fim + e -

reduz:
	finit

	# Começa resolvendo números negativos da forma -x

	movl listatoken, %edi

	procura_numeros_negativos:

	cmpl NULL, %edi						# verifica se chegou no final da lista, caso sim, vai para a proxima etapa da redução
	je comeca_reducao_vezes_divisao

	cmpl $2, (%edi)
	je achou_menos
	jne continua_procura_menos

achou_menos:
	movl 16(%edi), %ebx		# endereço do proximo depois do -
	cmpl $10, (%ebx)		# verifica se é um numero
	je eh_numero
	jne continua_procura_menos		# caso não seja, esse menos não pode ser reduzido

eh_numero:
	movl 12(%edi), %eax 			# anterior do -
	cmpl $10, (%eax) 				# se for um numero não pode reduzir esse - pois ele é uma operação
	je continua_procura_menos

	fldl menos_um				# coloca -1 e o numero na pilha, realiza a multiplicação entre eles e coloca o resultado onde estava o - anteriormente
	fldl 4(%ebx)
	fmulp %st(1), %st(0)
	fstpl 4(%edi)
	movl $10, (%edi)

	movl 16(%ebx), %ecx
	cmpl NULL, %ecx
	je eh_nulo

	movl 16(%ebx), %eax
	movl %eax, 16(%edi)
	movl %edi, 12(%eax)
	jmp continua_procura_menos

eh_nulo:						# é o ultimo elemento da lista então o seu proximo  agora é nulo e envia para a redução de divisão pois não existe mais - para reduzir
	movl $0, 16(%edi)
	jmp comeca_reducao_vezes_divisao

continua_procura_menos:				# continua procurando os menos
	movl 16(%edi), %edi
	jmp procura_numeros_negativos

	# Começa reduzindo * e /

	# A ideia da redução é procurar sequencialmente os sinais de / e *, quando o %edi estiver em um dos dois sinais ele envia para a pilha FPU o anterior
	# e o posterior do sinal que são os dois operandos, é feita a operação e o resultado é guardado no endereço do primeiro operando
	# após guardar o resultado é preciso remover os dois proximo elementos do resultado que são respectivamente o sinal da operação (* ou /) 
	# e o segundo operando, é feito isso através da manipulação dos proximos e anteriores dos elementos da lista


	comeca_reducao_vezes_divisao:
	finit
	movl listatoken, %edi

reduz_lista:

	cmpl	NULL, %edi 					# verifica se chegou no final da lista
	je	comeca_reducao_mais_menos
	
	cmpl	$10, (%edi)                # veririca se é um número, caso sim, continuar verificação para o proximo elemento da lista
	je	contreduz

	cmpl $1, (%edi)                   # se for um + tbm continua para o proximo
	je contreduz

	cmpl $2, (%edi)                   # se for um - tbm continua para o proximo
	je contreduz


se_simbolo:                              # só chega aqui se for um * ou /
	movl 12(%edi), %eax                 # anterior da operação (primeiro operando)
	fldl 4(%eax)       
	movl 16(%edi), %ebx	               # proximo da operação (segundo operando)
	fldl 4(%ebx)

	cmpl $4, (%edi)                    # verifica se é uma multiplicação ou divisão
	je faz_divisao

faz_multiplicacao:
	fmulp %st(1), %st(0)
	jmp termina_multiplicacao_divisao

faz_divisao:
	fdivrp %st(1), %st(0)

termina_multiplicacao_divisao:
	fstpl 4(%eax)			# Guarda o resultado no anterior: exemplo: 3*5 o resultado será guardado no lugar do 3
	movl 16(%ebx), %esi   # Pega o proximo do proximo
	cmpl NULL, %esi       
	je continua
	movl %eax, 12(%esi)  # coloca o anterior do proximo do proximo como o novo atual

continua:
	movl 16(%ebx), %edi	
	movl %edi, 16(%eax)
	movl $0, 16(%ebx)
	movl %eax, %edi

contreduz:

	movl	16(%edi), %edi
	jmp	reduz_lista		


#	REDUÇÃO MAIS E MENOS

# a redução de + e - segue o mesmo estilo da redução de * e /, a única diferença é que não precisa verificar se a operação é * ou / pois as mesmas já não existem


comeca_reducao_mais_menos:

movl listatoken, %edi

reduz_lista_mais_menos:

	cmpl	NULL, %edi
	je	fimreduz
	
	cmpl	$10, (%edi)
	je	contreduz_mais_menos

se_simbolo_mais_menos:
	movl 12(%edi), %eax # anterior
	fldl 4(%eax)
	movl 16(%edi), %ebx	# proximo
	fldl 4(%ebx)

	cmpl $2, (%edi)
	je faz_subtracao

faz_adicao:
	faddp %st(1), %st(0)
	jmp termina_mais_menos

faz_subtracao:
	fsubrp %st(1), %st(0)

termina_mais_menos:
	fstpl 4(%eax)			# Guarda o resultado no anterior: exemplo: 3*5 o resultado será guardado no lugar do 3
	movl 16(%ebx), %esi   # Pega o proximo do proximo
	cmpl NULL, %esi       
	je continua_mais_menos
	movl %eax, 12(%esi)  # coloca o anterior do proximo do proximo como o novo atual

continua_mais_menos:
	movl 16(%ebx), %edi	
	movl %edi, 16(%eax)
	movl $0, 16(%ebx)
	movl %eax, %edi

contreduz_mais_menos:

	movl	16(%edi), %edi
	jmp	reduz_lista_mais_menos


fimreduz:								# vai chegar aqui quando só houver 1 elemento na lista que é o resultado da operação

	movl listatoken, %eax              # o endereço do último elemento é o endereço da lista, é enviado para o eax para mostrar o resultado
	fldl 4(%eax)
	subl $8, %esp
	fstpl (%esp)
	pushl $mostraResultado
	call printf
	addl $12, %esp

ret

# Função pra mostrar a tela de abertura e o exemplo de funções
abertura:

	pushl	$telaabertura
	call	printf
	pushl $exemplo
	call printf
	addl	$8, %esp

	ret

# Função para ler a expressao digitada pelo usuario a ser resolvida
le_expressao:

	pushl	$pedeexpressao
	call	printf
	pushl	$express
	call	gets
	addl	$8, %esp
	
	pushl	$express
	pushl	$mostraS
	call	printf
	addl	$8, %esp

	ret

# Função para mostrar a lista de tokens
mostra_lista:

	pushl	$titulomostra
	call	printf
	addl	$4, %esp

	movl	listatoken, %edi

voltamostra:
	pushl	%edi

	cmpl	NULL, %edi
	je	fimmostra
	
	cmpl	$10, (%edi)
	je	mostranumero

mostrasimbolo:

	movl	4(%edi), %eax
	pushl	%eax
	pushl	$mostraC
	call	printf
	addl	$8, %esp
	jmp	contmostra

mostranumero:
	
	fldl	4(%edi)
	subl	$8, %esp
	fstl	(%esp)
	pushl	$mostraF
	call	printf
	addl	$12, %esp

contmostra:

	popl	%edi
	movl	16(%edi), %edi
	jmp	voltamostra	

fimmostra:
	popl	%edi
	ret


# Função para criar a lista duplamente encadeada
cria_lista:

	movl	$express, %edi
	movl	$1, poscar

pegaprox:

	movl	$0, %eax
	movb	(%edi), %al

	cmpb	$0, %al
	je	tratafimstring

	cmpb	$32, %al
	je	trataespaco

	cmpb	$43, %al
	je	tratasoma		# tipo 1

	cmpb	$45, %al
	je	tratasubtracao		# tipo 2

	cmpb	$42, %al
	je	tratamultiplicacao	# tipo 3

	cmpb	$47, %al
	je	tratadivisao		# tipo 4

	cmpb	$40, %al
	je	trataabreparentese	# tipo 5

	cmpb	$41, %al
	je	tratafechaparentese	# tipo 6

	cmpb	$115, %al
	je	trataseno		# tipo 10

	cmpb	$114, %al
	je	trataraiz		# tipo 10

	cmpb	$108, %al
	je	tratalog		# tipo 10

	cmpb 	$112, %al   # tipo 10
	je tratapotencia

	cmpb	$99, %al
	je	tratacosseno		# tipo 10

	cmpb	$116, %al
	je	tratatangente		# tipo 10 

	cmpb	$48, %al
	jge	tratanumero		# tipo 10

	movl	$msgerro1, %ebx
	jmp	trataerro

	ret

tratafimstring:

	# tratar excesso de abre parenteses

	movl	contapar, %ecx
	cmpl	$0, %ecx
	jg	errofim

	ret		# retorno do crialista
				
errofim:

	movl	$msgerro2, %ebx
	jmp 	trataerro
	

trataespaco:

	incl	poscar
	incl	%edi
	jmp	pegaprox

tratapotencia:

	pusha

	movl	$10, tipotoken
	pushl	$4		
	pushl	%edi
	pushl	$token
	call	memcpy
	addl	$4, %esp
	popl	%edi
	addl	$4, %esp		

	movl 	$token, %esi
	movb	$0, 4(%esi)		

	pushl	$token
	pushl	$tpow		
	call	strcmp
	addl	$8, %esp		
	cmpl	$0, %eax
	jne	erro4

	popa

	addl $4, poscar
	addl $4, %edi

	movb (%edi), %al
	cmpb $48, %al
	jl erro4

	cmpb $57, %al
	jg erro4

	call extraitokenN

	pusha

	pushl $token
	call atof
	addl $4, %esp

	popa

	movb (%edi), %al
	cmpb $44, %al
	jne erro4

	addl $1, %edi
	addl $1, poscar

	movb (%edi), %al
	cmpb $48, %al
	jl erro4

	cmpb $57, %al
	jg erro4

	call extraitokenN

	pusha

	pushl $token
	call atof
	addl $4, %esp

	popa

	movb (%edi), %al
	cmpb $41, %al
	jne erro4

	subl $8, %esp
	fstpl (%esp)
	subl $8, %esp
	fstpl (%esp)
	call pow

	addl 	$16, %esp
	movl	$10, tipotoken
	call	inserelista
	
	incl	poscar
	incl	%edi
	jmp	pegaprox


trataraiz:

	pusha

	movl	$10, tipotoken
	pushl	$5		
	pushl	%edi
	pushl	$token
	call	memcpy
	addl	$4, %esp
	popl	%edi
	addl	$4, %esp		

	movl 	$token, %esi
	movb	$0, 5(%esi)		

	pushl	$token
	pushl	$traiz		
	call	strcmp
	addl	$8, %esp		
	cmpl	$0, %eax
	jne	erro4

	popa				

	addl	$5, poscar 		
	addl	$5, %edi
	
	movb	(%edi), %al
	cmpb	$48, %al
	jl	erro4
	
	cmpb	$57, %al
	jg	erro4

	call	extraitokenN
	
	movb	(%edi), %al
	cmpb	$41, %al
	jne	erro4

	finit
	
	pushl	$token
	call	atof
	subl	$8, %esp
	fstl	(%esp)
	call	sqrt	
	addl	$12, %esp

	movl	$10, tipotoken
	call	inserelista
	
	incl	poscar
	incl	%edi
	jmp	pegaprox

tratalog:

	pusha

	movl	$10, tipotoken
	pushl	$4		
	pushl	%edi
	pushl	$token
	call	memcpy
	addl	$4, %esp
	popl	%edi
	addl	$4, %esp		

	movl 	$token, %esi
	movb	$0, 4(%esi)		

	pushl	$token
	pushl	$tlog		
	call	strcmp
	addl	$8, %esp		
	cmpl	$0, %eax
	jne	erro4

	popa				

	addl	$4, poscar 		
	addl	$4, %edi
	
	movb	(%edi), %al
	cmpb	$48, %al
	jl	erro4
	
	cmpb	$57, %al
	jg	erro4

	call	extraitokenN
	
	movb	(%edi), %al
	cmpb	$41, %al
	jne	erro4

	finit
	
	pushl	$token
	call	atof
	subl	$8, %esp
	fstl	(%esp)
	call	log10	
	addl	$12, %esp

	movl	$10, tipotoken
	call	inserelista
	
	incl	poscar
	incl	%edi
	jmp	pegaprox
	
tratasoma:

	movl	$1, tipotoken
	movl	$0, %ebx
	movb	%al, %bl

	call	inserelista
	incl	poscar
	incl	%edi
	jmp	pegaprox

tratasubtracao:

	movl	$2, tipotoken
	movl	$0, %ebx
	movb	%al, %bl

	call	inserelista
	incl	poscar
	incl	%edi
	jmp	pegaprox

tratamultiplicacao:

	movl	$3, tipotoken
	movl	$0, %ebx
	movb	%al, %bl

	call	inserelista
	incl	poscar
	incl	%edi
	jmp	pegaprox

tratadivisao:

	movl	$4, tipotoken
	movl	$0, %ebx
	movb	%al, %bl

	call	inserelista
	incl	poscar
	incl	%edi
	jmp	pegaprox

trataabreparentese:

	movl	$5, tipotoken
	movl	$0, %ebx
	movb	%al, %bl

	call	inserelista
	incl	contapar
	incl	poscar
	incl	%edi
	jmp	pegaprox

tratafechaparentese:

	movl	$6, tipotoken
	movl	$0, %ebx
	movb	%al, %bl

	call	inserelista
	decl	contapar
	movl	contapar, %ecx
	cmpl	$0, %ecx
	jl	erropar
	incl	poscar
	incl	%edi
	jmp	pegaprox

erropar:

	movl	$msgerro3, %ebx
	jmp	trataerro

trataseno:

	pusha

	pushl	$5			
	pushl	%edi
	pushl	$token
	call	memcpy
	addl	$4, %esp
	popl	%edi
	addl	$4, %esp		

	movl 	$token, %esi
	movb	$0, 5(%esi)		

	pushl	$token
	pushl	$tseno		
	call	strcmp
	addl	$8, %esp		
	cmpl	$0, %eax
	je	contseno1
	
	movl	$msgerro4, %ebx
	jmp	trataerro

contseno1:

	popa				

	addl	$5, poscar 		
	addl	$5, %edi
	
	movb	(%edi), %al
	cmpb	$48, %al
	jge	contseno2

	movl	$msgerro4, %ebx
	jmp	trataerro

	
	contseno2:		

	cmpb	$57, %al
	jle	contseno3
	
	movl	$msgerro4, %ebx
	jmp	trataerro

contseno3:

	call	extraitokenN
	
	movb	(%edi), %al
	cmpb	$41, %al
	je	contseno4
	
	movl	$msgerro4, %ebx
	jmp	trataerro

contseno4:
	
	finit
	
	pushl	$token
	call	atof
	subl	$8, %esp
	fstl	(%esp)
	call	sin	
	addl	$12, %esp

	movl	$10, tipotoken
	call	inserelista
	
	incl	poscar
	incl	%edi
	jmp	pegaprox

tratacosseno:
	
	pusha

	pushl	$8			
	pushl	%edi
	pushl	$token
	call	memcpy
	addl	$4, %esp
	popl	%edi
	addl	$4, %esp		

	movl 	$token, %esi
	movb	$0, 8(%esi)		

	pushl	$token
	pushl	$tcoseno		
	call	strcmp
	addl	$8, %esp		
	cmpl	$0, %eax
	je	contcoseno1

	movl	$msgerro4, %ebx
	jmp	trataerro


contcoseno1:

	popa				

	addl	$8, poscar 		
	addl	$8, %edi
	
	movb	(%edi), %al
	cmpb	$48, %al
	jge	contcoseno2

	movl	$msgerro4, %ebx
	jmp	trataerro

	
contcoseno2:		

	cmpb	$57, %al
	jle	contcoseno3
	
	# tratar erro na funcao cosseno: argumento nao numerico
	movl	$msgerro4, %ebx
	jmp	trataerro

contcoseno3:

	call	extraitokenN
	
	movb	(%edi), %al
	cmpb	$41, %al
	je	contcoseno4
	
	# tratar erro na funcao cosseno: argumento nao numerico
	movl	$msgerro4, %ebx
	jmp	trataerro

contcoseno4:
	
	finit
	
	pushl	$token
	call	atof
	subl	$8, %esp
	fstl	(%esp)
	call	cos	
	addl	$12, %esp

	movl	$10, tipotoken
	call	inserelista
	
	incl	poscar
	incl	%edi
	jmp	pegaprox

tratatangente:

	pusha

	pushl	$9			
	pushl	%edi
	pushl	$token
	call	memcpy
	addl	$4, %esp
	popl	%edi
	addl	$4, %esp		

	movl 	$token, %esi
	movb	$0, 9(%esi)		

	pushl	$token
	pushl	$ttangente		
	call	strcmp
	addl	$8, %esp		
	cmpl	$0, %eax
	je	conttangente1
	
	movl	$msgerro4, %ebx
	jmp	trataerro

conttangente1:

	popa				

	addl	$9, poscar 		
	addl	$9, %edi
	
	movb	(%edi), %al
	cmpb	$48, %al
	jge	conttangente2

	movl	$msgerro4, %ebx
	jmp	trataerro

	
conttangente2:		

	cmpb	$57, %al
	jle	conttangente3
	
	movl	$msgerro4, %ebx
	jmp	trataerro

conttangente3:

	call	extraitokenN
	
	movb	(%edi), %al
	cmpb	$41, %al
	je	conttangente4
	
	movl	$msgerro4, %ebx
	jmp	trataerro

conttangente4:
	
	finit
	
	pushl	$token
	call	atof
	subl	$8, %esp
	fstl	(%esp)
	call	tan	
	addl	$12, %esp

	movl	$10, tipotoken
	call	inserelista
	
	incl	poscar
	incl	%edi
	jmp	pegaprox


tratanumero:

	cmpb	$57, %al
	jle	conttratanumero1

	movl	$msgerro1, %ebx
	jmp	trataerro

conttratanumero1:

	call	extraitokenN

	finit
	
	pushl	$token
	call	atof
		
	movl	$10, tipotoken
	call	inserelista
	addl	$4, %esp

	incl	poscar
	jmp	pegaprox

trataerro:
	movl	poscar, %eax
	pushl	%eax
	pushl	%ebx
	call	printf
	addl	$8, %esp		#antes nada	
	pushl $0
	call exit

erro4:

	movl	$msgerro4, %ebx
	jmp	trataerro


extraitokenN:

	movl	$token, %esi

voltatokenN:

	movb	(%edi),%cl
	movb	%cl,(%esi) 

	incl	poscar
	incl	%edi
	incl	%esi
	movb	(%edi), %al

	cmpb	$46, %al
	je	contextrai1
	
	cmpb	$48, %al
	jge	contextrai3
	
	movb	$0, (%esi)

	movl	$0, contaponto
 	ret

contextrai1:

	cmpl	$0, contaponto
	je	contextrai2
	
	movl	$msgerro5, %ebx
	jmp	trataerro
	
contextrai2:

	incl	contaponto
	jmp	voltatokenN

contextrai3:
	
	cmpb	$57, %al
	jle	voltatokenN
	
	movl	$msgerro6, %ebx
	jmp	trataerro
	

inserelista:

	pushl	%edi

	movl	listatoken, %edi
	pushl	%edi
	pushl	%ebx
	
	pushl	$20
	call	malloc
	addl	$4, %esp

	popl	%ebx
	popl	%edi
	cmpl	NULL, %edi
	je	insereinicio

inserefim:
	
	movl	16(%edi), %esi
	cmpl	NULL, %esi
	je	continserefim
	
	movl	%esi, %edi
	jmp	inserefim

continserefim:
	
	movl	%edi, 12(%eax)
	movl	%eax, 16(%edi)
	jmp	inseredefato

insereinicio:

	movl	%eax, listatoken
	movl	%eax, 12(%eax)

inseredefato:
	
	movl	tipotoken, %ecx
	movl	%ecx,(%eax)

	cmpl	$10, %ecx
	je	inserenumero

inseresimbolo:

	movl	%ebx, 4(%eax)
	jmp	continsere

inserenumero:

	fstpl	4(%eax)

continsere:

	movl	$0, 16(%eax)	# marquei proximo com NULL
	
	popl	%edi
	ret

# Função para checar a lista
checa_lista:

	movl	listatoken, %edi

	cmpl $1, (%edi)		# se a lista começar com +
	je erro_lista

	cmpl $3, (%edi)		# se a lista começar com *
	je erro_lista

	cmpl $4, (%edi)		# se a lista começar com /
	je erro_lista

	cmpl $2, (%edi)				# se começar com - necessariamente precisa de um número depois, não aceitando mais de 1 menos no começo
	jne volta_checa_lista

	movl 16(%edi), %eax
	cmpl NULL, %eax
	je erro_lista

	cmpl $10, (%eax)
	je continua_checa_lista
	jne erro_lista

volta_checa_lista:
	
	cmpl NULL, %edi
	je termina_checa_lista

	cmpl $5, (%edi)						# é um ( e o programa não aceita
	je erro_lista

	cmpl $6, (%edi)						# é um ) e o programa não aceita
	je erro_lista

	cmpl $1, (%edi) 					# é um mais
	je checa_mais_vezes_divisao

	cmpl $2, (%edi)						# é um menos
	je checa_menos

	cmpl $3, (%edi)						# é uma multiplicação
	je checa_mais_vezes_divisao

	cmpl $4, (%edi)						# é uma divisão
	je checa_mais_vezes_divisao

	cmpl $10, (%edi)					# é um numero
	je checa_numero

checa_menos:							# um menos só pode ter um outro menos (e somente 1) ou um número após
	movl 16(%edi), %eax

	cmpl NULL, %eax
	je erro_lista

	cmpl $2, (%eax)
	je achou_outro_menos
	jne continua_checa_menos

achou_outro_menos:						# se o proximo do menos for outro menos, necessariamente o proximo do segundo menos precisa ser um número
	movl 16(%eax), %eax

	cmpl NULL, %eax
	je erro_lista

	cmpl $10, (%eax)
	je continua_checa_lista
	jne erro_lista

continua_checa_menos:
	cmpl $10, (%eax)
	jne erro_lista
	je continua_checa_lista

checa_mais_vezes_divisao:			# após um +,*,/ só pode ter um número ou um -
	movl 16(%edi), %eax

	cmpl NULL, %eax
	je erro_lista

	cmpl $2, (%eax)							 # checa se é um menos
	je checa_menos_apos_divisao					
	jne continua_checa_mais_vezes_divisao

checa_menos_apos_divisao:			# se for um - o proximo necessariamente precisa ser um numero
	movl 16(%eax), %eax

	cmpl NULL, %eax
	je erro_lista

	cmpl $10, (%eax)
	je continua_checa_lista
	jne erro_lista

continua_checa_mais_vezes_divisao:		# se não for um menos, só pode ser um número
	cmpl $10, (%eax)
	je continua_checa_lista

	jmp erro_lista

checa_numero:					# após um número só pode haver o fim da lista ou uma operação
	movl 16(%edi), %eax

	cmpl NULL, %eax
	je termina_checa_lista

	cmpl $10, (%eax)
	je erro_lista

continua_checa_lista:			# continua a verificação passando o proximo do %edi para o %edi e voltando ao checa_lista
	movl 16(%edi), %edi
	jmp volta_checa_lista


erro_lista:						# printa erro na ordem dos tokens e termina o programa
	pushl $trataerrolista
	call printf
	pushl $0
	call exit

termina_checa_lista:
	ret

.global main

main:

	call	abertura
	call	le_expressao
	call	cria_lista
	call	checa_lista
	#call	mostra_lista
	call	reduz	

fim:

	pushl $0
    call exit
