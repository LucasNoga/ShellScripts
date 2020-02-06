#!/bin/bash
# life : Jeu de la Vie
# Version 2: Corrigé par Daniel Albers
#+           pour permettre d'avoir en entrée des grilles non carrées.

# ########################################################################## #
# Ce script est la version Bash du "Jeu de la vie" de John Conway.           #
# "Life" est une implémentation simple d'automatisme cellulaire.             #
# -------------------------------------------------------------------------- #
# Sur un tableau rectangulaire, chaque "cellule" sera soit "vivante"         #
# soit "morte". On désignera une cellule vivante avec un point et une        #
# cellule morte avec une espace.                                             #
#  Nous commençons avec un tableau composé aléatoirement de points et        #
#+ d'espaces. Ce sera la génération de départ, "génération 0".               #
# Déterminez chaque génération successive avec les règles suivantes :        #
# 1) Chaque cellule a huit voisins, les cellules voisines (gauche,           #
#+   droite, haut, bas ainsi que les quatre diagonales.                      #
#                                                                            #
#                       123                                                  #
#                       4*5       L'étoile est la cellule en question.       #
#                       678                                                  #
#                                                                            #
# 2) Une cellule vivante avec deux ou trois voisins vivants reste            #
#+   vivante.                                                                #
SURVIE=2                                                                     #
# 3) Une cellule morte avec trois cellules vivantes devient vivante          #
#+   (une "naissance").                                                      #
NAISSANCE=3                                                                  #
# 4) Tous les autres cas concerne une cellule morte pour la prochaine        #
#+   génération.                                                             #
# ########################################################################## #


fichier_de_depart=fichier_jeu_life.sh   # Lit la génération de départ à partir du fichier "gen0".
                         #  Par défaut, si aucun autre fichier n'est spécifié à
                         #+ l'appel de ce script.
                         #
if [ -n "$1" ]           # Spécifie un autre fichier "génération 0".
then
  fichier_de_depart="$1"
fi


######################################################
#  Annule le script si fichier_de_depart non spécifié
#+ et
#+ gen0 non présent.

E_PASDEFICHIERDEPART=68

if [ ! -e "$fichier_de_depart" ]
then
  echo "Fichier de départ \""$fichier_de_depart"\" manquant !"
  exit $E_PASDEFICHIERDEPART
fi
######################################################

VIVANT1=.
MORT1=_
        # Représente des cellules vivantes et "mortes" dans le fichier de départ.

#  ---------------------------------------------------------- #
#  Ce script utilise un tableau 10 sur 10 (pourrait être augmenté
#+ mais une grande grille ralentirait de beaucoup l'exécution).
LIGNES=10
COLONNES=10
#  Modifiez ces deux variables pour correspondre à la taille
#+ de la grille, si nécessaire.
#  ---------------------------------------------------------- #

GENERATIONS=10          #  Nombre de générations pour le cycle.
                        #  Ajustez-le en l'augmentant si vous en avez le temps.

AUCUNE_VIVANTE=80       #  Code de sortie en cas de sortie prématurée,
                        #+ si aucune cellule n'est vivante.
VRAI=0
FAUX=1
VIVANTE=0
MORTE=1

avar=                   #  Global; détient la génération actuelle.
generation=0            # Initialise le compteur des générations.

# =================================================================


let "cellules = $LIGNES * $COLONNES"
                        # Nombre de cellules.

declare -a initial      # Tableaux contenant les "cellules".
declare -a current

