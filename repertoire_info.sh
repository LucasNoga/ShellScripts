#! /bin/bash
# Analyse et affiche des informations sur le répertoire.

# NOTE: Modification des lignes 273 et 353 suivant le fichier "README".

# Contrôles
# Si outrepassé par les arguments de la commande, ils doivent être dans l'ordre:
#   Arg1: "Descripteur du répertoire"
#   Arg2: "Chemins à exclure"
#   Arg3: "Répertoires à exclure"
#
# Les variables d'environnement outrepassent les valeurs par défaut.
# Les arguments de la commande outrepassent les variables d'environnement.

# Emplacement par défaut du contenu des descripteurs de fichiers.
MD5UCFS=${1:-${MD5UCFS:-'/tmpfs/ucfs'}}

# Répertoires à exclure
declare -a \
  CHEMINS_A_EXCLURE=${2:-${CHEMINS_A_EXCLURE:-'(/proc /dev /devfs /tmpfs)'}}

# Répertoires à exclure
declare -a \
  REPERTOIRES_A_EXCLURE=${3:-${REPERTOIRES_A_EXCLURE:-'(ucfs lost+found tmp wtmp)'}}

# Fichiers à exclure
declare -a \
  FICHIERS_A_EXCLURE=${3:-${FICHIERS_A_EXCLURE:-'(core "Nom avec des espaces")'}}


# Document intégré utilisé comme bloc de commentaires.
: "&lt;&lt;LSfieldsDoc
# # # Affiche les informations sur les répertoires du système de fichiers # # #
#
#       AfficheRepertoire "FileGlob" "Field-Array-Name"
# ou
#       AfficheRepertoire -of "FileGlob" "Field-Array-Filename"
#       '-of' signifiant 'sortie vers fichier'
# # # # #

Description du format de la chaîne : ls (GNU fileutils) version 4.0.36

Produit une ligne (ou plus) formattée :
inode droits    liens propriétaire groupe ...
32736 -rw-------    1 mszick   mszick

taille jour mois date hh:mm:ss année chemin
2756608 Sun Apr 20 08:53:06 2003 /home/mszick/core

Sauf, s'il est formatté :
inode  droits    liens propriétaire groupe ...
266705 crw-rw----    1    root  uucp

majeur mineur jour mois date hh:mm:ss année chemin
4,  68 Sun Apr 20 09:27:33 2003 /dev/ttyS4
NOTE: cette virgule bizarre après le nombre majeur

NOTE: le 'chemin' pourrait avoir plusieurs champs :
/home/mszick/core
/proc/982/fd/0 -> /dev/null
/proc/982/fd/1 -> /home/mszick/.xsession-errors
/proc/982/fd/13 -> /tmp/tmpfZVVOCs (deleted)
/proc/982/fd/7 -> /tmp/kde-mszick/ksycoca
/proc/982/fd/8 -> socket:[11586]
/proc/982/fd/9 -> pipe:[11588]

Si ce n'est pas suffisant pour que votre analyseur continue à deviner,
soit une soit les deux parties du chemin peuvent être relatives :
../Built-Shared -> Built-Static
../linux-2.4.20.tar.bz2 -> ../../../SRCS/linux-2.4.20.tar.bz2

Le premier caractère du champ des droits (sur 11 (10 ?) caractères) :
's' Socket
'd' Répertoire
'b' Périphérique bloc
'c' Périphérique caractère
'l' Lien symbolique
NOTE: Les liens non symboliques ne sont pas identifiés - testés pour des numéros
d'inodes identiques sur le même système de fichiers.
Toutes les informations sur les fichiers liés sont partagées sauf le nom et
l'emplacement.
NOTE: Un "lien" est connu comme un "alias" sur certains systèmes.
'-' fichier sans distinction.

Suivi par trois groupes de lettres pour l'utilisateur, le groupe et les autres.
Caractère 1: '-' non lisible; 'r' lisible
Caractère 2: '-' pas d'écriture; 'w' écriture (writable)
Caractère 3, utilisateur et groupe: Combine l'éxécution et un spécial
'-' non exécutable, non spécial
'x' exécutable, non spécial
's' exécutable, spécial
'S' non exécutable, spécial
Caractère 3, autres: Combine l'éxécution et le sticky (tacky?)
'-' non éxécutable, non tacky
'x' exécutable, non tacky
't' exécutable, tacky
'T' non exécutable, tacky

Suivi par un indicateur d'accès
Non testé, il pourrait être le onzième caractère
ou il pourrait générer un autre champ
' ' Pas d'accès autre
'+' Accès autre
LSfieldsDoc"


