LIBS =
LIB_DIR =
FLAGS = -O3 -Wall -D_GNU_SOURCE

.PHONY: clean all

all: fast slow matriz matriztrasp

fast: fast.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

slow: slow.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

matriz: matriz.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

matriztrasp: matriztrasp.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

clean:
	rm -f *.o *~ fast slow matriz matriztrasp
