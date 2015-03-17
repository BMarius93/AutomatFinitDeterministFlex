CC = gcc
CFLAGS = -Wall -g

all: build

lexer.c: lexer.lex
	flex --outfile=$@ $<

build: lexer

lexer: lexer.o 
	$(CC) $(CFLAGS) -o $@ $^ -lfl

.PHONY: clean

run: build
	./lexer

clean:
	rm -f *.o *~ lexer.c lexer