AfficheRepertoire(){
        local -a T
        local -i of=0           # Valeur par défaut
                                # Utilise la variable BASH par défaut ' \t\n'

        case "$#" in
        3)      case "$1" in
                -of)    of=1 ; shift ;;
                 * )    return 1 ;;
                esac ;;
        2)      : ;;            # L'instruction "continue" du pauvre
        *)      return 1 ;;
        esac

        # NOTE: la commande (ls) N'est PAS entre guillemets (")
        T=( $(ls --inode --ignore-backups --almost-all --directory \
        --full-time --color=none --time=status --sort=none \
        --format=long $1) )

        case $of in
        #  Affecte T en retour pour le tableau dont le nom a été passé
        #+ à $2
                0) eval $2=\( \"\$\{T\[@\]\}\" \) ;;
        # Ecrit T dans le nom du fichier passé à $2
                1) echo "${T[@]}" > "$2" ;;
        esac
        return 0
   }

# # # # # Est-ce que cette chaîne est un nombre légal ? # # # # #
#
#       EstNombre "Var"
# # # # # Il doit y avoir un meilleur moyen, hum...

EstNombre()
{
        local -i int
        if [ $# -eq 0 ]
        then
                return 1
        else
                (let int=$1)  2>/dev/null
                return $?       # Code de sortie du thread créé pour let
        fi
}

# # # Informations sur l'index des répertoires du système de fichiers # # #
#
#       AfficheIndex "Field-Array-Name" "Index-Array-Name"
# ou
#       AfficheIndex -if Field-Array-Filename Index-Array-Name
#       AfficheIndex -of Field-Array-Name Index-Array-Filename
#       AfficheIndex -if -of Field-Array-Filename Index-Array-Filename
# # # # #

: "&lt;&lt;AfficheIndexDoc
Parcourt un tableau de champs répertoire créé par AfficheRepertoire

Ayant supprimé les retours chariots dans un rapport habituellement ligne par
ligne, construit un index vers l'élement du tableau commençant à chaque ligne.

Chaque ligne obtient deux entrées de l'index, le premier élément de chaque ligne
(inode) et l'élément qui contient le chemin du fichier.

La première paire d'entrée de l'index (Numero-Ligne==0) apporte une
information :
Nom-Tableau-Index[0] : Nombre de "lignes" indexé
Nom-Tableau-Index[1] : Pointeur de la "ligne courante" vers Nom-Tableau-Index

Les paires d'index suivantes (si elles existent) contiennent les index des
éléments dans Nom-Tableau-Champ avec :
Nom-Tableau-Index[Numero-Ligne * 2] : L'élément champ "inode".
NOTE: La distance peut être de +11 ou +12 éléments.
Nom-Tableau-Index[(Numero-Ligne * 2) + 1] : L'élément "chemin".
NOTE: La distance est un nombre variable d'éléments.
La prochaine paire de lignes d'index pour Numero-Ligne+1.
AfficheIndexDoc"



AfficheIndex(){
        local -a LISTE                  # Variable locale du nom de liste
        local -a -i INDEX=( 0 0 )       # Variable locale de l'index à renvoyer
        local -i Lidx Lcpt
        local -i if=0 of=0              # Par défaut

        case "$#" in                    # Test simpliste des options
                0) return 1 ;;
                1) return 1 ;;
                2) : ;;                 # Instruction "continue" du pauvre
                3) case "$1" in
                        -if) if=1 ;;
                        -of) of=1 ;;
                         * ) return 1 ;;
                   esac ; shift ;;
                4) if=1 ; of=1 ; shift ; shift ;;
                *) return 1
        esac

        # Fait une copie locale de liste
        case "$if" in
                0) eval LISTE=\( \"\$\{$1\[@\]\}\" \) ;;
                1) LISTE=( $(cat $1) ) ;;
        esac

        # "Grok (grope?)" le tableau
        Lcpt=${#LISTE[@]}
        Lidx=0
        until (( Lidx >= Lcpt ))
        do
        if EstNombre ${LISTE[$Lidx]}
        then
                local -i inode nom
                local ft
                inode=Lidx
                local m=${LISTE[$Lidx+2]}       # Champ des liens
                ft=${LISTE[$Lidx+1]:0:1}        # Stats rapides
                case $ft in
                b)      ((Lidx+=12)) ;;         # Périphérique bloc
                c)      ((Lidx+=12)) ;;         # Périphérique caractère
                *)      ((Lidx+=11)) ;;         # Le reste
                esac
                nom=Lidx
                case $ft in
                -)      ((Lidx+=1)) ;;          # Le plus simple
                b)      ((Lidx+=1)) ;;          # Périphérique bloc
                c)      ((Lidx+=1)) ;;          # Périphérique caractère
                d)      ((Lidx+=1)) ;;          # Encore un autre
                l)      ((Lidx+=3)) ;;          # Au MOINS deux autres champs
