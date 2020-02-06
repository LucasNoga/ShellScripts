#!/bin/bash
# Extension du fichier == *.bash == spécifique à Bash

#   Copyright (c) Michael S. Zick, 2003; All rights reserved.
#   License: Use in any form, for any purpose.
#   Revision: $ID$
#
#              Édité pour la présentation par M.C.
#   (auteur du "Guide d'écriture avancée des scripts Bash")
#   Corrections et mises à jour (04/08) par Cliff Bamford.


#  Ce script a été testé sous Bash version 2.04, 2.05a et
#+ 2.05b.
#  Il pourrait ne pas fonctionner avec les versions précédentes.
#  Ce script de démonstration génère une erreur "command not found"
#+ --intentionnelle--. Voir ligne 436.

#  Le mainteneur actuel de Bash maintainer, Chet Ramey, a corrigé les éléments
#+ notés pour les versions ultérieures de Bash.



        ###-------------------------------------------###
        ###  Envoyez la sortie de ce script à 'more'  ###
        ###+ sinon cela dépassera la page.            ###
        ###                                           ###
        ###  Vous pouvez aussi rediriger sa sortie    ###
        ###+ vers un fichier pour l'examiner.         ###  
        ###-------------------------------------------###



#  La plupart des points suivants sont décrit en détail dans
#+ le guide d'écriture avancé du script Bash.
#  Ce script de démonstration est principalement une présentation réorganisée.
#      -- msz

# Les variables ne sont pas typées sauf cas indiqués.

#  Les variables sont nommées. Les noms doivent contenir un caractère qui
#+ n'est pas un chiffre.
#  Les noms des descripteurs de fichiers (comme dans, par exemple, 2>&1)
#+ contiennent UNIQUEMENT des chiffres.

# Les paramètres et les éléments de tavbleau Bash sont numérotés.
# (Les paramètres sont très similaires aux tableaux Bash.)

# Un nom de variable pourrait être indéfini (référence nulle).
unset VarNullee

# Un nom de variable pourrait être défini mais vide (contenu nul).
VarVide=''                         # Deux guillemets simples, adjacents.

# Un nom de variable pourrait être défini et non vide.
VarQuelquechose='Littéral'

# Une variable pourrait contenir:
#   * Un nombre complet, entier signé sur 32-bit (voire plus)
#   * Une chaîne
# Une variable pourrait aussi être un tableau.

#  Une chaîne pourrait contenir des espaces et pourrait être traitée
#+ comme s'il s'agissait d'un nom de fonction avec des arguments optionnelles.

#  Les noms des variables et les noms des functions sont dans différents
#+ espaces de noms.


#  Une variable pourrait être défini comme un tableau Bash soit explicitement
#+ soit implicitement par la syntaxe de l'instruction d'affectation.
#  Explicite:
declare -a VarTableau



# La commande echo est intégrée.
echo $VarQuelquechose

# La commande printf est intégrée.
# Traduire %s comme "Format chaîne"
printf %s $VarQuelquechose      #  Pas de retours chariot spécifiés,
                                #+ aucune sortie.
echo                            # Par défaut, seulement un retour chariot.




#  L'analyseur de mots de Bash s'arrête sur chaque espace blanc mais son
#+ manquement est significatif.
#  (Ceci reste vrai en général ; Il existe évidemment des exceptions.)




# Traduire le signe SIGNE_DOLLAR comme Contenu-de.

# Syntaxe étendue pour écrire Contenu-de :
echo ${VarQuelquechose}

#  La syntaxe étendue ${ ... } permet de spécifier plus que le nom de la
#+ variable.
#  En général, $VarQuelquechose peut toujours être écrit ${VarQuelquechose}.

# Appelez ce script avec des arguments pour visualiser l'action de ce qui suit.



#  En dehors des doubles guillemets, les caractères spéciaux @ et *
#+ spécifient un comportement identique.
#  Pourrait être prononcé comme Tous-Éléments-De.

#  Sans spécifier un nom, ils réfèrent un paramètre prédéfini Bash-Array.



# Références de modèles globaux
echo $*                       # Tous les paramètres du script ou de la fonction
echo ${*}                     # Pareil

# Bash désactive l'expansion de nom de fichier pour les modèles globaux.
# Seuls les caractères correspondants sont actifs.


# Références de Tous-Éléments-De
echo $@                         # Identique à ci-dessus
echo ${@}                       # Identique à ci-dessus




#  À l'intérieur des guillemets doubles, le comportement des références de
#+ modèles globaux dépend du paramètrage de l'IFS (Input Field Separator, soit
#+ séparateur de champ d'entrée).
#  À l'intérieur des guillemets doubles, les références à Tous-Éléments-De
#+ se comportent de façon identique.


#  Spécifier uniquement le nom de la variable contenant une chaîne réfère tous
#+ les éléments (caractères) d'une chaîne.


#  Spécifier un élément (caractère) d'une chaîne,
#+ la notation de référence de syntaxe étendue (voir ci-dessous) POURRAIT être
#+ utilisée.




