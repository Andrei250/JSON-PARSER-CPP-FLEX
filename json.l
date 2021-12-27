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
			}

			savedInd.pop();
		}

		if (savedInd.size() >= 1 && savedInd.top() == -1) {
			savedInd.pop();
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

	void afiseaza() {
		std::stack<std::unordered_set<std::string>> s1 = sets;
		std::stack<std::string> s2 = levels;
		std::stack<int> s3 = arrayIndexes;

		g << "LEVELS: ";

		while (!s2.empty()) {
			g << s2.top() << " ";
			s2.pop();
		}

		g << '\n';

		g << "Indexes: ";

		while (!s3.empty()) {
			g << s3.top() << " ";
			s3.pop();
		}

		g << "\nSets\n";

		while (!s1.empty()) {
			std::unordered_set<std::string> st = s1.top();
			s1.pop();

			for (auto it : st) {
				g << it << " ";
			}

			g << '\n';
		}

		g << '\n';
	}

%}

/* Declarari de patterns */
SYMBOL      [/#/$/%/@/+/./-/_/']
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
	g << "INITIAL object open\n";
	afiseaza();
	level++;
	BEGIN(STARTOBJECT);
}
<INITIAL>\[	{ 
	g << "INITIAL array open\n";
	isArray = true;
	level++;
	sets.push(currentElements);
	levels.push("");
	arrayIndexes.push(-1);

	currentElements = std::unordered_set<std::string>();

	BEGIN(STARTARRAY);
	afiseaza();

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
	afiseaza();

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
	afiseaza();

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

	}
	afiseaza();

}
<STARTOBJECT>\] {
	g << "startobject array close\n";
	afiseaza();
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
	g << "startarray array open\n";


	level++;
	sets.push(currentElements);
	arrayIndexes.push(currentIndex);

	currentElements = std::unordered_set<std::string>();
	currentIndex = 0;
	currentValue = "";

	BEGIN(STARTARRAY);
	afiseaza();

 }
<STARTARRAY>\{	{
	g << "startarray object open\n";


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
	afiseaza();

}
<STARTARRAY>\}	{
	g << "startarray object close\n";

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
	afiseaza();

}
<STARTARRAY>\] {
	g << "startarray array close\n";

	currentValue = "";
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
	afiseaza();

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
<KEYVALUE>\,			{
	currentElements.insert(currentValue);
	currentValue = "";
	currentNode = "";

	BEGIN(STARTOBJECT);
}
<KEYVALUE>\[			{
	g << "keyvalue array open\n";

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
	afiseaza();

}
<KEYVALUE>\{			{
	g << "keyvalue object open\n";

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
	afiseaza();

}
<KEYVALUE>\}			{
	g << "keyvalue object close\n";

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
	afiseaza();

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

	if (!isArray) {
		std::cout << "radacina " << buildOutput() << '\n';
	}

	fclose(yyin);
	return 0;
}