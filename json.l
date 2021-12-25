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

		if (saved.size() >= 1) {
			path = (saved.top() + " ");
			saved.pop();
		}

		while (!saved.empty()) {
			path = (saved.top() + " -> ") + path;

			saved.pop();
		}

		ans = path + ans;

		return ans;
	}
%}

/* Declarari de patterns */
SYMBOL      ["#$%@+.-_']
DIGIT		[0-9]
WORDPART	[a-zA-Z]|{DIGIT}|{SYMBOL}
WORD        {WORDPART}+
SPACE  		[ \t\r\n]
FRACTION 	{DIGIT}+[.]{DIGIT}+|["']{DIGIT}+[.]{DIGIT}+["']
NUMBER		{DIGIT}+|["']{DIGIT}+["']

%x STARTARRAY STARTOBJECT KEYVALUE

%%

<INITIAL>{SPACE}*\{{SPACE}* 	{
	level++;

	BEGIN(STARTOBJECT);
}
<INITIAL>{SPACE}*\[{SPACE}* 	{ std::cout << "INCEPUT DE ARRAY\n"; }

<STARTOBJECT>{WORDPART}				{
	currentNode += std::string(yytext);
}
<STARTOBJECT>{SPACE}*\:{SPACE}*		{ BEGIN(KEYVALUE); }
<STARTOBJECT>{SPACE}*\[{SPACE}* 	{ BEGIN(INITIAL); }
<STARTOBJECT>{SPACE}*\{{SPACE}* 	{
	currentElements.insert("obiecte");
	level++;
	levels.push(currentNode);
	sets.push(currentElements);
	currentElements = std::unordered_set<std::string>();
	currentNode = "";

	BEGIN(STARTOBJECT);
}
<STARTOBJECT>{SPACE}*\}{SPACE}*	{
	if (levels.size()) {
		std::cout << buildOutput() << '\n';
		currentNode = levels.top();
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
	
	BEGIN(STARTOBJECT);
}

<KEYVALUE>{SPACE}*(null|NULL|"NULL"|"null"){SPACE}* {
	currentElements.insert("null");
}
<KEYVALUE>{SPACE}*{FRACTION}{SPACE}*|{SPACE}*{NUMBER}{SPACE}*  {
	currentElements.insert("numere");
}
<KEYVALUE>{SPACE}*(true|TRUE|"TRUE"|"true"|false|FALSE|"FALSE"|"false"){SPACE}* {
	currentElements.insert("booleeni");
}
<KEYVALUE>{SPACE}*{WORDPART}{SPACE}* 	{
	currentElements.insert("șiruri");
}
<KEYVALUE>{SPACE}*\,{SPACE}*			{
	currentValue = "";
	currentNode = "";

	BEGIN(STARTOBJECT);
}
<KEYVALUE>{SPACE}*\{{SPACE}*			{
	currentElements.insert("obiecte");
	level++;
	levels.push(currentNode);
	sets.push(currentElements);
	currentElements = std::unordered_set<std::string>();
	currentNode = "";

	BEGIN(STARTOBJECT);
}
<KEYVALUE>{SPACE}*\}{SPACE}*			{
	if (levels.size()) {
		std::cout << buildOutput() << '\n';
		currentNode = levels.top();
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

	BEGIN(STARTOBJECT);
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