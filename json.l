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
			savedInd.pop();
		}

		while (!saved.empty()) {
			int ind = savedInd.top();
			std::string composed = saved.top();

			saved.pop();
			savedInd.pop();

			while (ind != -1) {
				composed += " [" + std::to_string(ind + '0') + "]";
				ind = savedInd.top();
				savedInd.pop();
			}

			path = (composed + " -> ") + path;

		}

		ans = path + ans;

		return ans;
	}

	void printStuf() {
		std::stack<int> savedInd = arrayIndexes;

		while (savedInd.size()) {
			g << savedInd.top() << " ";
			savedInd.pop();
		}

		g << '\n';
	}
%}

/* Declarari de patterns */
SYMBOL      ["#$%@+.-_']
DIGIT		[0-9]
WORDPART	([a-zA-Z]|{DIGIT}|{SYMBOL})
WORD        {WORDPART}+
SPACE  		[ \t\r\n]
FRACTION 	{DIGIT}+[.]{DIGIT}+|["']{DIGIT}+[.]{DIGIT}+["']
NUMBER		{DIGIT}+|["']{DIGIT}+["']

%x STARTARRAY STARTOBJECT KEYVALUE

%%

<INITIAL>{SPACE}*\{{SPACE}* 	{
	level++;
	g << std::string(yytext) << " 91\n";
	BEGIN(STARTOBJECT);
}
<INITIAL>{SPACE}*\[{SPACE}* 	{ 
	level++;
	g << std::string(yytext) << " 96\n";
	BEGIN(STARTARRAY);
}

<STARTOBJECT>{WORDPART}				{
	currentNode += std::string(yytext);
	g << std::string(yytext) << " 101\n";
}
<STARTOBJECT>{SPACE}*\:{SPACE}*		{
	g << std::string(yytext) << " 105\n";
	BEGIN(KEYVALUE);
}
<STARTOBJECT>{SPACE}*\[{SPACE}* 	{
	g << std::string(yytext) << " 109\n";
	level++;
	currentElements.insert("liste");
	arrayIndexes.push(-1);
	sets.push(currentElements);
	currentElements = std::unordered_set<std::string>();

	printStuf();
	g << "STARTOBJECT [\n";

	BEGIN(STARTARRAY);
}
<STARTOBJECT>{SPACE}*\{{SPACE}* 	{
	g << std::string(yytext) << " 122\n";
	currentElements.insert("obiecte");
	level++;
	levels.push(currentNode);
	sets.push(currentElements);
	arrayIndexes.push(-1);
	currentElements = std::unordered_set<std::string>();
	currentNode = "";

	printStuf();
	g << "STARTOBJECT acolada \n";

	BEGIN(STARTOBJECT);
}
<STARTOBJECT>{SPACE}*\}{SPACE}*	{
	g << std::string(yytext) << " 137\n";
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
	} else {
		std::cout << "radacina " << buildOutput() << '\n';
	}
	
	if (currentIndex - 1 != -1) {
		BEGIN(STARTARRAY);
	}

	BEGIN(STARTOBJECT);
}
<STARTOBJECT>{SPACE}*\,{SPACE}* {g << std::string(yytext) << " 164\n";}

<STARTARRAY>{SPACE}*(null|NULL|"NULL"|"null"){SPACE}* {
	g << std::string(yytext) << " 166\n";
	currentElements.insert("null");
}
<STARTARRAY>{SPACE}*{FRACTION}{SPACE}*|{SPACE}*{NUMBER}{SPACE}*  {
	g << std::string(yytext) << " 171\n";
	currentElements.insert("numere");
}
<STARTARRAY>{SPACE}*(true|TRUE|"TRUE"|"true"|false|FALSE|"FALSE"|"false"){SPACE}* {
	g << std::string(yytext) << " 174\n";
	currentElements.insert("booleeni");
}
<STARTARRAY>{WORDPART}			{
	g << std::string(yytext) << " 179\n";
	currentElements.insert("stringuri");
}
<STARTARRAY>{SPACE}*\[{SPACE}* 	{
	g << std::string(yytext) << " 182\n";
	level++;
	currentElements.insert("liste");
	sets.push(currentElements);
	arrayIndexes.push(currentIndex);
	currentElements = std::unordered_set<std::string>();

	printStuf();
	g << "array [\n";

	BEGIN(STARTARRAY);
 }
<STARTARRAY>{SPACE}*\{{SPACE}* 	{
	g << std::string(yytext) << " 195\n";
	currentElements.insert("obiecte");
	level++;
	levels.push(currentNode);
	sets.push(currentElements);
	arrayIndexes.push(0);
	currentElements = std::unordered_set<std::string>();
	currentNode = "";

	printStuf();
	g << "array acolada\n";

	BEGIN(STARTOBJECT);
}
<STARTARRAY>{SPACE}*\}{SPACE}*	{
	g << std::string(yytext) << " 211\n";
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
	} else {
		std::cout << "radacina " << buildOutput() << '\n';
	}
	
	if (currentIndex - 1 != -1) {
		BEGIN(STARTARRAY);
	}

	BEGIN(STARTOBJECT);
}
<STARTARRAY>{SPACE}*\]{SPACE}* {
	g << std::string(yytext) << " 239\n";
	currentIndex = arrayIndexes.top() + 1;
	arrayIndexes.pop();

	if (sets.size()) {
		currentElements = sets.top();
		sets.pop();
	} else {
		currentElements = std::unordered_set<std::string>();
	}
}
<STARTARRAY>{SPACE}*\,{SPACE}* {g << std::string(yytext) << " 250\n";}

<KEYVALUE>{SPACE}*(null|NULL|"NULL"|"null"){SPACE}* {
	g << std::string(yytext) << " 253\n";
	currentElements.insert("null");
}
<KEYVALUE>{SPACE}*{FRACTION}{SPACE}*|{SPACE}*{NUMBER}{SPACE}*  {
	g << std::string(yytext) << " 257\n";
	currentElements.insert("numere");
}
<KEYVALUE>{SPACE}*(true|TRUE|"TRUE"|"true"|false|FALSE|"FALSE"|"false"){SPACE}* {
	g << std::string(yytext) << " 260\n";
	currentElements.insert("booleeni");
}
<KEYVALUE>{SPACE}*{WORDPART}{SPACE}* 	{
	g << std::string(yytext) << " 265\n";
	currentElements.insert("șiruri");
}
<KEYVALUE>{SPACE}*\,{SPACE}*			{
	g << std::string(yytext) << " 269\n";
	currentValue = "";
	currentNode = "";

	BEGIN(STARTOBJECT);
}
<KEYVALUE>{SPACE}*\[{SPACE}*			{
	g << std::string(yytext) << " 276\n";
	level++;
	currentElements.insert("liste");
	sets.push(currentElements);
	arrayIndexes.push(currentIndex);
	currentElements = std::unordered_set<std::string>();

	printStuf();
	g << "keyvalue [\n";

	BEGIN(STARTARRAY);
}
<KEYVALUE>{SPACE}*\{{SPACE}*			{
	g << std::string(yytext) << " 289\n";
	currentElements.insert("obiecte");
	level++;
	levels.push(currentNode);
	sets.push(currentElements);
	arrayIndexes.push(-1);
	currentElements = std::unordered_set<std::string>();
	currentNode = "";

	printStuf();
	g << "keyvalue acolada\n";

	BEGIN(STARTOBJECT);
}
<KEYVALUE>{SPACE}*\}{SPACE}*			{
	g << std::string(yytext) << " 304\n";
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
	} else {
		std::cout << "radacina " << buildOutput() << '\n';
	}
	
	if (currentIndex - 1 != -1) {
		BEGIN(STARTARRAY);
	}

	BEGIN(STARTOBJECT);
}


.|{SPACE}*           			{g << std::string(yytext) << " 333\n";}

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