#  Spécifier uniquement le nom d'un tableau Bash référence l'élément 0,
#+ PAS le PREMIER DÉFINI, PAS le PREMIER AVEC CONTENU.

#  Une qualification supplémentaire est nécessaire pour référencer d'autres
#+ éléments, ce qui signifie que la référence DOIT être écrite dans la syntaxe
#+ étendue. La forme générale est ${nom[indice]}.

#  Le format de chaîne pourrait aussi être utilisé ${nom:indice}
#+ pour les tableaux Bash lors de la référence de l'élément zéro.


#  Les tableaux Bash sont implémentés en interne comme des listes liés,
#+ pas comme une aire fixe de stockage comme le font certains langages de
#+ programmation.


#   Caractéristiques des tableaux Bash (Bash-Arrays):
#   ------------------------------------------------

#   Sans autre indication, les indices des tableaux Bash
#+  commencent avec l'indice numéro 0. Littéralement : [0]
#   Ceci s'appelle un indice base 0.
###
#   Sans autre indication, les tableaux Bash ont des indices continus
#+  (indices séquentielles, sans trou/manque).
###
#   Les indices négatifs ne sont pas autorisés.
###
#   Les éléments d'un tableau Bash n'ont pas besoin de tous être du même type.
###
#   Les éléments d'un tableau Bash pourraient être indéfinis (référence nulle).
#       C'est-à-dire qu'un tableau Bash pourrait être "subscript sparse."
###
#   Les éléments d'un tableau Bash pourraient être définis et vides
#+  (contenu nul).
###
#   Les éléments d'un tableau Bash pourraient être :
#     * Un entier codé sur 32 bits (ou plus)
#     * Une chaîne
#     * Une chaîne formattée de façon à ce qu'elle soit en fait le nom d'une
#       fonction avec des arguments optionnelles
###
#   Les éléments définis d'un tableau Bash pourraient ne pas être définis
#   (unset).
#       C'est-à-dire qu'un tableau Bash à indice continu pourrait être modifié
#       en un tableau Bash à indice disparate.
###
#   Des éléments pourraient être ajoutés dans un tableau Bash en définissant un
#   élément non défini précédemment.
###
# Pour ces raisons, je les ai appelé des tableaux Bash ("Bash-Arrays").
# Je retourne maintenant au terme générique "tableau".
#     -- msz




echo "========================================================="

#  Lignes 202 à 334 fournies par Cliff Bamford. (Merci !)
#  Démo --- Interaction avec les tableaux, les guillemets, IFS, echo, * et @
#+ --- tous modifient la façon dont cela fonctionne

ArrayVar[0]='zero'                    # 0 normal
ArrayVar[1]=one                       # 1 valeur litérale sans guillemet
ArrayVar[2]='two'                     # 2 normal
ArrayVar[3]='three'                   # 3 normal
ArrayVar[4]='I am four'               # 4 normal avec des espaces
ArrayVar[5]='five'                    # 5 normal
unset ArrayVar[6]                     # 6 indéfini
ArrayValue[7]='seven'                 # 7 normal
ArrayValue[8]=''                      # 8 défini mais vide
ArrayValue[9]='nine'                  # 9 normal


echo '--- Voici le tableau que nous utilisons pour ce test'
echo
echo "ArrayVar[0]='zero'             # 0 normal"
echo "ArrayVar[1]=one                # 1 valeur litérale sans guillemet"
echo "ArrayVar[2]='two'              # 2 normal"
echo "ArrayVar[3]='three'            # 3 normal"
echo "ArrayVar[4]='I am four'        # 4 normal avec des espaces"
echo "ArrayVar[5]='five'             # 5 normal"
echo "unset ArrayVar[6]              # 6 indéfini"
echo "ArrayValue[7]='seven'          # 7 normal"
echo "ArrayValue[8]=''               # 8 défini mais vide"
echo "ArrayValue[9]='nine'           # 9 normal"
echo


echo
echo '---Cas 0 : Sans double guillemets, IFS par défaut (espace, tabulation, retour à la ligne) ---'
IFS=$'\x20'$'\x09'$'\x0A'            # Exactement dans cet ordre.
echo 'Voici : printf %q {${ArrayVar[*]}'
printf %q ${ArrayVar[*]}
echo
echo 'Voici : printf %q {${ArrayVar[@]}'
printf %q ${ArrayVar[@]}
echo
echo 'Voici : echo ${ArrayVar[*]}'
echo  ${ArrayVar[@]}
echo 'Voici : echo {${ArrayVar[@]}'
echo ${ArrayVar[@]}

echo
echo '---Cas 1 : Dans des guillemets doubles - IFS par défaut ---'
IFS=$'\x20'$'\x09'$'\x0A'           #  These three bytes,
echo 'Voici : printf %q "{${ArrayVar[*]}"'
printf %q "${ArrayVar[*]}"
echo
echo 'Voici : printf %q "{${ArrayVar[@]}"'
printf %q "${ArrayVar[@]}"
echo
echo 'Voici : echo "${ArrayVar[*]}"'
echo  "${ArrayVar[@]}"
echo 'Voici : echo "{${ArrayVar[@]}"'
echo "${ArrayVar[@]}"

