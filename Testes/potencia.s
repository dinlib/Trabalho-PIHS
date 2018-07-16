.section .data
	base: .double 2
	expoente: .double 5
	mostraD: .asciz "%.2lf\n"

.section .text

.global main

main:
	fldl base
	fldl expoente
	subl $8, %esp
	fstpl (%esp)
	subl $8, %esp
	fstpl (%esp)
	call pow
	subl $8, %esp
	fstpl (%esp)
	pushl $mostraD
	call printf

	pushl $0
	call exit

