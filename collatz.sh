#!/bin/bash
#collatz : Séries de Collatz

#  Le célèbre "hailstone" ou la série de Collatz.
#  ----------------------------------------------
#  1) Obtenir un entier "de recherche" à partir de la ligne de commande.
#  2) NOMBRE &lt;--- seed
#  3) Afficher NOMBRE.
#  4)  Si NOMBRE est pair, divisez par 2, ou
#  5)+ si impair, multiplier par 3 et ajouter 1.
#  6) NOMBRE &lt;--- résultat
#  7) Boucler à l'étape 3 (pour un nombre spécifié d'itérations).
#
#  La théorie est que chaque séquence, quelle soit la valeur initiale,
#+ se stabilisera éventuellement en répétant des cycles "4,2,1...",
#+ même après avoir fluctuée à travers un grand nombre de valeurs.
#
#  C'est une instance d'une "itération", une opération qui remplit son
#+ entrée par sa sortie.
#  Quelque fois, le résultat est une série "chaotique".


MAX_ITERATIONS=200
# Pour une grande échelle de nombre (&gt;32000), augmenter MAX_ITERATIONS.

h=${1:-$$}                      #  Nombre de recherche
                                #  Utiliser $PID comme nombre de recherche,
                                #+ si il n'est pas spécifié en argument de la
                                #+ ligne de commande.

echo
echo "C($h) --- $MAX_ITERATIONS Iterations"
echo

for ((i=1; i<=MAX_ITERATIONS; i++))
do

echo -n "$h     "
#          ^^^^^
#           tab

  let "reste = h % 2"
  if [ "$reste" -eq 0 ]       # Pair?
  then
    let "h /= 2"              # Divise par 2.
  else
    let "h = h*3 + 1"         # Multiplie par 3 et ajoute 1.
  fi


COLONNES=10                   # Sortie avec 10 valeurs par ligne.
let "retour_ligne = i % $COLONNES"
if [ "$retour_ligne" -eq 0 ]
then
  echo
fi  

done

echo

#  Pour plus d'informations sur cette fonction mathématique,
#+ voir _Computers, Pattern, Chaos, and Beauty_, par Pickover, p. 185 ff.,
#+ comme listé dans la bibliographie.

exit 0

