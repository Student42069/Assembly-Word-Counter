; ************************************************************
;       Programme: compterMots.pep     version PEP8.2 sous Windows
;
;       INF2171 - TP1
;       Un programme qui prend un un texte en entree et affiche le 
;       le nombre de mots commencant par chaque lettre de l'alphabet,
;       le nombre de mots total, les 10 premiers caracteres et le texte entree.
;
;       auteur:         Leonid Glazyrin
;       code permanent: GLAL77080105
;       courriel:       de891974@ens.uqam.ca
;       date:           7/13/2022
;       cours:          INF2171
; ***********************************************************
;
         LDA     0,i
         LDX     0,i
;-----------------------------------------------------
main:    LDA     sizeTamp,i  ;A = tailles tampon
         LDX     buffTxt,i   ;X = adresse du tampon
         CALL    saisir      ;saisir()
         LDX     buffTxt,i   ;A contient dela le nombre de caracter a imprimer
         STRO    msgTxtI,d   ;X adresse du tampon
         CALL    affTxt      ;afficher()1
         CHARO   '\n',i
         LDX     buffTxt,i
         LDA     10,i
         STRO    msgDix,d
         CALL    affTxt      ;afficher()2
         CHARO   '\n',i
         LDX     buffTxt,i   ;X = adresse du tampon
         LDA     cmps,i      ;A = adresse du tableau des comptes
         CALL    compter     ;compter()
         STA     cptWord,d   ;stocker le nombre de mots
         BREQ    fin         ;if(cptWord == 0) break
         CHARO   '\n',i
         STRO    msgCpt,d
         DECO    cptWord,d
         STRO    msgCptF,d
         LDX     cmps,i      ;X = adresse du tableau des comptes
         LDA     sizeTab,i   ;A = longeur de ce tableau
         CALL    afTbSZ      ;afTbSZ()
fin:     STOP
;------------------------------------------------------
; Variable << Locales >> du main() et Constantes
;
cptWord: .WORD   0           ;Contient le nombre de mots
sizeTamp:.EQUATE 100         ;taille du buffer
sizeTab: .EQUATE 26          ;taille du tableau des compteurs
;--------------------------------------------------------
;
; saisir:permet de stocker dans le tampon buffTxt un texte (100 octets)
;        la fin est indiquee par \n\n
; IN:    A = taille du tampon
;        X = adresse du tampon buffText
; OUT:   A = Le nombre d'octets utilise du tampon
; ERR:   S'il y a debordement du tampon l'execution s'arrete
;        et un message correspondant est affiche
saisir:  STX     adrTamp,d 
         STA     size,d 
         LDA     0,i
loop1:   CHARI   0,x         ;buffTxt[X] = charIn()
         LDBYTEA 0,x
         CPA     '\n',i      ;si saut de ligne
         BREQ    checkN      ;on regarde si caracter avant ete un saut de ligne
         CPA     '\x00',i    ;ces deux ligne au cas ou, de ce que j'ai compris des consignes
         BREQ    finLect
         BR      noN         ;sinon
checkN:  CPX     adrTamp,d   ;si premier caracter du buffer pas besoin
         BRLT    noN         ;de verifier donc on passe au prochain
         SUBX    1,i         ;sinon X = X - 1
         LDBYTEA 0,x         ;buffTxt.charAt(X - 1)
         CPA     '\n',i      ;si saut de ligne
         BREQ    finLect     ;on termine la lecture
         ADDX    1,i         ;sinon on remet X a l'indice qu'il avait avant de verifier
noN:     ADDX    1,i         ; X = X + 1 pour incremente l'indice de buffTxt
         LDA     longUsed,d
         ADDA    1,i         ;incremente le nombre d'octets utilise
         STA     longUsed,d
         CPA     size,d      ;if(longUsed == taille du tampon)
         BRNE    loop1       ;else on va au prohchain caractere
         BREQ    debord      ;break(debordement)
finLect: ADDX    1,i
         LDA     0,i         ;a la fin de la lecture on ajoute un caractere null
         STBYTEA 0,x         ;remplace aussi le dernier \n par \x00
         LDA     longUsed,d  ;valeur de retour est nombre octets utilisees
         RET0                ;return
