#!/bin/bash
# obj-oriented.sh: programmation orientée objet dans un script shell.

#  Note Importante :
#  Si vous exécutez ce script avec une version 3 ou ultérieure de Bash,
#+ remplacez tous les points dans les noms de fonctions avec un caractère légal, par exemple un tiret bas.

# Ressemble à la déclaration d'une classe en C++.
person.new(){
  local nom_objet=$1 nom=$2 prenom=$3 datenaissance=$4

  eval "$nom_objet.set_nom() {
          eval \"$nom_objet.get_nom() {
                   echo \$1
                 }\"
        }"

  eval "$nom_objet.set_prenom() {
          eval \"$nom_objet.get_prenom() {
                   echo \$1
                 }\"
        }"

  eval "$nom_objet.set_datenaissance() {
          eval \"$nom_objet.get_datenaissance() {
            echo \$1
          }\"
          eval \"$nom_objet.show_datenaissance() {
            echo \$(date -d \"1/1/1970 0:0:\$1 GMT\")
          }\"
          eval \"$nom_objet.get_age() {
            echo \$(( (\$(date +%s) - \$1) / 3600 / 24 / 365 ))
          }\"
        }"

  $nom_objet.set_nom $nom
  $nom_objet.set_prenom $prenom
  $nom_objet.set_datenaissance $datenaissance
}

echo

person.new self Bozeman Bozo 101272413
#  Crée une instance de "person.new" (en fait, passe les arguments à la
#+ fonction).

self.get_prenom              #   Bozo
self.get_nom                 #   Bozeman
self.get_age                 #   28
self.get_datenaissance       #   101272413
self.show_datenaissance      #   Sat Mar 17 20:13:33 MST 1973

echo

#  typeset -f
#+ pour voir les fonctions créées (attention, cela fait défiler la page).

exit 0

