%{
    #include <vector>
    #include <string>
    #include <stdio.h>
    #include <stdlib.h>
    #include <iostream>
	#include <stack>
	#include <unordered_set>
	#include <fstream>

	std::ofstream g("a.out");

	/* Variabile CPP*/
	std::stack<int> arrayIndexes;
	std::stack<std::string> levels;
	int level = 0;
	int currentIndex = 0;
	std::string currentNode = "";
	std::string currentValue = "";
	std::stack<std::unordered_set<std::string>> sets;
	std::unordered_set<std::string> currentElements;

	std::string buildOutput() {
		std::string ans = "conține";

		for (auto it : currentElements) {
			ans += " " + it + ",";
		}

		ans.pop_back();

		std::stack<std::string> saved = levels;
		std::string path = "";
		std::stack<int> savedInd = arrayIndexes;

		if (saved.size() >= 1) {
			path = (saved.top() + " ");
			saved.pop();

			if (savedInd.size() >= 1) {
				if (savedInd.top() != -1) {
					path += "[" + std::to_string(savedInd.top()) + "] ";
				}

				savedInd.pop();
			}
		}

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
SYMBOL      [/#/$/%/@/+/./-/_/']
DIGIT		[0-9]
WORDPART	([a-zA-Z]|{DIGIT}|{SYMBOL})
WORD        {WORDPART}+
SPACE  		[ \t\r\n/"]
FRACTION 	[/+/-]?{DIGIT}+[/.]{DIGIT}+
NUMBER		[/+/-]?{DIGIT}+

%x STARTARRAY STARTOBJECT KEYVALUE

%%

<INITIAL>{SPACE}* {}
<INITIAL>\{ 	{
	g << "INITIAL object open\n";
	level++;
	BEGIN(STARTOBJECT);
}
<INITIAL>\[	{ 
	g << "INITIAL array open\n";

	level++;
	BEGIN(STARTARRAY);
}

<STARTOBJECT>{SPACE}* 	{}
<STARTOBJECT>{WORDPART}	{
	currentNode += std::string(yytext);
}
<STARTOBJECT>\:	{
	BEGIN(KEYVALUE);
}
<STARTOBJECT>\[ {
	g << "STARTOBJECT array open\n";
	level++;
	currentElements.insert("liste");
	arrayIndexes.push(-1);
	sets.push(currentElements);
	currentElements = std::unordered_set<std::string>();

	BEGIN(STARTARRAY);
}
<STARTOBJECT>\{	{
	g << "startobject object open\n";
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
	g << "startobject object close\n";
	if (levels.size()) {
		std::cout << buildOutput() << '\n';

		currentNode = levels.top();
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

	} else {
		std::cout << "radacina " << buildOutput() << '\n';
	}
}
<STARTOBJECT>\] {g << "startobject array close\n";}
<STARTOBJECT>\, {}

<STARTARRAY>\: {}
<STARTARRAY>{SPACE}* {}
<STARTARRAY>(null|NULL|"NULL"|"null") {
	currentElements.insert("null");
}
<STARTARRAY>{FRACTION}|{NUMBER}  {
	currentElements.insert("numere");
}
<STARTARRAY>(true|TRUE|"TRUE"|"true"|false|FALSE|"FALSE"|"false") {
	currentElements.insert("booleeni");
}
<STARTARRAY>{WORDPART}			{
	currentElements.insert("stringuri");
}
<STARTARRAY>\[ 	{
	g << "startarray array open\n";
	level++;
	sets.push(currentElements);
	arrayIndexes.push(currentIndex);

	currentElements = std::unordered_set<std::string>();
	currentIndex = 0;

	BEGIN(STARTARRAY);
 }
<STARTARRAY>\{	{
	g << "startarray object open\n";
	currentElements.insert("obiecte");

	level++;
	sets.push(currentElements);
	arrayIndexes.push(currentIndex);

	currentElements = std::unordered_set<std::string>();
	currentNode = "";
	currentIndex = 0;

	BEGIN(STARTOBJECT);
}
<STARTARRAY>\}	{
	g << "startarray object close\n";

	if (sets.size()) {
		std::cout << buildOutput() << '\n';

		currentNode = levels.top();
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
	} else {
		std::cout << "radacina " << buildOutput() << '\n';
	}
}
<STARTARRAY>\] {
	g << "startarray array close\n";

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
	currentElements.insert("null");
}
<KEYVALUE>{FRACTION}|{NUMBER}  {
	g << "MORTII MA-TII\n";
	currentElements.insert("numere");
}
<KEYVALUE>(true|TRUE|"TRUE"|"true"|false|FALSE|"FALSE"|"false") {
	currentElements.insert("booleeni");
}
<KEYVALUE>{WORDPART} 	{
	currentElements.insert("șiruri");
}
<KEYVALUE>\,			{
	currentValue = "";
	currentNode = "";

	BEGIN(STARTOBJECT);
}
<KEYVALUE>\[			{
	g << "keyvalue array open\n";

	currentElements.insert("liste");

	level++;
	levels.push(currentNode);
	sets.push(currentElements);
	arrayIndexes.push(-1);

	currentElements = std::unordered_set<std::string>();
	currentNode = "";
	currentIndex = 0;

	BEGIN(STARTARRAY);
}
<KEYVALUE>\{			{
	g << "keyvalue object open\n";

	currentElements.insert("obiecte");

	level++;
	levels.push(currentNode);
	sets.push(currentElements);
	arrayIndexes.push(-1);

	currentElements = std::unordered_set<std::string>();
	currentNode = "";
	currentIndex = 0;

	BEGIN(STARTOBJECT);
}
<KEYVALUE>\}			{
	g << "keyvalue object close\n";

	if (levels.size()) {
		std::cout << buildOutput() << '\n';

// #########################################################################################
		currentNode = "";
		currentIndex = arrayIndexes.top() + 1;
		arrayIndexes.pop();
		levels.pop();

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

	} else {
		std::cout << "radacina " << buildOutput() << '\n';
	}
}


.|{SPACE}*           			{g << "ORICE ALTCEVA\n";}

%%


int main(int argc, char** argv){
	if (argc < 2){
		std::cout<< "Mod rulare: ./json test_in" << '\n';
		exit(1);
	}
	yyin = fopen(argv[1], "r");
	yylex();

	fclose(yyin);
	return 0;
}