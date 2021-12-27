# Dumitrescu Andrei 333CC

OFLAGS=-o $@
FILE=json.l
FISIER=./teste/t1l.json

json: json.o 
	g++ -o $@ $^ -lfl

json.o: json.cpp
	g++ -c -g -o $@ $<

json.cpp: $(FILE)
	flex -o$@ $(FILE)

.PHONY: clean

run:
	./json $(FISIER)

clean: 
	rm *.o json.cpp json