debord:  CHARO   '\n',i      ;err debordement
         STRO    msgDebor,d
         STOP
;--------------------------------------------------------
; Variables << Locales >> de saisir()
;
adrTamp: .WORD   0           ;adresse du tampon d'entree
longUsed:.WORD   0           ;nombre d'octet utilise
size:    .WORD   0           ;taille du tampon d'entree
;--------------------------------------------------------
;
; affTxt:affiche un certain nombre de caractere d'un texte
; IN:    A = nombre d'octets a afficher
;        X = adresse du tampon
affTxt:  NOP0                ;pour l'etiquette de nom de methode
loop2:   CHARO   0,x         ;print(buffTxt[X])
         ADDX    1,i         ;X += 1
         SUBA    1,i         ;A -= 1
         BREQ    finLoop2    ;termier quand nombre d'octets a afficher est 0
         BR      loop2
finLoop2:RET0                ;return
;--------------------------------------------------------
;
; compter: compte combien de mots commencent par chaque lettre de 
;          l'alphabet et retourne le nobre total de mots, je definis
;          un mot etant une lettre non-precede par une lettre.
; IN:    X = adresse du tampon
;        A = adresse du tableau des comptes des lettres
; OUT:   A = Le nombre de mots dans le texte
compter: STX     adTamp,d
         STA     adCompt,d   
         BR      noLoop      ;premiere fois on n'increment pas
loop3:   ADDX    1,i         ;aller au prochain caractere
noLoop:  LDA     0,i         ;s'assurer que A est a \x0000
         LDBYTEA 0,x         ;charger un caractere
         CPA     '\x00',i    ;si null on arrete de compter
         BREQ    finCompt    ;et break
         ANDA    0x00DF,i    ;mettre le caractere en majusclule si pas lettre pas grave
         STBYTEA letter,d    ;enrigistrer le caractere
         CALL    lettre
         CPA     1,i         ;si caractere est une lettre
         BRNE    loop3       ;sinon
         CPX     adTamp,d    ;si cest une lettre ET c'est le premier caracter cest un mot
         BREQ    firstLet    ;pas besoin de verifier le caractere precedant.
         SUBX    1,i         ;on va voir caracter precedant
         LDA     0,i         ;nettoyer A
         LDBYTEA 0,x         ;charger ce caractere precedant
         ADDX    1,i         ;+1 a X car on avait -1, trois ligne plus haut
         CALL    lettre      ;verifier si c'etait une lettre
         CPA     1,i         ;si c'etait aussi une lettre rien de speciale on continue
         BREQ    loop3       ;sinon c'est un nouveau mot 
firstLet:STX     addBefCo,d  ;sauvegarder l'adresse ou on est dans buffTxt(adTamp)
         LDX     0,i         ;nettoyer X
         LDBYTEX letter,d
         SUBX    'A',i       ;pour avoir l'index de cette lettre dans l'alphabet
         ASLX                ;*2 car c'est des nombres
         ADDX    adCompt,d   ;+ adresse du tableau des compteurs
         LDA     0,x         ;charger la valeur deja la
         ADDA    1,i         ;+1
         STA     0,x         ;sauvegarder
         LDA     numWords,d
         ADDA    1,i         ;increment le nombre de mots
         STA     numWords,d
         LDX     addBefCo,d  ;remettre X a l'adresse dans buffTxt et non cmps
         ADDX    1,i         ;incremente +1
         BR      loop3
finCompt:LDA     numWords,d  ;valeur de retour est le nombre de mots
         RET0                ;return
