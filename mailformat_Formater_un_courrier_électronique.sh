#!/bin/bash
#  mail-format.sh (ver. 1.1) : Formate les courriers électroniques.

#  Supprime les caractères '>', les tabulations et coupe aussi les lignes
#+ excessivement longues.

# =================================================================
#                 Vérification standard des argument(s) du script
ARGS=1
E_MAUVAISARGS=65
E_PASDEFICHIER=66

if [ $# -ne $ARGS ]  # Le bon nombre d'arguments a-t'il été passé au script?
then
  echo "Usage: `basename $0` nomfichier"
  exit $E_MAUVAISARGS
fi

if [ -f "$1" ]       # Vérifie si le fichier existe.
then
    nomfichier=$1
else
    echo "Le fichier \"$1\" n'existe pas."
    exit $E_PASDEFICHIER
fi
# =================================================================

LONGUEUR_MAX=70
# Longueur à partir de laquelle on coupe les lignes excessivement longues.

# ---------------------------------
# Une variable peut contenir un script sed.
scriptsed='s/^>//
s/^  *>//
s/^  *//
s/              *//'
# ---------------------------------

#  Supprime les caractères '>' et tabulations en début de lignes,
#+ puis coupe les lignes à $LONGUEUR_MAX caractères.
sed "$scriptsed" $1 | fold -s --width=$LONGUEUR_MAX
#  option -s pour couper les lignes à une espace blanche, si possible.


#  Ce script a été inspiré par un article d'un journal bien connu
#+ proposant un utilitaire Windows de 164Ko pour les mêmes fonctionnalités.
#
#  Un joli ensemble d'utilitaires de manipulation de texte et un langage de
#+ scripts efficace apportent une alternative à des exécutables gonflés.

exit 0