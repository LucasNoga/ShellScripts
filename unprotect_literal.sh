#! /bin/bash
# unprotect_literal.sh : Ne pas protéger les chaînes littérales

# set -vx

:"<<-'_UnProtect_Literal_String_Doc'

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
    vers '/dev/null' lorsque le script est lu la première fois.
    (Supprimez le commentaire de la commande ci-dessus pour voir cette action.)

    Supprimez la première ligne (Sha-Bang, #!) lors de l'utilisation de ce
    script en tant que procédure d'une bibliothèque. Dé-commentez aussi 
    le code d'exemple utilisé dans les deux places indiquées.


    Utilisation:
        Complément de la fonction "$(_pls 'Chaine litterale')".
        (Voir l'exemple protect_literal.sh.)

        VarChaine=$(_upls VariableChaineProtege)

    Fait:
        Lorsqu'utilisé sur le côté droit d'une instruction d'affectation ;
        fait que la substition est intégré à la chaîne protégée.

    Notes:
        Les noms étranges (_*) sont utilisé pour éviter de rencontrer ceux
        choisis par l'utilisateur lorsqu'il l'utilise en tant que bibliothèque.


_UnProtect_Literal_String_Doc"

_upls() {
    local IFS=$'x1B'                # Caractère \ESC (non requis)
    eval echo $@                    # Substitution on the glob.
}

# :<<-'_UnProtect_Literal_String_Test'
# # # Supprimez le "# " ci-dessus pour désactiver ce code. # # #


_pls() {
    local IFS=$'x1B'                # Caractère \ESC (non requis)
    echo $'\x27'$@$'\x27'           # Paramètre global codé en dur.
}

# Déclare un tableau pour les valeurs de tests.
declare -a tableauZ

# Affecte les éléments avec des types différents de guillements et échappements.
tableauZ=( zero "$(_pls 'Bonjour ${Moi}')" 'Bonjour ${Toi}' "\'Passe: ${pw}\'" )

# Maintenant, faire une affectation avec ce résultat.
declare -a tableau2=( ${tableauZ[@]} )

# Ce qui fait :
# - - Test trois - -
# Elément 0: zero est d'une longueur 4            # Notre élément marqueur.
# Elément 1: Bonjour ${Moi} est d'une longueur 11 # Résultat attendu.
# Elément 2: Bonjour est d'une longueur 5         # ${Toi} ne renvoit rien.
# Elément 3: 'Passe est d'une longueur 6          # Divisé sur les espaces.
# Elément 4: ' est d'une longueur 1               # La fin du guillemet est ici
                                                  # maintenant.

# set -vx

#  Initialise 'Moi' avec quelque-chose pour la substitution imbriqué ${Moi}.
#  Ceci a besoin d'être fait SEULEMENT avant d'évaluer la chaîne protégée.
#  (C'est pourquoi elle a été protégée.)

Moi="au gars du tableau."

# Initialise une variable de chaînes de caractères pour le résultat.
nouvelleVariable=$(_upls ${tableau2[1]})

# Affiche le contenu.
echo $nouvelleVariable

# Avons-nous réellement besoin d'une fonction pour faire ceci ?
variablePlusRecente=$(eval echo ${tableau2[1]})
echo $variablePlusRecente

#  J'imagine que non mais la fonction _upls nous donne un endroit où placer la
#+ documentation.
#  Ceci aide lorsque nous oublions une construction # comme ce que signifie
#+ $(eval echo ... ).

#  Que se passe-t'il si Moi n'est pas initialisé quand la chaîne protégée est
#+ évaluée ?
unset Moi
variableLaPlusRecente=$(_upls ${tableau2[1]})
echo $variableLaPlusRecente

# Simplement partie, pas d'aide, pas d'exécution, pas d'erreurs.

#  Pourquoi ?
#  Initialiser le contenu d'une variable de type chaîne contenant la séquence de
#+ caractères qui ont une signification dans Bash est un problème général
#+ d'écriture des scripts.
#
#  Ce problème est maintenant résolu en huit lignes de code (et quatre pages de
#+ description).

#  Où cela nous mène-t'il ?
#  Les pages web au contenu dynamique en tant que tableau de chaînes Bash.
#  Le contenu par requête pour une commande Bash 'eval' sur le modèle de page
#+ stocké.
#  Pas prévu pour remplacer PHP, simplement quelque chose d'intéressant à faire.
###
#  Vous n'avez pas une application pour serveur web ?
#  Aucun problème, vérifiez dans le répertoire d'exemples des sources Bash :
#+ il existe aussi un script Bash pour faire ça. 

# _UnProtect_Literal_String_Test
# # # Supprimez le "# " ci-dessus pour désactiver ce code. # # #

exit 0

