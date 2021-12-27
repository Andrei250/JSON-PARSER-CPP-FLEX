/* Dumitrescu Andrei 333CC */
%{
    #include <vector>
    #include <string>
    #include <stdio.h>
    #include <stdlib.h>
    #include <iostream>
	#include <stack>
	#include <unordered_set>

	/* Variabile CPP*/
	std::stack<int> arrayIndexes;
	std::stack<std::string> levels;
	int level = 0;
	int currentIndex = 0;
	std::string currentNode = "";
	std::string currentValue = "";
	std::stack<std::unordered_set<std::string>> sets;
	std::unordered_set<std::string> currentElements;
	bool isArray = false;

	/* Contruiesc sirul care se va afisa la fiecare
	 * finalizare de obiect. */
	std::string buildOutput() {
		std::string ans = "conține";

		for (auto it : currentElements) {
			if (it != "") {
				ans += " " + it + ",";
			}
		}

		ans.pop_back();

		// salvez stivele
		std::stack<std::string> saved = levels;
		std::string path = "";
		std::stack<int> savedInd = arrayIndexes;

		if (saved.size() >= 1) {
			path = (saved.top() + " ");
			saved.pop();
		}

		// Daca am index de array si -1 atunci scot de 2 ori
		// Explicatia e ca eu la obiect in array retin index
		// si key-ul il retin si pt deschiderea rray-ului.
		// Deci am 2 valori index pentru array si il scot de 2 ori.
		// -1 pt obiect, >= 0 pentru array element
		if (savedInd.size() >= 1) {
			if (savedInd.top() != -1) {
				path += "[" + std::to_string(savedInd.top()) + "] ";
				savedInd.pop();

				if (savedInd.size() >= 1 && savedInd.top() == -1) {
					savedInd.pop();
				}
			} else {
				savedInd.pop();
			}
		}
		

		// Construiesc invers outputul
		while (!saved.empty()) {
			int ind;
			std::string composed = saved.top();

			if (savedInd.size()) {
				ind = savedInd.top();
				savedInd.pop();
			}

			saved.pop();

			while (ind != -1 && savedInd.size()) {
				composed += " [" + std::to_string(ind) + "]";
				ind = savedInd.top();
				savedInd.pop();
			}

			path = (composed + " -> ") + path;

		}

		ans = path + ans;

		return ans;
	}
%}

