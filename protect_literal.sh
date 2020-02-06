#! /bin/bash
# protect_literal.sh Protéger les chaînes littérales

# set -vx

:"<<-'_Protect_Literal_String_Doc'

    Copyright (c) Michael S. Zick, 2003; All Rights Reserved
    License: Unrestricted reuse in any form, for any purpose.
    Warranty: None
    Revision: $ID$

    Copyright (c) Michael S. Zick, 2003; Tous droits réservés
    Licence: Utilisation non restreinte quelque soit sa forme, quelque soit le
    but.
    Garantie : Aucune
    Revision: $ID$

    Documentation redirigée vers no-operation sous Bash. Bash enverra ce bloc
    vers '/dev/null' lorsque le script sera lu la première fois.
    (Supprimez le commentaire de la commande ci-dessus pour voir cette action.)

    Supprimez la première ligne (Sha-Bang, #!) lors de l'utilisation de ce
    script en tant que procédure d'une bibliothèque. Décommentez aussi 
    le code d'exemple utilisé dans les deux places indiquées.


    Usage:
        _protect_literal_str 'une chaine quelconque qui correspond à votre
        ${fantaisie}'
        Affiche simplement l'argument sur la sortie standard, les guillemets étant
        restaurés.

        $(_protect_literal_str 'une chaine quelconque qui correspond à votre
        ${fantaisie}')
        sur le côté droit d'une instruction d'affectation.

    Fait:
        Utilisé sur le côté droit d'une affectation, préserve les guillemets
        protégeant le contenu d'un littéral lors de son affectation.

    Notes:
        Les noms étranges (_*) sont utilisé pour éviter de rencontrer ceux
        choisis par l'utilisateur lorsqu'il l'utilise en tant que bibliothèque.


_Protect_Literal_String_Doc

# La fonction 'pour illustration'"

_protect_literal_str() {

# Récupére un caractère inutilisé, non affichable comme IFS local.
# Non requis, mais montre ce que nous ignorons.
    local IFS=$'\x1B'               # caractère \ESC

# Entoure tous_elements_de entre guillemets lors de l'affectation.
    local tmp=$'\x27'$@$'\x27'
#    local tmp=$'\''$@$'\''         # Encore plus sale.

    local len=${#tmp}               # Info seulement.
    echo $tmp a une longueur de $len.         # Sortie ET information.
}

# Ceci est la version nom-court.
_pls() {
    local IFS=$'x1B'                # caractère \ESC (non requis)
    echo $'\x27'$@$'\x27'           # Paramètre global codé en dur
}

# :<<-'_Protect_Literal_String_Test'
# # # Supprimez le "# " ci-dessus pour désactiver ce code. # # #

# Voir à quoi ressemble ceci une fois affiché.
echo
echo "- - Test Un - -"
_protect_literal_str 'Bonjour $utilisateur'
_protect_literal_str 'Bonjour "${nom_utilisateur}"'
echo

# Ce qui donne :
# - - Test Un - -
# 'Bonjour $utilisateur' fait 13 caractères de long.
# 'Bonjour "${nom_utilisateur}"' a une taille de 21 caractères.

#  Cela ressemble à notre attente, donc pourquoi tout ceci ?
#  La différence est cachée à l'intérieur de l'ordonnancement interne des opérations
#+ de Bash.
#  Ce qui s'affiche lorsque vous l'utilisez sur le côté droit de l'affectation.

# Déclarez un tableau pour les valeurs de tests.
declare -a tableauZ

#  Affecte les éléments comprenant différents types de guillemets et de caractères
#+ d'échappement.
tableauZ=( zero "$(_pls 'Bonjour ${Moi}')" 'Bonjour ${Toi}' "\'Passe: ${pw}\'" )

# Maintenant, affiche ce tableau.
echo "- - Test Deux - -"
for (( i=0 ; i<${#tableauZ[*]} ; i++ ))
do
    echo  Elément $i: ${tableauZ[$i]} fait  ${#tableauZ[$i]} caractères de long.
done
echo

# Ce qui nous donne :
# - - Test Deux - -
# Elément 0: zero fait 4 caractères de long.           # Notre élément marqueur
# Elément 1: 'Bonjour ${Moi}' fait 13 caractères de long.# Notre "$(_pls '...' )"
# Elément 2: Bonjour ${Toi} fait 12 caractères de long.  # Les guillemets manquent
# Elément 3: \'Passe: \' fait 10 caractères de long.    # ${pw} n'affiche rien

# Maintenant, affectez ce résultat.
declare -a tableau2=( ${tableauZ[@]} )

# Et affiche ce qui s'est passé.
echo "- - Test Trois - -"
for (( i=0 ; i<${#tableau2[*]} ; i++ ))
do
    echo  Elément $i: ${tableau2[$i]} fait ${#tableau2[$i]} caractères de long.
done
echo

# Ce qui nous donne :
# - - Test Trois - -
# Elément 0: zero fait 4 caractères de long.         # Notre élément marqueur.
# Elément 1: Hello ${Moi} fait 11 caractères de long.# Résultat attendu.
# Elément 2: Hello fait 5 caractères de long.        # ${Toi} n'affiche rien.
# Elément 3: 'Passe: fait 6 caractères de long.      # Se coupe sur les espaces.
# Elément 4: ' fait 1 caractères de long.            # Le guillemet final est ici
                                                     # maintenant.

#  Les guillemets de début et de fin de notre élément 1 sont supprimés.
#  Bien que non affiché, les espaces blancs de début et de fin sont aussi supprimés.
#  Maintenant que le contenu des chaînes est initialisé, Bash placera toujours, en interne,
#+ entre guillemets les contenus comme requis lors de ses opérations.

#  Pourquoi?
#  En considérant notre construction "$(_pls 'Hello ${Moi}')" :
#  " ... " -> Supprime les guillemets.
#  $( ... ) -> Remplace avec le resultat de ..., supprime ceci.
#  _pls ' ... ' -> appelé avec des arguments littérales, supprime les guillemets.
#  Le résultat renvoyé inclut les guillemets ; MAIS le processus ci-dessus a déjà
#+ été réalisé, donc il devient une partie de la valeur affectée.
#
#  De manière identique, lors d'une utilisation plus poussée de la variable de type
#+ chaînes de caractères, le ${Moi} fait partie du contenu (résultat) et survit à
#+ toutes les opérations.
#  (Jusqu'à une indication explicite pour évaluer la chaîne).

#  Astuce : Voir ce qui arrive lorsque les guillemets ($'\x27') sont remplacés par
#+ des caractères ($'\x22') pour les procédures ci-dessus.
#  Intéressant aussi pour supprimer l'ajout de guillemets.

# _Protect_Literal_String_Test
# # # Supprimez le caractère "# " ci-dessus pour désactiver ce code. # # #

exit 0

