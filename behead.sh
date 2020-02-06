#!/bin/sh
# behead: Supprimer les en-têtes des courriers électroniques et des nouvelles

if [ $# -eq 0 ]; then
# ==> Si pas d'arguments en ligne de commande, alors fonctionne avec un
# ==> fichier redirigé vers stdin.
        sed -e '1,/^$/d' -e '/^[        ]*$/d'
        # --> Supprime les lignes vides et les autres jusqu'à la première
        # --> commençant avec une espace blanche.
else
# ==> Si des arguments sont présents en ligne de commande, alors fonctionne avec
# ==> des fichiers nommés.
        for i do
                sed -e '1,/^$/d' -e '/^[        ]*$/d' $i
                # --> De même.
        done
fi

# ==> Exercice: Ajouter la vérification d'erreurs et d'autres options.
# ==>
# ==> Notez que le petit script sed se réfère à l'exception des arguments
# ==> passés.
# ==> Est-il intéressant de l'embarquer dans une fonction? Pourquoi?

