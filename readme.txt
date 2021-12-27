Dumitrescu Andrei 333CC

Am considerat ca inputul este VALID.

Ideea temei este sa ma leg de 3 stari alese de mine: STARTARRAY, STARTOBJECT
si KEYVALUE.

De fiecare data cand incepe un caracter '{', trec in starea STARTOBJECT, unde
verific daca urmeaza un array, un alt obiect sau un string ( o cheie).
    - Daca urmeaza un array, trec in starea StartArray (pe care o explc
        in cele ce urmeaza)
    - Daca urmeaza un obiect, raman in aceasta stare
    - Daca urmeaza un string, folosesc patternul WORDPART ( regex ).
    - Dupa string, urmeaza ':', ceea ce ma duce in starea KEYVALUE.

Starea STARTARRAY:

Aici sunt deja intr-un array.
    - Daca urmeaza elemente (numere, cuvinte, etc) atunci doar retin tipul lor
        intr-un set si continui.
    - Daca urmeaza un obiect, trec in starea STARTOBJECT
    - Daca urmeaza final de array, atunci doar scot din stive informatiile
        adunate pe acest nivel.
    - Daca se inchide un obeict ( dintr-o iteratie anteriaora ), atunci
        scot din stiva ce trebuie scos.
    - Daca urmeaza un alt array, revin in starea asta.

Starea KEYVALUE:

Starea aceasta descrie ceea ce se afla dupa ':' la o cheie.
    - Daca este un simplu string retin intr-un set tipul acesteia.
    - Daca este obiect, merg in STARTOBJECT.
    - Daca este array, merg in StartArray.

De fiecare data cand apare '}', afisez informatia de pana acum.
Folosesc o functie facuta in CPP, in care afisez informatiile pana la acel
nivel.

Folosesc 3 stive: sets, levels, arrayInd

sets - retin pentru fiecare nivel (de obiect sau array) ce tipuri de info
        contine ( obiecte, numere, etc )
levels - numele key-urilor de obiect pentru fiecare nivel de adancime
arrayInd - -1 daca este inceput de obiect si >= 0 daca sunt valori index
            are unor array-uri

Astfel, daca dau de '[', adaug -1 ca index si daca in interiorul acestuia
pe nivelul imediat urmator se afla ceva pun valoarea 0, indiferent de tip.
Daca este obiect pun -1 sau valoarea index-ului in caz ca este intr-un array.

La fel si pentru celalalte stive.

Probleme aparute: - Daca puneam in regex spatiile la fiecare tip nu mergeau
                    starile cum trebuia,
                  - Ghilimelele pot fi o problema la aprsare,
                  - Punct si virgula poate incurca la key-uri.

Rezolvare: La fiecare stare daca este spatiu ( \n\t\r si ") atunci nu fac 
            nimic. Am considerat si '"' ca spatii pentru a nu fi nevoie
            sa le sterg sau sa scap cumva de ele in parsare. Este o modalitate
            mai usoara de a scapa de ele, folosind puterea FLEX.
            La punct si virjula treceam in starea KEYVALUE.

La rularea make se compileaza fisierul.
Am pus si regula run, insa trebuie schimbat mereu variabila FISIER.

In directorul teste se afla testele default si 3 teste facute de mine:
    - self.json
    - self1.json
    - self2.json

make clean pentru a sterge executabilele.