echo
echo '---Cas 2 : Dans des guillemets doubles - IFS vaut q'
IFS='q'
echo 'Voici : printf %q "{${ArrayVar[*]}"'
printf %q "${ArrayVar[*]}"
echo
echo 'Voici : printf %q "{${ArrayVar[@]}"'
printf %q "${ArrayVar[@]}"
echo
echo 'Voici : echo "${ArrayVar[*]}"'
echo  "${ArrayVar[@]}"
echo 'Voici : echo "{${ArrayVar[@]}"'
echo "${ArrayVar[@]}"

echo
echo '---Cas 3 : Dans des guillemets doubles - IFS vaut ^'
IFS='^'
echo 'Voici : printf %q "{${ArrayVar[*]}"'
printf %q "${ArrayVar[*]}"
echo
echo 'Voici : printf %q "{${ArrayVar[@]}"'
printf %q "${ArrayVar[@]}"
echo
echo 'Voici : echo "${ArrayVar[*]}"'
echo  "${ArrayVar[@]}"
echo 'Voici : echo "{${ArrayVar[@]}"'
echo "${ArrayVar[@]}"

echo
echo '---Cas 4 : Dans des guillemets doubles - IFS vaut ^ suivi par  
espace, tabulation, retour à la ligne'
IFS=$'^'$'\x20'$'\x09'$'\x0A'       # ^ + espace tabulation retour à la ligne
echo 'Voici : printf %q "{${ArrayVar[*]}"'
printf %q "${ArrayVar[*]}"
echo
echo 'Voici : printf %q "{${ArrayVar[@]}"'
printf %q "${ArrayVar[@]}"
echo
echo 'Voici : echo "${ArrayVar[*]}"'
echo  "${ArrayVar[@]}"
echo 'Voici : echo "{${ArrayVar[@]}"'
echo "${ArrayVar[@]}"

echo
echo '---Cas 6 : Dans des guillemets doubles - IFS configuré mais vide'
IFS=''
echo 'Voici : printf %q "{${ArrayVar[*]}"'
printf %q "${ArrayVar[*]}"
echo
echo 'Voici : printf %q "{${ArrayVar[@]}"'
printf %q "${ArrayVar[@]}"
echo
echo 'Voici : echo "${ArrayVar[*]}"'
echo  "${ArrayVar[@]}"
echo 'Voici : echo "{${ArrayVar[@]}"'
echo "${ArrayVar[@]}"

echo
echo '---Cas 7 : Dans des guillemets doubles - IFS indéfini'
unset IFS
echo 'Voici : printf %q "{${ArrayVar[*]}"'
printf %q "${ArrayVar[*]}"
echo
echo 'Voici : printf %q "{${ArrayVar[@]}"'
printf %q "${ArrayVar[@]}"
echo
echo 'Voici : echo "${ArrayVar[*]}"'
echo  "${ArrayVar[@]}"
echo 'Voici : echo "{${ArrayVar[@]}"'
echo "${ArrayVar[@]}"

echo
echo '---Fin des cas---'
echo "========================================================="; echo



# Remettre la valeur par défaut d'IFS.
# Par défaut, il s'agit exactement de ces trois octets.
IFS=$'\x20'$'\x09'$'\x0A'           # Dans cet ordre.

# Interprétation des affichages précédents :
#   Un modèle global est de l'entrée/sortie ; le paramètrage de l'IFS est pris
en compte.
###
#   Un Tous-Éléments-De ne prend pas en compte le paramètrage de l'IFS.
###
#   Notez les affichages différents en utilisant la commande echo et l'opérateur
#+ de format entre guillemets de la commande printf.


#  Rappel :
#   Les paramètres sont similaires aux tableaux et ont des comportements
similaires.
###
#  Les exemples ci-dessous démontrent les variantes possibles.
#  Pour conserver la forme d'un tableau à indice non continu, un supplément au
script
#+ est requis.
###
#  Le code source de Bash dispose d'une routine d'affichage du format
#+ d'affectation [indice]=valeur   .
#  Jusqu'à la version 2.05b, cette routine n'est pas utilisée
#+ mais cela pourrait changer dans les versions suivantes.



