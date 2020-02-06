#!/bin/bash
# insertion-sort.bash: Implémentation du tri d'insertion dans Bash

                  
# URL: http://www.lugmen.org.ar/~jjo/jjotip/insertion-sort.bash.d


# Testez avec    ./insertion-sort.bash -t
# Ou  :          bash insertion-sort.bash -t
# Ce qui suit *ne fonctionne pas* :
#              sh insertion-sort.bash -t
#  Pourquoi pas ? Astuce : quelles fonctionnalités spécifiques de Bash sont
#+ désactivées quand un script est exécuté par 'sh script.sh'?
#
: ${DEBUG:=0}  # Debug, surchargé avec :  DEBUG=1 ./nomscript . . .
# Substitution de paramètres -- configurer DEBUG à 0 si non initialisé auparavant.

# Tableau global : "liste"
typeset -a liste
# Chargement de nombres séparés par des espaces blancs à partir de stdin.
if [ "$1" = "-t" ]; then
DEBUG=1
        read -a liste < <( od -Ad -w24 -t u2 /dev/urandom ) # Liste aléatoire.
#                     ^ ^  substitution de processus
else
        read -a liste
fi
numelem=${#liste[*]}

#  Affiche la liste, marquant l'élément dont l'index est $1
#+ en la surchargeant avec les deux caractères passés à $2.
#  La ligne est préfixée par $3.
afficherliste()
  {
  echo "$3"${liste[@]:0:$1} ${2:0:1}${liste[$1]}${2:1:1} ${liste[@]:$1+1};
  }

# Boucle _pivot_ -- à partir du second élément jusqu'à la fin de la liste.
for(( i=1; i&lt;numelem; i++ )) do
        ((DEBUG))&amp;&amp;showlist i "[]" " "
        # À partir du _pivot_ actuel, retour au premier élément.
        for(( j=i; j; j-- )) do
                # Recherche du premier élément inférieur au "pivot" actuel...
                [[ "${list[j-1]}" -le "${list[i]}" ]] && break
        done
        (( i==j )) && continue ## Aucune insertion n'était nécessaire pour cet élément.
        # . . . Déplacer liste[i] (pivot) à la gauche de liste[j] :
        liste=(${liste[@]:0:j} ${liste[i]} ${liste[j]}\
        #         {0,j-1}        {i}        {j}
              ${liste[@]:j+1:i-(j+1)} ${liste[@]:i+1})
        #          {j+1,i-1}               {i+1,last}
        ((DEBUG))&amp;&amp;afficherliste j "&lt;&gt;" "*"
done


echo
echo  "------"
echo $'Résultat :\n'${liste[@]}

exit $?