#  Un peu plus d'élégance ici permettrait de gérer des tubes, des sockets,
#+ des fichiers supprimés - plus tard.
                *)      until EstNombre ${LISTE[$Lidx]} || ((Lidx >= Lcpt))
                        do
                                ((Lidx+=1))
                        done
                        ;;                      # Non requis.
                esac
                INDEX[${#INDEX[*]}]=$inode
                INDEX[${#INDEX[*]}]=$nom
                INDEX[0]=${INDEX[0]}+1          # Une "ligne" de plus
# echo "Ligne: ${INDEX[0]} Type: $ft Liens: $m Inode: \
# ${LIST[$inode]} Nom: ${LIST[$name]}"

        else
                ((Lidx+=1))
        fi
        done
        case "$of" in
                0) eval $2=\( \"\$\{INDEX\[@\]\}\" \) ;;
                1) echo "${INDEX[@]}" > "$2" ;;
        esac
        return 0                        # Que pourrait'il arriver de mal ?
}

# # # # # Fichier identifié par son contenu # # # # #
#
#       DigestFile Nom-Tableau-Entree Nom-Tableau-Digest
# ou
#       DigestFile -if NomFichier-EnEntree Nom-Tableau-Digest
# # # # #

# Document intégré utilisé comme bloc de commentaires.
: "&lt;&lt;DigestFilesDoc

La clé (no pun intended) vers un Système de Fichiers au Contenu Unifié (UCFS)
permet de distinguer les fichiers du système basés sur leur contenu.
Distinguer des fichiers par leur nom est tellement 20è siècle.

Le contenu se distingue en calculant une somme de contrôle de ce contenu.
Cette version utilise le programme md5sum pour générer une représentation de la
somme de contrôle 128 bit du contenu.
Il existe une chance pour que deux fichiers ayant des contenus différents
génèrent la même somme de contrôle utilisant md5sum (ou tout autre outil de
calcul de somme de contrôle). Si cela devait devenir un problème, alors
l'utilisation de md5sum peut être remplacée par une signature cryptographique.
Mais jusque là...

La documentation de md5sum précise que la sortie de cette commande affiche
trois champs mais, à la lecture, il apparaît comme deux champs (éléments du
tableau). Ceci se fait par le manque d'espaces blancs entre le second et le
troisième champ. Donc, cette fonction groupe la sortie du md5sum et renvoit :
        [0]     Somme de contrôle sur 32 caractères en héxidecimal (nom du
                fichier UCFS)
        [1]     Caractère seul : ' ' fichier texte, '*' fichier binaire
        [2]     Nom système de fichiers (style 20è siècle)
        Note: Ce nom pourrait être le caractère '-' indiquant la lecture de
        STDIN

DigestFilesDoc"



DigestFile(){
        local if=0              # Par défaut.
        local -a T1 T2

        case "$#" in
        3)      case "$1" in
                -if)    if=1 ; shift ;;
                 * )    return 1 ;;
                esac ;;
        2)      : ;;            # Instruction "continue" du pauvre
        *)      return 1 ;;
        esac

        case $if in
        0) eval T1=\( \"\$\{$1\[@\]\}\" \)
           T2=( $(echo ${T1[@]} | md5sum -) )
           ;;
        1) T2=( $(md5sum $1) )
           ;;
        esac

        case ${#T2[@]} in
        0) return 1 ;;
        1) return 1 ;;
        2) case ${T2[1]:0:1} in         # SanScrit-2.0.5
           \*) T2[${#T2[@]}]=${T2[1]:1}
               T2[1]=\*
               ;;
            *) T2[${#T2[@]}]=${T2[1]}
               T2[1]=" "
               ;;
           esac
           ;;
        3) : ;; # Suppose qu'il fonctionne
        *) return 1 ;;
        esac

        local -i len=${#T2[0]}
        if [ $len -ne 32 ] ; then return 1 ; fi
        eval $2=\( \"\$\{T2\[@\]\}\" \)
}

# # # # # Trouve l'emplacement du fichier # # # # #
#
#       LocateFile [-l] NomFichier Nom-Tableau-Emplacement
# ou
#       LocateFile [-l] -of NomFichier NomFichier-Tableau-Emplacement
# # # # #

#  L'emplacement d'un fichier correspond à l'identifiant du système de fichiers
#+ et du numéro de l'inode.

# Document intégré comme bloc de commentaire.
: "&lt;&lt;StatFieldsDoc
        Basé sur stat, version 2.2
        champs de stat -t et stat -lt
        [0]     nom
        [1]     Taille totale
                Fichier - nombre d'octets
                Lien symbolique - longueur de la chaîne représentant le chemin
        [2]     Nombre de blocs (de 512 octets) alloués
        [3]     Type de fichier et droits d'accès (hex)
        [4]     ID utilisateur du propriétaire
        [5]     ID groupe du propriétaire
        [6]     Numéro de périphérique
        [7]     Numéro de l'inode
        [8]     Nombre de liens
        [9]     Type de périphérique (si périphérique d'inode) Majeur
        [10]    Type de périphérique (si périphérique d'inode) Mineur
        [11]    Heure du dernier accès
                Pourrait être désactivé dans 'mount' avec noatime
                atime des fichiers changés par exec, read, pipe, utime, mknod
                (mmap?)
                atime des répertoires changés par ajout/suppression des fichiers
        [12]    Heure de dernière modification
                mtime des fichiers changés par write, truncate, utime, mknod
                mtime des répertoires changés par ajout/suppression des fichiers
        [13]    Heure de dernier changement
                ctime reflète le temps de la dernière modification de l'inode
                (propriétaire, groupe, droits, nombre de liens)"

# LocateFile [-l] NomFichier Nom-Tableau-Emplacement
# LocateFile [-l] -of NomFichier Nom-Tableau-Emplacement
LocateFile(){
        local -a LOC LOC1 LOC2
        local lk="" of=0

        case "$#" in
        0) return 1 ;;
        1) return 1 ;;
        2) : ;;
        *) while (( "$#" > 2 ))
           do
              case "$1" in
               -l) lk=-1 ;;
              -of) of=1 ;;
                *) return 1 ;;
              esac
           shift
           done ;;
        esac

