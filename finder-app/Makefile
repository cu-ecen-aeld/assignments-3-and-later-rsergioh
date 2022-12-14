CROSS_COMPILE_STR=aarch64-none-linux-gnu-

all: writer.o

writer.o : writer.c
ifeq ($(CROSS_COMPILE), $(CROSS_COMPILE_STR))
	@ echo "Cross compiling for aarch64"
	$(CROSS_COMPILE)gcc -g -Wall -c -o writer.o writer.c
	$(CROSS_COMPILE)gcc -g -Wall -I/ writer.o -o writer
else
	@ echo "Compiling for native execution"
	gcc -g -Wall -c -o writer.o writer.c
	gcc -g -Wall -I/ writer.o -o writer
endif
	@ chmod 777 ./writer
    
clean :
	rm -f *.o *.elf *.map *.S writer
