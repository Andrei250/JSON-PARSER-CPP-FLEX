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

	std::string buildOutput() {
		std::string ans = "conține";

		for (auto it : currentElements) {
			if (it != "") {
				ans += " " + it + ",";
			}
		}

		ans.pop_back();

		std::stack<std::string> saved = levels;
		std::string path = "";
		std::stack<int> savedInd = arrayIndexes;

		if (saved.size() >= 1) {
			path = (saved.top() + " ");
			saved.pop();
		}

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

%x STARTARRAY STARTOBJECT KEYVALUE

%%

<INITIAL>{SPACE}* {}
<INITIAL>\{ 	{
	level++;
	BEGIN(STARTOBJECT);
}
<INITIAL>\[	{
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
	currentNode = "";
}
<STARTOBJECT>\, {
	currentElements.insert(currentValue);
}

<STARTARRAY>\: {}
<STARTARRAY>{SPACE}* {}
<STARTARRAY>(null|NULL|"NULL"|"null") {
	if (currentValue == "") {
		currentValue = "null";
	}
}
<STARTARRAY>{FRACTION}|{NUMBER}  {
	if (currentValue == "") {
		currentValue = "numere";
	} else if (currentValue == "numere" &&
		((std::string(yytext))[0] == '-' ||
		(std::string(yytext))[0] == '+')) {
		currentValue = "siruri";
	}
}
<STARTARRAY>(true|TRUE|"TRUE"|"true"|false|FALSE|"FALSE"|"false") {
	if (currentValue == "") {
		currentValue = "booleeni";
	}
}
<STARTARRAY>{WORDPART}			{
	currentValue = "siruri";
}
<STARTARRAY>\- {}
<STARTARRAY>\[ 	{
	level++;
	sets.push(currentElements);
	arrayIndexes.push(currentIndex);

	currentElements = std::unordered_set<std::string>();
	currentIndex = 0;
	currentValue = "";

	BEGIN(STARTARRAY);
 }
<STARTARRAY>\{	{
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

	if (!isArray) {
		std::cout << "radacina " << buildOutput() << '\n';
	}

	fclose(yyin);
	return 0;
}