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
				savedInd.pop();
			}
		}

		while (!saved.empty()) {
			int ind = savedInd.top();
			std::string composed = saved.top();

			saved.pop();
			savedInd.pop();

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
FRACTION 	[+-]?{DIGIT}+[.]{DIGIT}+
NUMBER		[+-]?{DIGIT}+

%x STARTARRAY STARTOBJECT KEYVALUE

%%

<INITIAL>{SPACE}* {}
<INITIAL>\{ 	{
	level++;
	BEGIN(STARTOBJECT);
}
<INITIAL>\[	{ 
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
	level++;
	currentElements.insert("liste");
	arrayIndexes.push(-1);
	sets.push(currentElements);
	currentElements = std::unordered_set<std::string>();

	BEGIN(STARTARRAY);
}
<STARTOBJECT>\{	{
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
	if (levels.size()) {
		std::cout << buildOutput() << '\n';

		currentNode = levels.top();
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
		}

		BEGIN(STARTARRAY);
	} else {
		std::cout << "radacina " << buildOutput() << '\n';
	}
}
<STARTOBJECT>\] {}
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
	level++;
	currentElements.insert("liste");
	sets.push(currentElements);
	arrayIndexes.push(currentIndex);
	currentElements = std::unordered_set<std::string>();

	BEGIN(STARTARRAY);
 }
<STARTARRAY>\{	{
	currentElements.insert("obiecte");
	level++;
	levels.push(currentNode);
	sets.push(currentElements);
	arrayIndexes.push(currentIndex);
	currentElements = std::unordered_set<std::string>();
	currentNode = "";
	currentIndex = 0;

	BEGIN(STARTOBJECT);
}
<STARTARRAY>\}	{
	if (levels.size()) {
		std::cout << buildOutput() << '\n';

		currentNode = levels.top();
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
		}

		BEGIN(STARTARRAY);
	} else {
		std::cout << "radacina " << buildOutput() << '\n';
	}
}
<STARTARRAY>\] {
	currentIndex = arrayIndexes.top() + 1;
	arrayIndexes.pop();

	if (sets.size()) {
		currentElements = sets.top();
		sets.pop();
	} else {
		currentElements = std::unordered_set<std::string>();
	}

	if (currentIndex == 0) {
		BEGIN(STARTOBJECT);
	}

	BEGIN(STARTARRAY);
}
<STARTARRAY>\, {}

<KEYVALUE>{SPACE}* {}
<KEYVALUE>(null|NULL|"NULL"|"null") {
	currentElements.insert("null");
}
<KEYVALUE>{FRACTION}|{NUMBER}  {
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
	level++;
	currentElements.insert("liste");
	sets.push(currentElements);
	arrayIndexes.push(-1);
	currentElements = std::unordered_set<std::string>();
	currentIndex = 0;

	BEGIN(STARTARRAY);
}
<KEYVALUE>\{			{
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
	if (levels.size()) {
		std::cout << buildOutput() << '\n';

		currentNode = levels.top();
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
		}

		BEGIN(STARTARRAY);
	} else {
		std::cout << "radacina " << buildOutput() << '\n';
	}
}


.|{SPACE}*           			{}

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