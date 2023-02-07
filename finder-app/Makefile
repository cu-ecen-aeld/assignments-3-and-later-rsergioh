CROSS_COMPILE_STR=aarch64-none-linux-gnu-

all: writer

writer.o : writer.c
	aarch64-none-linux-gnu-gcc -g -Wall -c writer.c
writer : writer.o
	arch64-none-linux-gnu-gcc g -Wall -I/ writer.o -o writer
    
clean :
	rm -f *.o *.elf *.map *.S writer
