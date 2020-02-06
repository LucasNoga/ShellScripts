#! /bin/bash
#
# Un très simplifié "renommeur" de fichiers (basé sur "lowercase.sh").
#
#  L'utilitaire "ren", par Vladimir Lanin (lanin@csd2.nyu.edu),
#+ fait un bien meilleur travail que ceci.


ARGS=2
E_MAUVAISARGS=65
UN=1                   # Pour avoir correctement singulier ou pluriel
                       # (voir plus bas.)

if [ $# -ne "$ARGS" ]
then
  echo "Usage: `basename $0` ancien-modele nouveau-modele"
  #  Comme avec "rn gif jpg", qui renomme tous les fichiers gif du répertoire
  #+ courant en jpg.
  exit $E_MAUVAISARGS
fi

nombre=0               # Garde la trace du nombre de fichiers renommés.


for fichier in *$1*    # Vérifie tous les fichiers correspondants du répertoire.
do
   if [ -f "$fichier" ]  # S'il y a correspondance...
   then
     fname=`basename $fichier`             # Supprime le chemin.
     n=`echo $fname | sed -e "s/$1/$2/"`   # Substitue ancien par nouveau dans
                                           # le fichier.
     mv $fname $n                          # Renomme.
     let "nombre += 1"
   fi
done   

if [ "$nombre" -eq "$UN" ]                # Pour une bonne grammaire.
then
  echo "$nombre fichier renommé."
else 
  echo "$nombre fichiers renommés."
fi 

exit 0


# Exercices:
# ---------
# Avec quel type de fichiers cela ne fonctionnera pas?
# Comment corriger cela?
#
#  Réécrire ce script pour travailler sur tous les fichiers d'un répertoire,
#+ contenant des espaces dans leur noms, et en les renommant après avoir
#+ substitué chaque espace par un tiret bas.