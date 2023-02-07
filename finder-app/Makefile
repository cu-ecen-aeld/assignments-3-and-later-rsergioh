all: writer

writer.o : writer.c
	$(CC) $(CCFLAGS) -c writer.c
writer : writer.o
	$(CC) $(LDFLAGS) writer.o -o writer
    
clean :
	$(RM) -f *.o *.elf *.map *.S writer
