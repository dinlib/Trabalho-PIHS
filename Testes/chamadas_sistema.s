.section .data

	outvid: .ascii "\nMsg teste impressa no video usando chamada write()\n"
	fimoutvid:
	pedealgo: .ascii "\nDigite algo pelo teclado: "
	fimpedealgo:
	strarqout: .ascii "\nMsg teste impressa no arquivo usando chamada write()\n"
	fimstrarqout:
	pedearqin: .ascii "\nEntre com o nome do arquivo de entrada\n> "
	fimpedearqin:
	pedearqout: .ascii "\nEntre com o nome do arquivo de saida\n> "
	fimpedearqout:
	mostrain: .ascii "\nEntrada Original em Caracteres Suja = "
	fimmostrain:

	mostrainlimpa: .ascii "\nEntrada Original em Caracteres Limpa = "
	fimmostrainlimpa:
	buffer: .ascii "12345678901234567890123456789012345678901234567890"
	fimbuffer:
	pergunta: .asciz "\n\nConverter a entrada para:\n<1> Inteiro\n<2> Real\n > "
	mostratam: .asciz "\n\nTamanho da Entrada Valida: %d\n"
	mostraintoint: .asciz "\nEntrada Convertida para Numero Inteiro = %d\n"
	mostrastrarqin: .asciz "\nString Lida: %s\n"
	mostraintofloat: .asciz "\nEntrada Convertida para Numero PF = %.2lf\n"
	mostranomearq: .asciz "\nNome do Arquivo: %s\n"
	msgfim: .asciz "\nAll is done!"
	.equ tamoutvid, fimoutvid-outvid
	.equ tamstrarqout, fimstrarqout-strarqout
	.equ tampedearqin, fimpedearqin-pedearqin
	.equ tampedearqout, fimpedearqout-pedearqout
	.equ tampedealgo, fimpedealgo-pedealgo
	.equ tambuffer, fimbuffer-buffer
	.equ tammostrain, fimmostrain-mostrain
	.equ tammostrainlimpa, fimmostrainlimpa-mostrainlimpa
	enter: .byte 10 # código ascii do line feed (pulalinha) = '\n'
	return: .byte 13 # código ascii do carriage return
	NULL: .byte 0 # código ascii do NULL = '\0'
	espaco: .byte ' ' # espaco em branco
	formato: .asciz "%d" # formato de entrada para o scanf
	pulalin: .asciz "\n" # string com pulalinha linha para o printf
	nomearqin: .space 50
	nomearqout: .int 0
	opcao: .int 0
	tam: .int 0
	valorint: .int 0
	valorreal: .double 0.0
	STD_OUT: .int 1 # descritor do video
	STD_IN: .int 2 # descritor do teclado
	SYS_EXIT: .int 1
	SYS_FORK: .int 2
	SYS_READ: .int 3
	SYS_WRITE: .int 4
	SYS_OPEN: .int 5
	SYS_CLOSE: .int 6
	SYS_CREAT: .int 8
	SAIDA_NORMAL: .int 0 # codigo de saida bem sucedida
.section .text

.global main

main:

movl SYS_WRITE, %eax
movl STD_OUT, %ebx
movl $pedealgo, %ecx
movl $tampedealgo, %edx
int $0x80
movl SYS_READ, %eax
movl STD_IN, %ebx
movl $buffer, %ecx
movl $tambuffer, %edx
int $0x80




determinastrutil:
movl $buffer, %edi
movl $-1,%ebx
volta:
addl $1, %ebx
movb (%edi), %al
cmpb enter, %al
jz conclui
cmpb espaco, %al
jz conclui
addl $1, %edi
jmp volta
conclui:
movb NULL, %al
movb %al, (%edi) # substitui enter ou espaco por fim de string


pushl $buffer
pushl $mostranomearq
call printf

pushl $0
call exit
