 Exemple A.14. password: Générer des mots de passe aléatoires de 8 caractères

#!/bin/bash
#  Pourrait nécessiter d'être appelé avec un #!/bin/bash2 sur les anciennes
#+ machines.
#
#  Générateur de mots de passe aléatoires pour Bash 2.x +
#+ par Antek Sawicki <tenox@tenox.tc>,
#  qui a généreusement permis à l'auteur du guide ABS de l'utiliser ici.
#
# ==> Commentaires ajoutés par l'auteur du document ==>


MATRICE="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
# ==> Les mots de passe seront constitués de caractères alphanumériques.
LONGUEUR="8"
# ==> Modification possible de 'LONGUEUR' pour des mots de passe plus longs.


while [ "${n:=1}" -le "$LONGUEUR" ]
# ==> Rappelez-vous que := est l'opérateur de "substitution par défaut".
# ==> Donc, si 'n' n'a pas été initialisé, l'initialiser à 1.
do
        PASS="$PASS${MATRICE:$(($RANDOM%${#MATRICE})):1}"
        # ==> Très intelligent, pratiquement trop astucieux.

        # ==> Commençons par le plus intégré...
        # ==> ${#MATRICE} renvoie la longueur du tableau MATRICE.

        # ==> $RANDOM%${#MATRICE} renvoie un nombre aléatoire entre 1 et la
        # ==> longueur de MATRICE - 1.

        # ==> ${MATRICE:$(($RANDOM%${#MATRICE})):1}
        # ==> renvoie l'expansion de MATRICE à une position aléatoire, par
        # ==> longueur 1. 
        # ==> Voir la substitution de paramètres {var:pos:len}, section 3.3.1
        # ==> et les exemples suivants.

        # ==> PASS=... copie simplement ce résultat dans PASS (concaténation).

        # ==> Pour mieux visualiser ceci, décommentez la ligne suivante
        # ==>             echo "$PASS"
        # ==> pour voir la construction de PASS, un caractère à la fois,
        # ==> à chaque itération de la boucle.

        let n+=1
        # ==> Incrémentez 'n' pour le prochain tour.
done

echo "$PASS"      # ==> Ou, redirigez le fichier, comme voulu.

exit 0