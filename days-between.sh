#!/bin/bash
#days-between : Calculer le nombre de jours entre deux dates.

# Usage: ./days-between.sh [M]M/[D]D/AAAA [M]M/[D]D/AAAA
#
# Note: Script modifié pour tenir compte des changements dans Bash 2.05b +
#+      qui ont fermé la "fonctionnalité" permettant de renvoyer des valeurs
#+      entières négatives grandes.

#  Comparez ce script avec l'implémentation de la formule de Gauss en C sur
#+ http://buschencrew.hypermart.net/software/datedif

ARGS=2                # Deux arguments attendus en ligne de commande.
E_PARAM_ERR=65        # Erreur de paramètres.

ANNEEREF=1600         # Année de référence.
SIECLE=100
JEA=365
AJUST_DIY=367         # Ajusté pour l'année bissextile + fraction.
MEA=12
JEM=31
CYCLE=4

MAXRETVAL=256         #  Valeur de retour positive la plus grande possible
                      #+ renvoyée par une fonction.

diff=                 #  Déclaration d'une variable globale pour la différence
                      #+ de date.
value=                #  Déclaration d'une variable globale pour la valeur
                      #+ absolue.
jour=                 #  Déclaration de globales pour jour, mois, année.
mois=
annee=


Erreur_Param ()        # Mauvais paramètres en ligne de commande.
{
  echo "Usage: `basename $0` [M]M/[D]D/YYYY [M]M/[D]D/YYYY"
  echo "       (la date doit être supérieure au 1/3/1600)"
  exit $E_PARAM_ERR
}  


Analyse_Date ()                #  Analyse la date à partir des paramètres en
{                              #+ ligne de commande.
  mois=${1%%/**}
  jm=${1%/**}                  # Jour et mois.
  jour=${dm#*/}
  let "annee = `basename $1`"  #  Pas un nom de fichier mais fonctionne de la
                               #+ même façon.
}  


verifie_date ()                 # Vérifie la validité d'une date.
{
  [ "$jour" -gt "$JEM" ] || [ "$mois" -gt "$MEA" ] ||
  [ "$annee" -lt "$ANNEEREF" ] && Erreur_Param
  # Sort du script si mauvaise(s) valeur(s).
  # Utilise une liste-ou ou une liste-et.
  #
  # Exercice: Implémenter une vérification de date plus rigoureuse.
}


supprime_zero_devant () #  Il est préférable de supprimer les zéros possibles
{                       #+ du jour et/ou du mois sinon Bash va les
  val=${1#0}            #+ interpréter comme des valeurs octales
  return $val           #+ (POSIX.2, sect 2.9.2.1).
}


index_jour ()         # Formule de Gauss:
{                     # Nombre de jours du 1er mars 1600 jusqu'à la date passée
                      # en arguments.

  jour=$1
  mois=$2
  annee=$3

  let "mois = $mois - 2"
  if [ "$mois" -le 0 ]
  then
    let "mois += 12"
    let "annee -= 1"
  fi  

  let "annee -= $ANNEEREF"
  let "indexyr = $annee / $SIECLE"


  let "Jours = $JEA*$annee + $annee/$CYCLE - $indexyr \
               + $indexyr/$CYCLE + $AJUST_DIY*$mois/$MEA + $jour - $JEM"
  # Pour une explication en détails de cet algorithme, voir
  #+   http://weblogs.asp.net/pgreborio/archive/2005/01/06/347968.aspx

  echo $Days

}  


calcule_difference ()              # Différence entre les indices de deux jours.
{
  let "diff = $1 - $2"             # Variable globale.
}  


abs ()                             #  Valeur absolue.
{                                  #  Utilise une variable globale "valeur".
  if [ "$1" -lt 0 ]                #  Si négatif
  then                             #+ alors
    let "value = 0 - $1"           #+ change de signe,
  else                             #+ sinon
    let "value = $1"               #+ on le laisse.
  fi
}



if [ $# -ne "$ARGS" ]            # Requiert deux arguments en ligne de commande.
then
  Erreur_Param
fi  

Analyse_Date $1
verifie_date $jour $mois $annee      #  Vérifie si la date est valide.

supprime_zero_devant $jour           #  Supprime tout zéro débutant
jour=$?                              #+ sur le jour et/ou le mois.
supprime_zero_devant $mois
mois=$?

let "date1 = `day_index $jour $mois $annee`"

Analyse_Date $2
verifie_date $jour $mois $annee

supprime_zero_devant $jour
jour=$?
supprime_zero_devant $mois
mois=$?

date2 = $(day_index $jour $mois $annee)  # Substitution de commande


calcule_difference $date1 $date2

abs $diff                          # S'assure que c'est positif.
diff=$value

echo $diff

exit 0