# La longueur d'une chaîne, mesurée en éléments non nuls (caractères) :
echo
echo '- - Références sans guillemets - -'
echo 'Nombre de caractères non nuls : '${#VarQuelquechose}' caractères.'

# test='Lit'$'\x00''eral'           # $'\x00' est un caractère nul.
# echo ${#test}                     # Vous avez remarqué ?



#  La longueur d'un tableau, mesurée en éléments définis,
#+ ceci incluant les éléments à contenu nul.
echo
echo 'Nombre de contenu défini : '${#VarTableau[@]}' éléments.'
# Ce n'est PAS l'indice maximum (4).
# Ce n'est PAS l'échelle des indices (1...4 inclus).
# C'EST la longueur de la liste chaînée.
###
#  L'indice maximum et l'échelle d'indices pourraient être trouvées avec
#+ un peu de code supplémentaire.

# La longueur d'une chaîne, mesurée en éléments non nuls (caractères):
echo
echo '- - Références du modèle global, entre guillemets - -'
echo 'Nombre de caractères non nuls : '"${#VarQuelquechose}"'.'

#  La longueur d'un tableau, mesuré avec ses éléments définis,
#+ ceci incluant les éléments à contenu nul.
echo
echo "Nombre d'éléments définis: '"${#VarTableau[*]}"' éléments."

#  Interprétation : la substitution n'a pas d'effet sur l'opération ${# ... }.
#  Suggestion :
#  Toujours utiliser le caractère Tous-Éléments-De
#+ si cela correspond au comportement voulu (indépendence par rapport à l'IFS).



#  Définir une fonction simple.
#  J'inclus un tiret bas dans le nom pour le distinguer des exemples ci-dessous.
###
#  Bash sépare les noms de variables et les noms de fonctions
#+ grâce à des espaces de noms différents.
#  The Mark-One eyeball isn't that advanced.
###
_simple() {
    echo -n 'FonctionSimple'$@      #  Les retours chariots disparaissent dans
le résultat.
}


# La notation ( ... ) appelle une commande ou une fonction.
# La notation $( ... ) est prononcée Résultat-De.


# Appelle la fonction _simple
echo
echo '- - Sortie de la fonction _simple - -'
_simple                             # Essayez de passer des arguments.
echo
# or
(_simple)                           # Essayez de passer des arguments.
echo

echo "- Existe-t'il une variable de ce nom ? -"
echo $_simple indéfinie             # Aucune variable de ce nom.

# Appelle le résultat de la fonction _simple (message d'erreur attendu)

###
$(_simple)                          # Donne un message d'erreur :
#                          line 436: FonctionSimple: command not found
#                          ---------------------------------------

echo
###

#  Le premier mot du résultat de la fonction _simple
#+ n'est ni une commande Bash valide ni le nom d'une fonction définie.
###
# Ceci démontre que la sortie de _simple est sujet à évaluation.
###
# Interprétation :
#   Une fonction peut être utilisée pour générer des commandes Bash en ligne.


# Une fonction simple où le premier mot du résultat EST une commande Bash :
###
_print() {
    echo -n 'printf %q '$@
}

echo '- - Affichage de la fonction _print - -'
_print parm1 parm2                  # Une sortie n'est PAS une commande.
echo

$(_print parm1 parm2)               #  Exécute : printf %q parm1 parm2
                                    #  Voir ci-dessus les exemples IFS
                                    #+ pour les nombreuses possibilités.
echo

$(_print $VarQuelquechose)             # Le résultat prévisible.
echo



# Variables de fonctions
# ----------------------

echo
echo '- - Variables de fonctions - -'
# Une variable pourrait représenter un entier signé, une chaîne ou un tableau.
# Une chaîne pourrait être utilisée comme nom de fonction avec des arguments
optionnelles.

# set -vx                           #  À activer si désiré
declare -f funcVar                  #+ dans l'espace de noms des fonctions

funcVar=_print                      # Contient le nom de la fonction.
$funcVar parm1                      # Identique à _print à ce moment.
echo

funcVar=$(_print )                  # Contient le résultat de la fonction.
$funcVar                            # Pas d'entrée, pas de sortie.
$funcVar $VarQuelquechose           # Le résultat prévisible.
echo

funcVar=$(_print $VarQuelquechose)  #  $VarQuelquechose remplacé ICI.
$funcVar                            #  L'expansion fait parti du contenu
echo                                #+ des variables.

funcVar="$(_print $VarQuelquechose)" #  $VarQuelquechose remplacé ICI.
$funcVar                             #  L'expansion fait parti du contenu
echo                                #+ des variables.

#  La différence entre les versions sans guillemets et avec double guillemets
#+ ci-dessus est rencontrée dans l'exemple "protect_literal.sh".
#  Le premier cas ci-dessus est exécuté comme deux mots Bash sans guillemets.
#  Le deuxième cas est exécuté comme un mot Bash avec guillemets.




# Remplacement avec délai
# -----------------------

echo
echo '- - Remplacement avec délai - -'
funcVar="$(_print '$VarQuelquechose')" # Pas de remplacement, simple mot Bash.
eval $funcVar                          # $VarQuelquechose remplacé ICI.
echo

VarQuelquechose='NouvelleChose'
eval $funcVar                       # $VarQuelquechose remplacé ICI.
echo

# Restaure la configuration initiale.
VarQuelquechose=Literal

#  Il existe une paire de fonctions démontrées dans les exemples
#+ "protect_literal.sh" et "unprotect_literal.sh".
#  Il s'agit de fonctions à but général pour des littérales à remplacements avec
délai
#+ contenant des variables.





# REVUE :
# ------

#  Une chaîne peut être considérée comme un tableau classique d'éléments de type
#+ caractère.
#  Une opération sur une chaîne s'applique à tous les éléments (caractères) de
#+ la chaîne (enfin, dans son concept).
###
#  La notation ${nom_tableau[@]} représente tous les éléments du tableau Bash
#+ nom_tableau.
###
#  Les opérations sur les chaînes de syntaxe étendue sont applicables à tous les
#+ éléments d'un tableau.
###
#  Ceci peut être pensé comme une boucle For-Each sur un vecteur de chaînes.
###
#  Les paramètres sont similaires à un tableau.
#  L'initialisation d'un paramètre de type tableau pour un script
#+ et d'un paramètre de type tableau pour une fonction diffèrent seulement
#+ dans l'initialisation de ${0}, qui ne change jamais sa configuration.
###
#  L'indice zéro du tableau, paramètre d'un script, contient le nom du script.
###
#  L'indice zéro du tableau, paramètre de fonction, NE CONTIENT PAS le nom de la
#+ fonction.
#  Le nom de la fonction courante est accédé par la variable $NOM_FONCTION.
###
#  Une liste rapide et revue suit (rapide mais pas courte).

echo
echo '- - Test (mais sans changement) - -'
echo '- référence nulle -'
echo -n ${VarNulle-'NonInitialisée'}' '  # NonInitialisée
echo ${VarNulle}                         # NewLine only
echo -n ${VarNulle:-'NonInitialisée'}' ' # NonInitialisée
echo ${VarNulle}                         # Newline only

echo '- contenu nul -'
echo -n ${VarVide-'Vide'}' '             # Seulement l'espace
echo ${VarVide}                          # Nouvelle ligne seulement
echo -n ${VarVide:-'Vide'}' '            # Vide
echo ${VarVide}                          # Nouvelle ligne seulement

echo '- contenu -'
echo ${VarQuelquechose-'Contenu'}        # Littéral
echo ${VarQuelquechose:-'Contenu'}       # Littéral

echo '- Tableau à indice non continu -'
echo ${VarTableau[@]-'non initialisée'}

# Moment ASCII-Art
# État               O==oui, N==non
#                    -       :-
# Non initialisé     O       O       ${# ... } == 0
# Vide               N       O       ${# ... } == 0
# Contenu            N       N       ${# ... } > 0

#  Soit la première partie des tests soit la seconde pourrait être une chaîne
#+ d'appel d'une commande ou d'une fonction.
echo
echo '- - Test 1 pour indéfini - -'
declare -i t
_decT() {
    t=$t-1
}

# Référence nulle, initialisez à t == -1
t=${#VarNulle}                           # Résultats en zéro.
${VarNulle- _decT }                      # La fonction s'exécute, t vaut maintenant -1.
echo $t

# Contenu nul, initialisez à t == 0
t=${#VarVide}                          # Résultats en zéro.
${VarVide- _decT }                     # Fontion _decT NON exécutée.
echo $t

# Contenu, initialisez à t == nombre de caractères non nuls
VarQuelquechose='_simple'                  # Initialisez avec un nom de fonction valide.
t=${#VarQuelquechose}                      # longueur différente de zéro
${VarQuelquechose- _decT }                 # Fonction _simple exécutée.
echo $t                                    # Notez l'action Append-To.

# Exercice : nettoyez cet exemple.
unset t
unset _decT
VarQuelquechose=Literal

echo
echo '- - Test et modification - -'
echo '- Affectation si référence nulle -'
echo -n ${VarNulle='NonInitialisée'}' '          # NonInitialisée NonInitialisée
echo ${VarNulle}
unset VarNulle

echo '- Affectation si référence nulle -'
echo -n ${VarNulle:='NonInitialisée'}' '         # NonInitialisée NonInitialisée
echo ${VarNulle}
unset VarNulle

echo "- Pas d'affectation si contenu nul -"
echo -n ${VarVide='Vide'}' '          # Espace seulement
echo ${VarVide}
VarVide=''

echo "- Affectation si contenu nul -"
echo -n ${VarVide:='Vide'}' '         # Vide Vide
echo ${VarVide}
VarVide=''

echo "- Aucun changement s'il a déjà un contenu -"
echo ${VarQuelquechose='Contenu'}          # Littéral
echo ${VarQuelquechose:='Contenu'}         # Littéral


# Tableaux Bash à indice non continu
###
#  Les tableaux Bash ont des indices continus, commençant à zéro
#+  sauf indication contraire.
###
#  L'initialisation de VarTableau était une façon de le "faire autrement".
#+ Voici un autre moyen :
###
echo
declare -a TableauNonContinu
TableauNonContinu=( [1]=un [2]='' [4]='quatre' )
# [0]=référence nulle, [2]=contenu nul, [3]=référence nulle

echo '- - Liste de tableaux à indice non continu - -'
# À l'intérieur de guillemets doubles, IFS par défaut, modèle global

IFS=$'\x20'$'\x09'$'\x0A'
printf %q "${TableauNonContinu[*]}"
echo

#  Notez que l'affichage ne distingue pas entre "contenu nul" et "référence nulle".
#  Les deux s'affichent comme des espaces blancs échappés.
###
#  Notez aussi que la sortie ne contient PAS d'espace blanc échappé
#+ pour le(s) "référence(s) nulle(s)" avant le premier élément défini.
###
# Ce comportement des versions 2.04, 2.05a et 2.05b a été rapporté et
#+ pourrait changer dans une prochaine version de Bash.

#  Pour afficher un tableau sans indice continu et maintenir la relation
#+ [indice]=valeur sans changement requiert un peu de programmation.
#  Un bout de code possible :
###
# local l=${#TableauNonContinu[@]}  # Nombre d'éléments définis
# local f=0                         # Nombre d'indices trouvés
# local i=0                         # Indice à tester
(                                   # Fonction anonyme en ligne
    for (( l=${#TableauNonContinu[@]}, f = 0, i = 0 ; f < l ; i++ ))
    do
        # 'si défini alors...'
        ${TableauNonContinu[$i]+ eval echo '\ ['$i']='${TableauNonContinu[$i]} ; (( f++ )) }
    done
)

# Le lecteur arrivant au fragment de code ci-dessus pourrait vouloir voir
#+ la liste des commandes et les commandes multiples sur une ligne dans le texte
#+ du guide de l'écriture avancée de scripts shell Bash.
###
#  Note :
#  La version "read -a nom_tableau" de la commande "read" commence à remplir
#+ nom_tableau à l'indice zéro.
#  TableauNonContinu ne définit pas de valeur à l'indice zéro.
###
#  L'utilisateur ayant besoin de lire/écrire un tableau non contigu pour soit
#+ un stockage externe soit une communication par socket doit inventer une paire
#+ de code lecture/écriture convenant à ce but.
###
# Exercice : nettoyez-le.

unset TableauNonContinu

echo
echo '- - Alternative conditionnel (mais sans changement)- -'
echo "- Pas d'alternative si référence nulle -"
echo -n ${VarNulle+'NonInitialisee'}' '
echo ${VarNulle}
unset VarNulle

echo "- Pas d'alternative si référence nulle -"
echo -n ${VarNulle:+'NonInitialisee'}' '
echo ${VarNulle}
unset VarNulle

echo "- Alternative si contenu nul -"
echo -n ${VarVide+'Vide'}' '               # Vide
echo ${VarVide}
VarVide=''

echo "- Pas d'alternative si contenu nul -"
echo -n ${VarVide:+'Vide'}' '              # Espace seul
echo ${VarVide}
VarVide=''

echo "- Alternative si contenu déjà existant -"

# Alternative littérale
echo -n ${VarQuelquechose+'Contenu'}' '        # Contenu littéral
echo ${VarQuelquechose}

# Appelle une fonction
echo -n ${VarQuelquechose:+ $(_simple) }' '    # Littéral FonctionSimple
echo ${VarQuelquechose}
echo

echo '- - Tableau non contigu - -'
echo ${VarTableau[@]+'Vide'}                   # Un tableau de 'vide'(s)
echo

echo '- - Test 2 pour indéfini - -'

declare -i t
_incT() {
    t=$t+1
}

#  Note:
#  C'est le même test utilisé dans le fragment de code
#+  pour le tableau non contigu.

# Référence nulle, initialisez : t == -1
t=${#VarNulle}-1                     # Les résultats dans moins-un.
${VarNulle+ _incT }                  # Ne s'exécute pas.
echo $t' Null reference'

# Contenu nul, initialisez : t == 0
t=${#VarVide}-1                    # Les résultats dans moins-un.
${VarVide+ _incT }                 # S'exécute.
echo $t'  Null content'

# Contenu, initialisez : t == (nombre de caractères non nuls)
t=${#VarQuelquechose}-1                # longueur non nul moins un
${VarQuelquechose+ _incT }             # S'exécute.
echo $t'  Contents'

# Exercice : nettoyez cet exemple.
unset t
unset _incT

# ${name?err_msg} ${name:?err_msg}
#  Ceci suit les mêmes règles mais quitte toujours après
#+ si une action est spécifiée après le point d'interrogation.
#  L'action suivant le point d'interrogation pourrait être un littéral
#+ ou le résultat d'une fonction.
###
#  ${nom?} ${nom:?} sont seulement des tests, le retour peut être testé.




# Opérations sur les éléments
# ---------------------------

echo
echo '- - Sélection du sous-élément de queue - -'

#  Chaînes, tableaux et paramètres de position

#  Appeler ce script avec des arguments multiples
#+ pour voir les sélections du paramètre.

echo '- Tous -'
echo ${VarQuelquechose:0}           # tous les caractères non nuls
echo ${VarTableau[@]:0}             # tous les éléments avec contenu
echo ${@:0}                         # tous les paramètres avec contenu
                                    # ignore paramètre[0]

echo
echo '- Tous après -'
echo ${VarQuelquechose:1}           # tous les non nuls après caractère[0]
echo ${VarTableau[@]:1}             # tous après élément[0] avec contenu
echo ${@:2}                         # tous après param[1] avec contenu

echo
echo '- Intervalle après -'
echo ${VarQuelquechose:4:3}         # ral
                                    # trois caractères après
                                    # caractère[3]

echo '- Sparse array gotch -'
echo ${VarTableau[@]:1:2}   #  quatre - le premier élément avec contenu.
                            #  Deux éléments après (s'ils existent).
                            #  le PREMIER AVEC CONTENU
                            #+ (le PREMIER AVEC CONTENU doit être
                            #+ considéré comme s'il s'agissait de
                            #+ l'indice zéro).
#  Éxécuté comme si Bash considère SEULEMENT les éléments de tableau avec CONTENU
#  printf %q "${VarTableau[@]:0:3}"    # Essayez celle-ci

#  Dans les versions 2.04, 2.05a et 2.05b,
#+ Bash ne gère pas les tableaux non contigu comme attendu avec cette notation.
#
#  Le mainteneur actuel de Bash, Chet Ramey, a corrigé ceci.


echo '- Tableaux contigus -'
echo ${@:2:2}               # Deux paramètres suivant paramètre[1]

# Nouvelles victimes des exemples de vecteurs de chaînes :
chaineZ=abcABC123ABCabc
tableauZ=( abcabc ABCABC 123123 ABCABC abcabc )
noncontiguZ=( [1]='abcabc' [3]='ABCABC' [4]='' [5]='123123' )

echo
echo ' - - Chaîne victime - -'$chaineZ'- - '
echo ' - - Tableau victime - -'${tableauZ[@]}'- - '
echo ' - - Tableau non contigu - -'${noncontiguZ[@]}'- - '
echo ' - [0]==réf. nulle, [2]==réf. nulle, [4]==contenu nul - '
echo ' - [1]=abcabc [3]=ABCABC [5]=123123 - '
echo ' - nombre de références non nulles : '${#noncontiguZ[@]}' elements'

echo
echo "- - Suppression du préfixe d'un sous élément - -"
echo '- - la correspondance de modèle globale doit inclure le premier caractère. - -'
echo "- - Le modèle global doit être un littéral ou le résultat d'une fonction. - -"
echo


# Fonction renvoyant un modèle global simple, littéral
_abc() {
    echo -n 'abc'
}

echo '- Préfixe court -'
echo ${chaineZ#123}                 # Non modifié (pas un préfixe).
echo ${chaineZ#$(_abc)}             # ABC123ABCabc
echo ${tableauZ[@]#abc}             # Appliqué à chaque élément.

# echo ${noncontiguZ[@]#abc}            # Version-2.05b quitte avec un « core dump ».
# Corrigé depuis par Chet Ramey.

# Le -it serait sympa- Premier-Indice-De
# echo ${#noncontiguZ[@]#*}             # Ce n'est PAS du Bash valide.

echo
echo '- Préfixe le plus long -'
echo ${chaineZ##1*3}                # Non modifié (pas un préfixe)
echo ${chaineZ##a*C}                # abc
echo ${tableauZ[@]##a*c}            # ABCABC 123123 ABCABC

# echo ${noncontiguZ[@]##a*c}           # Version-2.05b quitte avec un « core dump ».
# Corrigé depuis par Chet Ramey.

echo
echo '- - Suppression du sous-élément suffixe - -'
echo '- - La correspondance du modèle global doit inclure le dernier caractère. - -'
echo '- - Le modèle global pourrait être un littéral ou un résultat de fonction. - -'
echo
echo '- Suffixe le plus court -'
echo ${chaineZ%1*3}                 # Non modifié (pas un suffixe).
echo ${chaineZ%$(_abc)}             # abcABC123ABC
echo ${tableauZ[@]%abc}             # Appliqué à chaque élément.

# echo ${noncontiguZ[@]%abc}            # Version-2.05b quitte avec un « core dump ».
# Corrigé depuis par Chet Ramey.

# Le -it serait sympa- Dernier-Indice-De
# echo ${#noncontiguZ[@]%*}             # Ce n'est PAS du Bash valide.

echo
echo '- Suffixe le plus long -'
echo ${chaineZ%%1*3}                # Non modifié (pas un suffixe)
echo ${chaineZ%%b*c}                # a
echo ${tableauZ[@]%%b*c}            # a ABCABC 123123 ABCABC a

# echo ${noncontiguZ[@]%%b*c}           # Version-2.05b quitte avec un « core dump ».
# Corrigé depuis par Chet Ramey.

echo
echo '- - Remplacement de sous-élements - -'
echo "- - Sous-élément situé n'importe où dans la chaîne. - -"
echo '- - La première spécification est un modèle global. - -'
echo '- - Le modèle global pourrait être un littéral ou un résultat de fonction de modèle global. - -'
echo '- - La seconde spécification pourrait être un littéral ou un résultat de fonction. - -'
echo '- - La seconde spécification pourrait être non spécifiée. Prononcez-ça comme :'
echo '    Remplace-Avec-Rien (Supprime) - -'
echo



# Fonction renvoyant un modèle global simple, littéral
_123() {
    echo -n '123'
}

echo '- Remplace la première occurrence -'
echo ${chaineZ/$(_123)/999}         # Modifié (123 est un composant).
echo ${chaineZ/ABC/xyz}             # xyzABC123ABCabc
echo ${tableauZ[@]/ABC/xyz}         # Appliqué à chaque élément.
echo ${noncontiguZ[@]/ABC/xyz}      # Fonctionne comme attendu.

echo
echo '- Supprime la première first occurrence -'
echo ${chaineZ/$(_123)/}
echo ${chaineZ/ABC/}
echo ${tableauZ[@]/ABC/}
echo ${noncontiguZ[@]/ABC/}

#  Le remplacement ne doit pas être un littéral,
#+ car le résultat de l'appel d'une fonction est permis.
#  C'est général pour toutes les formes de remplacement.
echo
echo '- Remplace la première occurence avec Résultat-De -'
echo ${chaineZ/$(_123)/$(_simple)}   # Fonctionne comme attendu.
echo ${tableauZ[@]/ca/$(_simple)}    # Appliqué à chaque élément.
echo ${noncontiguZ[@]/ca/$(_simple)} # Fonctionne comme attendu.

echo
echo '- Remplace toutes les occurrences -'
echo ${chaineZ//[b2]/X}              # X-out b et 2
echo ${chaineZ//abc/xyz}             # xyzABC123ABCxyz
echo ${tableauZ[@]//abc/xyz}         # Appliqué à chaque élément.
echo ${noncontiguZ[@]//abc/xyz}      # Fonctionne comme attendu.

echo
echo '- Supprime toutes les occurrences -'
echo ${chaineZ//[b2]/}
echo ${chaineZ//abc/}
echo ${tableauZ[@]//abc/}
echo ${noncontiguZ[@]//abc/}

echo
echo '- - Remplacement du sous-élément préfixe - -'
echo '- - La correspondance doit inclure le premier caractère. - -'
echo

echo '- Remplace les occurrences du préfixe -'
echo ${chaineZ/#[b2]/X}             # Non modifié (n'est pas non plus un préfixe).
echo ${chaineZ/#$(_abc)/XYZ}        # XYZABC123ABCabc
echo ${tableauZ[@]/#abc/XYZ}        # Appliqué à chaque élément.
echo ${noncontiguZ[@]/#abc/XYZ}     # Fonctionne comme attendu.

echo
echo '- Supprime les occurrences du préfixe -'
echo ${chaineZ/#[b2]/}
echo ${chaineZ/#$(_abc)/}
echo ${tableauZ[@]/#abc/}
echo ${noncontiguZ[@]/#abc/}

echo
echo '- - Remplacement du sous-élément suffixe - -'
echo '- - La correspondance doit inclure le dernier caractère. - -'
echo

echo '- Remplace les occurrences du suffixe -'
echo ${chaineZ/%[b2]/X}             # Non modifié (n'est pas non plus un suffixe).
echo ${chaineZ/%$(_abc)/XYZ}        # abcABC123ABCXYZ
echo ${tableauZ[@]/%abc/XYZ}        # Appliqué à chaque élément.
echo ${noncontiguZ[@]/%abc/XYZ}     # Fonctionne comme attendu.

echo
echo '- Supprime les occurrences du suffixe -'
echo ${chaineZ/%[b2]/}
echo ${chaineZ/%$(_abc)/}
echo ${tableauZ[@]/%abc/}
echo ${noncontiguZ[@]/%abc/}

echo
echo '- - Cas spéciaux du modèle global nul - -'
echo

echo '- Tout préfixe -'
# modèle de sous-chaîne nul, signifiant 'préfixe'
echo ${chaineZ/#/NEW}               # NEWabcABC123ABCabc
echo ${tableauZ[@]/#/NEW}           # Appliqué à chaque élément.
echo ${noncontiguZ[@]/#/NEW}        # Aussi appliqué au contenu nul.
                                    # Cela semble raisonnable.

echo
echo '- Tout suffixe -'
# modèle de sous-chaîne nul, signifiant 'suffixe'
echo ${chaineZ/%/NEW}               # abcABC123ABCabcNEW
echo ${tableauZ[@]/%/NEW}           # Appliqué à chaque élément.
echo ${noncontiguZ[@]/%/NEW}        # Aussi appliqué au contenu nul.
                                    # Cela semble raisonnable.

echo
echo '- - Cas spécial pour le modèle global For-Each - -'
echo '- - - - Ceci est un rêve - - - -'
echo

_GenFunc() {
    echo -n ${0}                    # Illustration seulement.
    # Actuellement, ce serait un calcul arbitraire.
}

#  Toutes les occurrences, correspondant au modèle NImporteQuoi.
#  Actuellement, //*/ n'établit pas une correspondance avec un modèle nul
#+ ainsi qu'avec une référence nulle.
#  /#/ et /%/ correspondent à un contenu nul mais pas à une référence nulle.
echo ${noncontiguZ[@]//*/$(_GenFunc)}


#  Une syntaxe possible placerait la notation du paramètre utilisé
#+ à l'intérieur du moyen de construction.
#   ${1} - L'élément complet
#   ${2} - Le préfixe, S'il existe, du sous-élément correspondant
#   ${3} - Le sous-élément correspondant
#   ${4} - Le suffixe, S'il existe, du sous-élément correspondant
#
# echo ${noncontiguZ[@]//*/$(_GenFunc ${3})}   # Pareil que ${1}, ici.
# Cela sera peut-être implémenté dans une future version de Bash.


exit 0

