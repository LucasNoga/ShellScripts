#!/bin/bash
# soundex: Calcule le code "soundex" pour des noms


#
#  Une version légèrement différente de ce script est apparu dans
#+ la colonne "Shell Corner" d'Ed Schaefer en juillet 2002
#+ du magazine en ligne "Unix Review",
#+ http://www.unixreview.com/documents/uni1026336632258/

NBARGS=1                     # A besoin du nom comme argument.
E_MAUVAISARGS=70

if [ $# -ne "$NBARGS" ]
then
  echo "Usage: `basenom $0` nom"
  exit $E_MAUVAISARGS
fi  


affecte_valeur ()              #  Affecte une valeur numérique
{                              #+ aux lettres du nom.

  val1=bfpv                    # 'b,f,p,v' = 1
  val2=cgjkqsxz                # 'c,g,j,k,q,s,x,z' = 2
  val3=dt                      #  etc.
  val4=l
  val5=mn
  val6=r

# Une utilisation particulièrement intelligente de 'tr' suit.
# Essayez de comprendre ce qui se passe ici.

valeur=$( echo "$1" \
| tr -d wh \
| tr $val1 1 | tr $val2 2 | tr $val3 3 \
| tr $val4 4 | tr $val5 5 | tr $val6 6 \
| tr -s 123456 \
| tr -d aeiouy )

# Affecte des valeurs aux lettres.
# Supprime les numéros dupliqués, sauf s'ils sont séparés par des voyelles.
# Ignore les voyelles, sauf en tant que séparateurs, donc les supprime à la fin.
# Ignore 'w' et 'h', même en tant que séparateurs, donc les supprime au début.
#
# La substitution de commande ci-dessus utilise plus de tube qu'un plombier
# <g>.

}  


nom_en_entree="$1"
echo
echo "Nom = $nom_en_entree"


# Change tous les caractères en entrée par des minuscules.
# ------------------------------------------------
nom=$( echo $nom_en_entree | tr A-Z a-z )
# ------------------------------------------------
# Au cas où cet argument est un mélange de majuscules et de minuscules.


# Préfixe des codes soundex: première lettre du nom.
# --------------------------------------------


pos_caract=0                     # Initialise la position du caractère.
prefixe0=${nom:$pos_caract:1}
prefixe=`echo $prefixe0 | tr a-z A-Z`
                                 # Met en majuscule la première lettre de soundex.

let "pos_caract += 1"            # Aller directement au deuxième caractères.
nom1=${nom:$pos_caract}


# ++++++++++++++++++++++++++ Correctif Exception +++++++++++++++++++++++++++++++++
#  Maintenant, nous lançons à la fois le nom en entrée et le nom décalé d'un
#+ caractère vers la droite au travers de la fonction d'affectation de valeur.
#  Si nous obtenons la même valeur, cela signifie que les deux premiers
#+ caractères du nom ont la même valeur et que l'une d'elles doit être annulée.
#  Néanmoins, nous avons aussi besoin de tester si la première lettre du nom est
#+ une voyelle ou 'w' ou 'h', parce que sinon cela va poser problème.

caract1=`echo $prefixe | tr A-Z a-z`    # Première lettre du nom en minuscule.

affecte_valeur $nom
s1=$valeur
affecte_valeur $nom1
s2=$valeur
affecte_valeur $caract1
s3=$valeur
s3=9$s3                              #  Si la première lettre du nom est une
                                     #+ voyelle ou 'w' ou 'h',
                                     #+ alors sa "valeur" sera nulle (non
                                     #+ initialisée).
                                     #+ Donc, positionnons-la à 9, une autre
                                     #+ valeur non utilisée, qui peut être
                                     #+ vérifiée.


if [[ "$s1" -ne "$s2" || "$s3" -eq 9 ]]
then
  suffixe=$s2
else  
  suffixe=${s2:$pos_caract}
fi  
# ++++++++++++++++++++++ fin Correctif Exception +++++++++++++++++++++++++++++++++


fin=000                    # Utilisez au moins 3 zéro pour terminer.


soun=$prefixe$suffixe$fin  # Terminez avec des zéro.

LONGUEURMAX=4              # Tronquer un maximum de 4 caractères
soundex=${soun:0:$LONGUEURMAX}

echo "Soundex = $soundex"

echo

#  Le code soundex est une méthode d'indexage et de classification de noms
#+ en les groupant avec ceux qui sonnent de le même façon.
#  Le code soundex pour un nom donné est la première lettre de ce nom, suivi par
#+ un code calculé sur trois chiffres.
#  Des noms similaires devraient avoir les mêmes codes soundex

#   Exemples:
#   Smith et Smythe ont tous les deux le soundex "S-530"
#   Harrison = H-625
#   Hargison = H-622
#   Harriman = H-655

#  Ceci fonctionne assez bien en pratique mais il existe quelques anomalies.
#
#
#  Certaines agences du gouvernement U.S. utilisent soundex, comme le font les
#  généalogistes.
#
#  Pour plus d'informations, voir
#+ "National Archives and Records Administration home page",
#+ http://www.nara.gov/genealogy/soundex/soundex.html



# Exercice:
# --------
# Simplifier la section "Correctif Exception" de ce script.

exit 0