# Plus de Sanscrit-2.0.5
      # LOC1=( $(stat -t $lk $1) )
      # LOC2=( $(stat -tf $lk $1) )
      #  Supprimez le commentaire des deux lignes ci-dessus si le système
      #+ dispose de la commande "stat" installée.
        LOC=( ${LOC1[@]:0:1} ${LOC1[@]:3:11}
              ${LOC2[@]:1:2} ${LOC2[@]:4:1} )

        case "$of" in
                0) eval $2=\( \"\$\{LOC\[@\]\}\" \) ;;
                1) echo "${LOC[@]}" > "$2" ;;
        esac
        return 0
}

# Et enfin, voici un code de test
AfficheTableau(){
        local -a Ta;

        eval Ta=\( \"\$\{$1\[@\]\}\" \)
        echo
        echo "-*-*- Liste de tableaux -*-*-"
        echo "Taille du tableau $1: ${#Ta[*]}"
        echo "Contenu du tableau $1:"
        for (( i=0 ; i<${#Ta[*]} ; i++ ))
        do
            echo -e "\tElément $i: ${Ta[$i]}"
        done
        return 0
}

declare -a CUR_DIR
# Pour de petits tableaux
AfficheRepertoire "${PWD}" CUR_DIR
AfficheTableau CUR_DIR

declare -a DIR_DIG
DigestFile CUR_DIR DIR_DIG
echo "Le nouveau \"nom\" (somme de contrôle) pour ${CUR_DIR[9]} est ${DIR_DIG[0]}"

declare -a DIR_ENT
# BIG_DIR # Pour de réellement gros tableaux - utilise un fichier temporaire en
          # disque RAM
# BIG-DIR # AfficheRepertoire -of "${CUR_DIR[11]}/*" "/tmpfs/junk2"
AfficheRepertoire "${CUR_DIR[11]}/*" DIR_ENT

declare -a DIR_IDX
# BIG-DIR # AfficheIndex -if "/tmpfs/junk2" DIR_IDX
AfficheIndex DIR_ENT DIR_IDX

declare -a IDX_DIG
# BIG-DIR # DIR_ENT=( $(cat /tmpfs/junk2) )
# BIG-DIR # DigestFile -if /tmpfs/junk2 IDX_DIG
DigestFile DIR_ENT IDX_DIG
# Les petits (devraient) être capable de paralléliser AfficheIndex & DigestFile
# Les grands (devraient) être capable de paralléliser AfficheIndex & DigestFile
# & l'affectation
echo "Le \"nom\" (somme de contrôle) pour le contenu de ${PWD} est ${IDX_DIG[0]}"

declare -a FILE_LOC
LocateFile ${PWD} FILE_LOC
AfficheTableau FILE_LOC

exit 0