affiche ()
{

alive=0                 # Nombre de cellules "vivantes" à un moment donné.
                        # Initialement à zéro.

declare -a tab
tab=( `echo "$1"` )     # Argument convertit en tableau.

nombre_element=${#tab[*]}

local i
local verifligne

for ((i=0; i<$nombre_element; i++))
do

# Insère un saut de ligne à la fin de chaque ligne.
  let "verifligne = $i % COLONNES"
  if [ "$verifligne" -eq 0 ]
  then
    echo                # Saut de ligne.
    echo -n "      "    # Indentation.
  fi  

  cellule=${tab[i]}

  if [ "$cellule" = . ]
  then
    let "vivante += 1"
  fi  

  echo -n "$cellule" | sed -e 's/_/ /g'
  # Affiche le tableau et modifie les tirets bas en espaces.
done  

return

}

EstValide ()                            # Teste si les coordonnées sont valides.
{

  if [ -z "$1"  -o -z "$2" ]          # Manque-t'il des arguments requis ?
  then
    return $FAUX
  fi

local ligne
local limite_basse=0                   # Désactive les coordonnées négatives.
local limite_haute
local gauche
local droite

let "limite_haute = $LIGNES * $COLONNES - 1" # Nombre total de cellules.


if [ "$1" -lt "$limite_basse" -o "$1" -gt "$limite_haute" ]
then
  return $FAUX                       # En dehors des limites.
fi  

ligne=$2
let "gauche = $ligne * $COLONNES"            # Limite gauche.
let "droite = $gauche + $COLONNES - 1"       # Limite droite.

if [ "$1" -lt "$gauche" -o "$1" -gt "$droite" ]
then
  return $FAUX                       # En dehors des limites.
fi  

return $VRAI                          # Coordonnées valides.

}  


EstVivante ()           # Teste si la cellule est vivante.
                        #  Prend un tableau, un numéro de cellule et un état de
                        #+ cellule comme arguments.
{
  ObtientNombre "$1" $2 # Récupère le nombre de cellules vivantes dans le voisinage.
  local voisinage=$?


  if [ "$voisinage" -eq "$NAISSANCE" ]  # Vivante dans tous les cas.
  then
    return $VIVANTE
  fi

  if [ "$3" = "." -a "$voisinage" -eq "$SURVIE" ]
  then                  # Vivante uniquement si précédemment vivante.
    return $VIVANTE
  fi  

  return $MORTE          # Par défaut.

}  


ObtientNombre ()        # Compte le nombre de cellules vivantes dans le
                        # voisinage de la cellule passée en argument.
                        # Deux arguments nécessaires :
                        # $1) tableau contenant les variables
                        # $2) numéro de cellule
{
  local numero_cellule=$2
  local tableau
  local haut
  local centre
  local bas
  local l
  local ligne
  local i
  local t_hau
  local t_cen
  local t_bas
  local total=0
  local LIGNE_NHBD=3

  tableau=( `echo "$1"` )

  let "haut = $numero_cellule - $COLONNES - 1"  #  Initialise le voisinage de la
                                                #+ cellule.
  let "centre = $numero_cellule - 1"
  let "bas = $numero_cellule + $COLONNES - 1"
  let "l = $numero_cellule / $COLONNES"

  for ((i=0; i<$LIGNE_NHBD; i++))     # Parcours de gauche à droite.
  do
    let "t_hau = $haut + $i"
    let "t_cen = $centre + $i"
    let "t_bas = $bas + $i"


    let "ligne = $l"                  # Calcule la ligne centrée du voisinage.
    EstValide $t_cen $ligne           # Position de la cellule valide ?
    if [ $? -eq "$VRAI" ]
    then
      if [ ${tableau[$t_cen]} = "$VIVANT1" ] # Est-elle vivante ?
      then                            # Oui ?
        let "total += 1"              # Incrémenter le total.
      fi        
    fi  

    let "ligne = $l - 1"              # Compte la ligne du haut.
    EstValide $t_haut $haut
    if [ $? -eq "$VRAI" ]
    then
      if [ ${tableau[$t_haut]} = "$VIVANT1" ]  # Redondance.
      then                                     # Cela peut-il être optimisé ?
        let "total += 1"
      fi        
    fi  

    let "ligne = $l + 1"              # Compte la ligne du bas.
    EstValide $t_bas $ligne
    if [ $? -eq "$VRAI" ]
    then
      if [ ${tableau[$t_bas]} = "$VIVANT1" ] 
      then
        let "total += 1"
      fi        
    fi  

  done  


  if [ ${tableau[$numero_cellule]} = "$VIVANT1" ]
  then
    let "total -= 1"        #  S'assurer que la valeur de la cellule testée
  fi                        #+ n'est pas elle-même comptée.


  return $total
  
}

prochaine_gen ()               # Mise à jour du tableau des générations.
{

local tableau
local i=0

tableau=( `echo "$1"` )        # Argument passé converti en tableau.

while [ "$i" -lt "$cellules" ]
do
  EstVivante "$1" $i ${tableau[$i]}  # La cellule est-elle vivante ?
  if [ $? -eq "$VIVANTE" ]
  then                         #  Si elle l'est, alors
    tableau[$i]=.              #+ représente la cellule avec un point.
  else  
    tableau[$i]="_"            #  Sinon, avec un tiret bas.
   fi                          #+ (sera transformé plus tard en espace).
  let "i += 1" 
done   


# let "generation += 1"   # Incrémente le nombre de générations.
# Pourquoi cette ligne a-t'elle été mise en commentaire ?

# Initialise la variable à passer en tant que paramètre à la fonction
# "affiche".
une_var=`echo ${tableau[@]}` # Convertit un tableau en une variable de type chaîne.
affiche "$une_var"           # L'affiche.
echo; echo
echo "Génération $generation  -  $vivante vivante"

if [ "$alive" -eq 0 ]
then
  echo
  echo "Sortie prématurée : aucune cellule encore vivante !"
  exit $AUCUNE_VIVANTE    #  Aucun intérêt à continuer
fi                        #+ si aucune cellule n'est vivante.

}


# =========================================================

# main ()

# Charge un tableau initial avec un fichier de départ.
initial=( `cat "$fichier_de_depart" | sed -e '/#/d' | tr -d '\n' |\
sed -e 's/\./\. /g' -e 's/_/_ /g'` )
# Supprime les lignes contenant le symbole de commentaires '#'.
# Supprime les retours chariot et insère des espaces entre les éléments.

clear          # Efface l'écran.

echo #         Titre
echo "======================="
echo "    $GENERATIONS générations"
echo "           du"
echo "   \"Jeu de la Vie\""
echo "======================="


# -------- Affiche la première génération. --------
Gen0=`echo ${initial[@]}`
affiche "$Gen0"           # Affiche seulement.
echo; echo
echo "Génération $generation  -  $alive vivante"
# -------------------------------------------


let "generation += 1"     # Incrémente le compteur de générations.
echo

# ------- Affiche la deuxième génération. -------
Actuelle=`echo ${initial[@]}`
prochaine_gen "$Actuelle"          # Mise à jour & affichage.
# ------------------------------------------

let "generation += 1"     # Incrémente le compteur de générations.

# ------ Boucle principale pour afficher les générations conséquentes ------
while [ "$generation" -le "$GENERATIONS" ]
do
  Actuelle="$une_var"
  prochaine_gen "$Actuelle"
  let "generation += 1"
done
# ==============================================================

echo

exit 0 # FIN

# Le tableau dans ce script a un "problème de bordures".
# Les bordures haute, basse et des côtés avoisinent une absence de cellules mortes.
# Exercice: Modifiez le script pour avoir la grille
# +         de façon à ce que les côtés gauche et droit se touchent,
# +         comme le haut et le bas.
#
# Exercice: Créez un nouveau fichier "gen0" pour ce script.
#           Utilisez une grille 12 x 16, au lieu du 10 x 10 original.
#           Faites les modifications nécessaires dans le script,
#+          de façon à ce qu'il s'exécute avec le fichier modifié.
#
# Exercice: Modifiez ce script de façon à ce qu'il puisse déterminer la taille
#+          de la grille à partir du fichier "gen0" et initialiser toute variable
#+          nécessaire au bon fonctionnement du script.
#           Ceci rend inutile la modification des variables dans le script
#+          suite à un modification de la taille de la grille.
#
# Exercice : Optimisez ce script.
#            Le code est répétitif et redondant,
#+           par exemple aux lignes 335-336.