/* Declarari de patterns */
SYMBOL      [/#/$/%/@/+/./-/_/'/(/)]
DIGIT		[0-9]
WORDPART	([a-zA-Z]|{DIGIT}|{SYMBOL})
WORD        {WORDPART}+
SPACE  		[ \t\r\n/"]
FRACTION 	[/+/-]?({DIGIT}+[/.]{DIGIT}+)
NUMBER		[/+/-]?{DIGIT}+

/* Starile necesare => array, obiect sau valoarea unei chei */
/* STARTARRAY => descrie starea cand se afla la nivelul unui array*/
/* STARTOBEJCT => descrie starea cand se afla la nivelul unui obiect*/
/* KEYVALUE => descrie starea de valoare a unei chei din obiect*/

/* Nu am pus comentarii la toate starile, deoarece unele se repetau*/
/* si nu vedeam rostul sa explic acelasi lucru. Am ales sa se repete, */
/* deoarece este mai usor de urmarit pe stari, acestea fiind pozitionate una*/
/* dupa cealalta. Elementele care se repeta sunt inceputul si sfarsitul de */
/* obiect si array si parsarea numerelor si a stringurilor */

%x STARTARRAY STARTOBJECT KEYVALUE

%%

<INITIAL>{SPACE}* {}
<INITIAL>\{ 	{
	// Inceput de obiect, trece in starea STARTOBJECT

	level++;
	BEGIN(STARTOBJECT);
}
<INITIAL>\[	{
	// Inceput de array, trece in starea STARTARRAY

	isArray = true;
	level++;
	sets.push(currentElements);
	levels.push("");
	arrayIndexes.push(-1);

	currentElements = std::unordered_set<std::string>();

	BEGIN(STARTARRAY);
}

<STARTOBJECT>{SPACE}* 	{}
<STARTOBJECT>{WORDPART}	{
	// Parte dintr-un cuvant. Il bag in currentNode, care este cheia obiectului

	currentNode += std::string(yytext);
}
<STARTOBJECT>\:	{
	// Dupa cheie urmeaza valoare. Tren in starea KEYVALUE

	BEGIN(KEYVALUE);
}
<STARTOBJECT>\[ {
	// Incepe un array. Retin informatiile de pana acum in stive.
	// -1 in index, deoarece este inceput, nu se afla in array.
	// in sets ce valori am avut pana acum in obiect
	// trec in starea STARTARRAY

	level++;
	currentElements.insert("liste");
	arrayIndexes.push(-1);
	sets.push(currentElements);
	currentElements = std::unordered_set<std::string>();

	BEGIN(STARTARRAY);

}
<STARTOBJECT>\{	{
	// La fel ca sus, daor ca acum trebuie sa retin si cheia in stiva levels
	// raman in STARTOBJECT

	currentElements.insert("obiecte");
	level++;
	levels.push(currentNode);
	sets.push(currentElements);
	arrayIndexes.push(-1);
	currentElements = std::unordered_set<std::string>();
	currentNode = "";

	BEGIN(STARTOBJECT);
}
<STARTOBJECT>\} {
	// Daca se inchide un obiect, afisez toata calea pana in acest punct
	// Doar daca currentIndex este scot chei din stiva levels, deoarece
	// altfel poate urma un alt element din array si am nevoie de el.
	// In functie d eindex trec in alte stari

	if (levels.size()) {
		std::cout << buildOutput() << '\n';

		currentNode = "";
		currentIndex = arrayIndexes.top() + 1;
		arrayIndexes.pop();

		if (sets.size()) {
			currentElements = sets.top();
			sets.pop();
		} else {
			currentElements = std::unordered_set<std::string>();
		}

		level--;

		if (currentIndex == 0) {
			levels.pop();

			BEGIN(STARTOBJECT);
		} else {
			BEGIN(STARTARRAY);	
		}

	}
}
<STARTOBJECT>\] {
	// Stare care nu influenteaza

	currentNode = "";
}
<STARTOBJECT>\, {
	// Retin tipul elementelor de pana acum, deoarece sunt separate
	// prin virgula

	currentElements.insert(currentValue);
}

<STARTARRAY>\: {}
<STARTARRAY>{SPACE}* {}
<STARTARRAY>(null|NULL|"NULL"|"null") {
	// avem null

	if (currentValue == "") {
		currentValue = "null";
	}
}
<STARTARRAY>{FRACTION}|{NUMBER}  {
	// Avem numar in array

	if (currentValue == "") {
		currentValue = "numere";
	} else if (currentValue == "numere" &&
		((std::string(yytext))[0] == '-' ||
		(std::string(yytext))[0] == '+')) {
		currentValue = "siruri";
	}
}
<STARTARRAY>(true|TRUE|"TRUE"|"true"|false|FALSE|"FALSE"|"false") {
	// avem boolean

	if (currentValue == "") {
		currentValue = "booleeni";
	}
}
<STARTARRAY>{WORDPART}			{
	// avem doar un sir

	currentValue = "siruri";
}
<STARTARRAY>\- {}
<STARTARRAY>\[ 	{
	// aceeasi explicatie ca la STARTOBEJCT

	level++;
	sets.push(currentElements);
	arrayIndexes.push(currentIndex);

	currentElements = std::unordered_set<std::string>();
	currentIndex = 0;
	currentValue = "";

	BEGIN(STARTARRAY);
 }
<STARTARRAY>\{	{
	// aceeasi explicatie ca la STARTOBJECT
	// Insa de data aceasta nu mai punem cheia inca o data,
	// deoarece daca o punem de fiecare data este duplicata in stiva

	currentElements.insert("obiecte");
	currentElements.insert(currentValue);

	level++;
	sets.push(currentElements);
	arrayIndexes.push(currentIndex);

	currentElements = std::unordered_set<std::string>();
	currentNode = "";
	currentIndex = 0;
	currentValue = "";

	BEGIN(STARTOBJECT);
}
<STARTARRAY>\}	{
	// aceeasi explicatie ca la STARTOBEJCT

	if (sets.size()) {
		std::cout << buildOutput() << '\n';

		currentValue = "";
		currentNode = "";
		currentIndex = arrayIndexes.top() + 1;
		arrayIndexes.pop();

		if (sets.size()) {
			currentElements = sets.top();
			sets.pop();
		} else {
			currentElements = std::unordered_set<std::string>();
		}

		level--;

		if (currentIndex == 0) {
			BEGIN(STARTOBJECT);
		} else {
			BEGIN(STARTARRAY);
		}
	}
}
<STARTARRAY>\] {
	// Aceeasi explicatie ca la STARTOBJECT

	currentValue = "";
	currentNode = "";
	currentIndex = arrayIndexes.top() + 1;
	arrayIndexes.pop();

	if (sets.size()) {
		currentElements = sets.top();
		sets.pop();
	} else {
		currentElements = std::unordered_set<std::string>();
	}

	if (currentIndex == 0) {
		levels.pop();

		BEGIN(STARTOBJECT);
	} else {
		BEGIN(STARTARRAY);
	}
}
<STARTARRAY>\, {}

<KEYVALUE>{SPACE}* {}
<KEYVALUE>(null|NULL|"NULL"|"null") {
	if (currentValue == "") {
		currentValue = "null";
	}
}
<KEYVALUE>{FRACTION}|{NUMBER}  {
	if (currentValue == "") {
		currentValue = "numere";
	} else if (currentValue == "numere" &&
		((std::string(yytext))[0] == '-' ||
		(std::string(yytext))[0] == '+')) {
		currentValue = "siruri";
	}
}
<KEYVALUE>(true|TRUE|"TRUE"|"true"|false|FALSE|"FALSE"|"false") {
	if (currentValue == "") {
		currentValue = "booleeni";
	}
}
<KEYVALUE>{WORDPART} 	{
	currentValue = "siruri";
}
<KEYVALUE>\- {}
<KEYVALUE>\: {}
<KEYVALUE>\,			{
	// Daca avem virgula, urmeaza alt obiect, deci trecem iar in STARTOBJECT

	currentElements.insert(currentValue);
	currentValue = "";
	currentNode = "";

	BEGIN(STARTOBJECT);
}
<KEYVALUE>\[			{
	currentElements.insert("liste");
	currentElements.insert(currentValue);

	level++;
	levels.push(currentNode);
	sets.push(currentElements);
	arrayIndexes.push(-1);

	currentElements = std::unordered_set<std::string>();
	currentNode = "";
	currentIndex = 0;
	currentValue = "";

	BEGIN(STARTARRAY);
}
<KEYVALUE>\{			{
	currentElements.insert(currentValue);
	currentElements.insert("obiecte");

	level++;
	levels.push(currentNode);
	sets.push(currentElements);
	arrayIndexes.push(-1);

	currentElements = std::unordered_set<std::string>();
	currentNode = "";
	currentIndex = 0;
	currentValue = "";

	BEGIN(STARTOBJECT);
}
<KEYVALUE>\}			{
	currentElements.insert(currentValue);

	if (levels.size()) {
		std::cout << buildOutput() << '\n';

		currentNode = "";
		currentValue = "";
		currentIndex = arrayIndexes.top() + 1;
		arrayIndexes.pop();

		if (sets.size()) {
			currentElements = sets.top();
			sets.pop();
		} else {
			currentElements = std::unordered_set<std::string>();
		}

		level--;

		if (currentIndex == 0) {
			levels.pop();

			BEGIN(STARTOBJECT);
		} else {
			BEGIN(STARTARRAY);
		}

	}
}


.|{SPACE}*	{}

%%


int main(int argc, char** argv){
	if (argc < 2){
		std::cout<< "Mod rulare: ./json test_in" << '\n';
		exit(1);
	}
	yyin = fopen(argv[1], "r");
	yylex();

	// Daca nu se incepe cu array, afisez informatii despre radacina
	if (!isArray) {
		std::cout << "radacina " << buildOutput() << '\n';
	}

	fclose(yyin);
	return 0;
}