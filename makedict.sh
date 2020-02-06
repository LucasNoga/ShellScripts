#!/bin/bash
# makedict : Créer un dictionnaire

# Modification du script /usr/sbin/mkdict (/usr/sbin/cracklib-forman).
# Script original copyright 1993, par Alec Muffett.
#
#  Ce script modifié inclus dans ce document d'une manière consistente avec le
#+ document "LICENSE" du paquetage "Crack" dont fait partie le script original.

#  Ce script manipule des fichiers texte pour produire une liste triée de mots
#+ trouvés dans les fichiers.
#  Ceci pourrait être utile pour compiler les dictionnaires et pour d'autres
#+ buts lexicographiques.


E_MAUVAISARGS=65

if [ ! -r "$1" ]                     #  Au moins un argument, qui doit être
then                                 #+ un fichier valide.
        echo "Usage: $0 fichiers-à-manipuler"
  exit $E_MAUVAISARGS
fi  


# SORT="sort"                     #  Plus nécessaire de définir des options
                                  #+ pour sort. Modification du script
                                  #+ original.

cat $* |                          # Contenu des fichiers spécifiés vers stdout.
        tr A-Z a-z |              # Convertion en minuscule.
        tr ' ' '\012' |           #  Nouveau: modification des espaces en
                                  #+ retours chariot.
#       tr -cd '\012[a-z][0-9]' | #  Suppression de tout ce qui n'est pas
                                  #  alphanumérique
                                  #+ (dans le script original).
        tr -c '\012a-z'  '\012' | #  Plutôt que de supprimer les caractères
                                  #+ autres qu'alphanumériques,
                                  #+ les modifie en retours chariot.
        sort |                    #  Les options $SORT ne sont plus
                                  #+ nécessaires maintenant.
        uniq |                    # Suppression des mots dupliqués.
        grep -v '^#' |            #  Suppression des lignes commençant avec
                                  #+ le symbole '#'.
        grep -v '^$'              # Suppression des lignes blanches.

exit 0  

