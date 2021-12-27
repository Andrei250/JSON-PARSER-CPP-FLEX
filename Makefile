CC=g++
LEX=flex
LDFLAGS=-lfl
CFLAGS=-c -g
OFLAGS=-o $@
SRC=json.l

json: json.o 
	$(CC) -o $@ $^ $(LDFLAGS)

json.o: json.cpp
	$(CC) $(CFLAGS) -o $@ $<

json.cpp: $(SRC)
	$(LEX) -o$@ $(SRC)

.PHONY: clean

clean: 
	rm *~ *.o json.cpp json