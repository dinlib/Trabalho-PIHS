all:
	@clear
	@gcc -c -m32 calcexpress.s -o calcexpress.o
	@gcc -m32 principal.c calcexpress.o -o principal -lm
	@rm *.o
	@clear
	@./principal
