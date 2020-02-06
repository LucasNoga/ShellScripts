#!/bin/bash
# hash-example.sh: Colorisation de texte en utilisant les fonctions de hachage
# Auteur : Mariusz Gniazdowski <mgniazd-at-gmail.com>

. Hash.lib      # Chargement de la bibliothèque des fonctions.

hash_set couleurs rouge        "\033[0;31m"
hash_set couleurs bleu         "\033[0;34m"
hash_set couleurs bleu_leger   "\033[1;34m"
hash_set couleurs rouge_leger  "\033[1;31m"
hash_set couleurs cyan         "\033[0;36m"
hash_set couleurs vert_leger   "\033[1;32m"
hash_set couleurs gris_leger   "\033[0;37m"
hash_set couleurs vert         "\033[0;32m"
hash_set couleurs jaune        "\033[1;33m"
hash_set couleurs violet_leger "\033[1;35m"
hash_set couleurs violet       "\033[0;35m"
hash_set couleurs reset_couleur "\033[0;00m"


# $1 - nom de la clé
# $2 - valeur
essaie_couleurs() {
        echo -en "$2"
        echo "Cette ligne est $1."
}

hash_foreach couleurs essaie_couleurs
hash_echo couleurs reset_couleur -en

echo -e '\nSurchargeons quelques couleurs avec du jaune.\n'
# Il est difficile de lire du texte jaune sur certains terminaux.
hash_dup couleurs jaune rouge vert_leger bleu vert gris_leger cyan
hash_foreach couleurs essaie_couleurs
hash_echo couleurs reset_color -en

echo -e '\nSupprimons-les et essayons couleurs une fois encore...\n'

for i in rouge vert_leger bleu vert gris_leger cyan; do
        hash_unset couleurs $i
done
hash_foreach couleurs essaie_couleurs
hash_echo couleurs reset_couleur -en

hash_set autre texte "Autres exemples..."
hash_echo autre texte
hash_get_into autre txt texte
echo $texte

hash_set autre my_fun essaie_couleurs
hash_call autre my_fun   purple "`hash_echo couleurs violet`"
hash_echo couleurs reset_couleur -en

echo; echo "Retour à la normale ?"; echo

exit $?