;--------------------------------------------------------
; Variables << Locales >> de compter()
;
adTamp:  .WORD   0           ;adresse du tampon d'entree
adCompt: .WORD   0           ;adresse du tableau des comptes 
numWords:.WORD   0           ;nombre de mots
letter:  .BLOCK  1           ;caractere courant
addBefCo:.WORD   0           ;adressee du buffTxt avant de travailler avec adresse dans tableau des comptes
;--------------------------------------------------------
;
; lettre:retourne si un CHAR donnee est une lettre entre a et z.
; IN:    A = code ASCII d'un CHAR
; OUT:   A = 1 si c'est une lettre en a-z ou A-Z, -1 sinon.
lettre:  ANDA    0x00DF,i    ;mettre la lettre en majuscule
         CPA     'A',i
         BRLT    pasLett     ;if < 'A' break
         CPA     'Z',i
         BRGT    pasLett     ;if > 'Z' break
         LDA     1,i         ;return 1
         RET0
pasLett: LDA     -1,i         ;return -1
         RET0
;
; afTbSZ:affiche le compte de chaque lettre s'il est different de zero
;        accompagne de la lettre associee.
; IN:    X = adresse d'un tableau
;        A = nombre d'elements dans ce tableau
afTbSZ:  STA     nbElem,d 
         STX     addTabL,d 
         ADDX    nbElem,d    ;addresse de fin du tableau des compteurs
         ADDX    nbElem,d    ;est l'addresse de debut + 2*(nbElement)
         STX     addFinTb,d  ;car 1 elent prend 2 octets
         LDX     addTabL,d
while:   CPX     addFinTb,d  ;si on est rendu a la fin du tableau
         BREQ    endWhile    ;break
         LDA     0,x         ;A = cmps[X]
         STA     occur,d     ;occur = A
;---------
         LDA     iLettre,d
         ADDA    1,i         ;incrementer l'index de l'alphabet de 1
         STA     iLettre,d
;---------
         ADDX    2,i         ;incremente l'adresse de cmps de 2 car cest des nombres
;---------
         LDA     occur,d     ;A = occur
         BREQ    while       ;if(occur == 0) on affiche rien
;---------
         LDA     iLettre,d   ;sinon A = index dans l'alphabet
         CALL    afLetTb     ;afLetTb()
         DECO    occur,d     ;print(nombre de fois que cette lettre commencait un mot)
         CHARO   '\n',i
;--------
         BR      while       ;loop
endWhile:RET0                ;return
;--------------------------------------------------------
; Variables << Locales >> de afTbSZ()
;
nbElem:  .WORD   0           ;nombre d'element dans le tableau
occur:   .WORD   0           ;occurence of this letter        
addTabL: .WORD   0           ;adresse du tableau cmps
addFinTb:.WORD   0           ;adresse de la fin du tableau cmps
iLettre: .WORD   0           ;index de lettre dans l'alpahabet [1-26] (simplifier l'incrementation)
;--------------------------------------------------------
;
; afLetTb: affiche une lettre de l'alphabet (ex: 'a/A :')
;        accompagne de la lettre associee.
; IN:    A = index d'une lettre dans l'alphabet (ex: 0 = A)
afLetTb: SUBA    1,i         ;etant donner que les iLettre sont de 1 a 26, il les faut 0 a 25
         ADDA    'a',i
         STBYTEA thisLet,d 
         CHARO   thisLet,d   ;charOut(la lettre en minuscule)
         CHARO   '/',i
         ANDA    0x00DF,i
         STBYTEA thisLet,d
         CHARO   thisLet,d   ;charOut(la lettre en majuscule)
         CHARO   ':',i
         RET0                ;return
;--------------------------------------------------------
; Variables << Locales >> de afLetTb()
;
thisLet: .BLOCK   0          ;la lettre qu'il faut imprimer
;--------------------------------------------------------
; Variables Globales
;
buffTxt: .BLOCK  100         ;buffer de texte d'entree
cmps:    .BLOCK  52          ;tableau des compteurs
;-----------------------------------------------------
; Messages Strings
;
msgTxtI: .ASCII  "Texte initiale :\n\x00"
msgDix:  .ASCII  "10 octets du texte initiale :\n\x00"
msgCpt:  .ASCII  "Compteurs des mots(\x00"
msgCptF: .ASCII  "):\n\x00"
msgDebor:.ASCII  "Debordement du tampon de saisie.\x00" 
;-----------------------------------------------------
         .END                