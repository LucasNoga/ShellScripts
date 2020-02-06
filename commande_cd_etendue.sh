 Exemple A.35. 


#!/bin/bash
# commande_cd_etendue.sh Une commande cd étendue

# La dernière version de ce script est disponible à partir de
# http://freshmeat.net/projects/cd/
#       .cd_new


#  Une amélioration de la commande Unix cd
#       Il y a une pile illimitée d'entrées et d'entrées spéciales. Les
#       entrées de la pile conservent les cd_maxhistory derniers répertoires
#       qui ont été utilisés. Les entrées spéciales peuvent être affectées aux
#       répertoires fréquemment utilisés.
#
#       Les entrées spéciales pourraient être préaffectées en configurant les
#       variables d'environnement CDSn ou en utilisant la commande -u ou -U.
#
#       Ce qui suit est une suggestion pour le fichier .profile :
#
#               . cdll              #  Configure la commande cd
#       alias cd='cd_new'           #  Remplace la commande cd
#               cd -U               #  Charge les entrées pré-affectées pour
#                                   #+ la pile et les entrées spéciales
#               cd -D               #  Configure le mode pas par défaut
#               alias @="cd_new @"  #  Autorise l'utilisation de @ pour récupérer
#                                   #+ l'historique
#
#       Pour une aide, saisissez :
#
#               cd -h ou
#               cd -H


cd_hm (){
        ${PRINTF} "%s" "cd [dir] [0-9] [@[s|h] [-g [&lt;dir&gt;]] [-d] [-D] [-r&lt;n&gt;] [dir|0-9] [-R&lt;n&gt;] [&lt;dir&gt;|0-9]
   [-s&lt;n&gt;] [-S&lt;n&gt;] [-u] [-U] [-f] [-F] [-h] [-H] [-v]
    &lt;dir&gt; Se place sous le répertoire
    0-n         Se place sous le répertoire précedent (0 est le précédent, 1 est l'avant-dernier, etc)
                n va jusqu'au bout de l'historique (par défaut, 50)
    @           Liste les entrées de l'historique et les entrées spéciales
    @h          Liste les entrées de l'historique
    @s          Liste les entrées spéciales
    -g [&lt;dir&gt;]  Se place sous le nom littéral (sans prendre en compte les noms spéciaux)
                Ceci permet l'accès aux répertoires nommés '0','1','-h' etc
    -d          Modifie l'action par défaut - verbeux. (Voir note)
    -D          Modifie l'action par défaut - silencieux. (Voir note)
    -s&lt;n&gt;       Se place sous l'entrée spéciale &lt;n&gt;*
    -S&lt;n&gt;       Se place sous l'entrée spéciale &lt;n&gt; et la remplace avec le répertoire en cours*
    -r&lt;n&gt; [&lt;dir&gt;] Se place sous le répertoire &lt;dir&gt; and then put it on special entry &lt;n&gt;*
    -R&lt;n&gt; [&lt;dir&gt;] Se place sous le répertoire &lt;dir&gt; et place le répertoire en cours dans une entrée spéciale &lt;n&gt;*
    -a&lt;n&gt;       Autre répertoire suggéré. Voir la note ci-dessous.
    -f [&lt;file&gt;] Fichier des entrées &lt;file&gt;.
    -u [&lt;file&gt;] Met à jour les entrées à partir de &lt;file&gt;.
                Si aucun nom de fichier n'est fourni, utilise le fichier par défaut (${CDPath}${2:-"$CDFile"})
                -F et -U sont les versions silencieuses
    -v          Affiche le numéro de version
    -h          Aide
    -H          Aide détaillée

    *Les entrées spéciales (0 - 9) sont conservées jusqu'à la déconnexion, remplacées par une autre entrée
    ou mises à jour avec la commande -u

    Autres répertoires suggérés :
    Si un répertoire est introuvable, alors CD suggèrera des possibilités. Ce sont les répertoires
    commençant avec les mêmes lettres et si des résultats sont disponibles, ils sont affichés avec
    le préfixe -a&lt;n&gt; où &lt;n&gt; est un numéro.
    Il est possible de se placer dans le répertoire en saisissant cd -a&lt;n&gt; sur la ligne de commande.

    Le répertoire pour -r&lt;n&gt; ou -R&lt;n&gt; pourrait être un numéro. Par exemple :
        $ cd -r3 4  Se place dans le répertoire de l'entrée 4 de l'historique et la place
                    sur l'entrée spéciale 3
        $ cd -R3 4  Place le répertoire en cours sur l'entrée spéciale 3 et se déplace dans l'entrée 4
                    de l'historique
        $ cd -s3    Se déplace dans l'entrée spéciale 3

    Notez que les commandes R,r,S et s pourraient être utilisées sans numéro et faire ainsi référence à 0:
        $ cd -s     Se déplace dans l'entrée spéciale 0
        $ cd -S     Se déplace dans l'entrée spéciale 0 et fait de l'entrée spéciale 0 le répertoire courant
        $ cd -r 1   Se déplace dans l'entrée spéciale 1 et la place sur l'entrée spéciale 0
        $ cd -r     Se déplace dans l'entrée spéciale 0 et la place sur l'entrée spéciale 0
    "
        if ${TEST} "$CD_MODE" = "PREV"
        then
                ${PRINTF} "$cd_mnset"
        else
                ${PRINTF} "$cd_mset"
        fi
}

cd_Hm (){
        cd_hm
        ${PRINTF} "%s" "
        Les répertoires précédents (0-$cd_maxhistory) sont stockés dans les variables
        d'environnement CD[0] - CD[$cd_maxhistory]
        De façon similaire, les répertoires spéciaux S0 - $cd_maxspecial sont dans la
        variable d'environnement CDS[0] - CDS[$cd_maxspecial]
        et pourraient être accédés à partir de la ligne de commande

        Le chemin par défaut pour les commandes -f et -u est $CDPath
        Le fichier par défaut pour les commandes est -f et -u est $CDFile

        Configurez les variables d'environnement suivantes :
            CDL_PROMPTLEN  - Configuré à la longueur de l'invite que vous demandez.
                La chaîne de l'invite est configurée suivant les caractères de droite du
                répertoire en cours.
                Si non configuré, l'invite n'est pas modifiée.
            CDL_PROMPT_PRE - Configuré avec la chaîne pour préfixer l'invite.
                La valeur par défaut est:
                    standard:  \"\\[\\e[01;34m\\]\"  (couleur bleu).
                    root:      \"\\[\\e[01;31m\\]\"  (couleur rouge).
            CDL_PROMPT_POST    - Configuré avec la chaîne pour suffixer l'invite.
                La valeur par défaut est:
                    standard:  \"\\[\\e[00m\\]$\"   (réinitialise la couleur et affiche $).
                    root:      \"\\[\\e[00m\\]#\"   (réinitialise la couleur et affiche #).
            CDPath - Configure le chemin par défaut des options -f & -u.
                     Par défaut, le répertoire personnel de l'utilisateur
            CDFile - Configure le fichier par défaut pour les options -f & -u.
                     Par défaut, cdfile
        
"
    cd_version

}

cd_version (){
    printf "Version: ${VERSION_MAJOR}.${VERSION_MINOR} Date: ${VERSION_DATE}\n"
}

#
# Tronque à droite.
#
# params:
#   p1 - chaîne
#   p2 - longueur à tronquer
#
# renvoit la chaîne dans tcd
#
cd_right_trunc ()
{
    local tlen=${2}
    local plen=${#1}
    local str="${1}"
    local diff
    local filler="<--"
    if ${TEST} ${plen} -le ${tlen}
    then
        tcd="${str}"
    else
        let diff=${plen}-${tlen}
        elen=3
        if ${TEST} ${diff} -le 2
        then
            let elen=${diff}
        fi
        tlen=-${tlen}
        let tlen=${tlen}+${elen}
        tcd=${filler:0:elen}${str:tlen}
    fi
}

#
# Trois versions de l'historique do :
#    cd_dohistory  - empile l'historique et les spéciaux côte à côte
#    cd_dohistoryH - Affiche seulement l'historique
#    cd_dohistoryS - Affiche seulement les spéciaux
#
cd_dohistory (){
    cd_getrc
        ${PRINTF} "Historique :\n"
    local -i count=${cd_histcount}
    while ${TEST} ${count} -ge 0
    do
        cd_right_trunc "${CD[count]}" ${cd_lchar}
            ${PRINTF} "%2d %-${cd_lchar}.${cd_lchar}s " ${count} "${tcd}"

        cd_right_trunc "${CDS[count]}" ${cd_rchar}
            ${PRINTF} "S%d %-${cd_rchar}.${cd_rchar}s\n" ${count} "${tcd}"
        count=${count}-1
    done
}

cd_dohistoryH (){
    cd_getrc
        ${PRINTF} "Historique :\n"
        local -i count=${cd_maxhistory}
        while ${TEST} ${count} -ge 0
        do
                ${PRINTF} "${count} %-${cd_flchar}.${cd_flchar}s\n" ${CD[$count]}
                count=${count}-1
        done
}

cd_dohistoryS (){
    cd_getrc
        ${PRINTF} "Spéciaux :\n"
        local -i count=${cd_maxspecial}
        while ${TEST} ${count} -ge 0
        do
                ${PRINTF} "S${count} %-${cd_flchar}.${cd_flchar}s\n" ${CDS[$count]}
                count=${count}-1
        done
}

cd_getrc (){
    cd_flchar=$(stty -a | awk -F \; '/rows/ { print $2 $3 }' | awk -F \  '{ print $4 }')
    if ${TEST} ${cd_flchar} -ne 0
    then
        cd_lchar=${cd_flchar}/2-5
        cd_rchar=${cd_flchar}/2-5
            cd_flchar=${cd_flchar}-5
    else
            cd_flchar=${FLCHAR:=75}  # cd_flchar is used for for the @s & @h history
            cd_lchar=${LCHAR:=35}
            cd_rchar=${RCHAR:=35}
    fi
}

cd_doselection (){
        local -i nm=0
        cd_doflag="TRUE"
        if ${TEST} "${CD_MODE}" = "PREV"
        then
                if ${TEST} -z "$cd_npwd"
                then
                        cd_npwd=0
                fi
        fi
        tm=$(echo "${cd_npwd}" | cut -b 1)
    if ${TEST} "${tm}" = "-"
    then
        pm=$(echo "${cd_npwd}" | cut -b 2)
        nm=$(echo "${cd_npwd}" | cut -d $pm -f2)
        case "${pm}" in
                a) cd_npwd=${cd_sugg[$nm]} ;;
                s) cd_npwd="${CDS[$nm]}" ;;
                S) cd_npwd="${CDS[$nm]}" ; CDS[$nm]=`pwd` ;;
                r) cd_npwd="$2" ; cd_specDir=$nm ; cd_doselection "$1" "$2";;
                R) cd_npwd="$2" ; CDS[$nm]=`pwd` ; cd_doselection "$1" "$2";;
        esac
    fi

        if ${TEST} "${cd_npwd}" != "." -a "${cd_npwd}" != ".." -a "${cd_npwd}" -le ${cd_maxhistory} >>/dev/null 2>&1
        then
                cd_npwd=${CD[$cd_npwd]}
        else
                case "$cd_npwd" in
                         @)  cd_dohistory ; cd_doflag="FALSE" ;;
                        @h) cd_dohistoryH ; cd_doflag="FALSE" ;;
                        @s) cd_dohistoryS ; cd_doflag="FALSE" ;;
                        -h) cd_hm ; cd_doflag="FALSE" ;;
                        -H) cd_Hm ; cd_doflag="FALSE" ;;
                        -f) cd_fsave "SHOW" $2 ; cd_doflag="FALSE" ;;
                        -u) cd_upload "SHOW" $2 ; cd_doflag="FALSE" ;;
                        -F) cd_fsave "NOSHOW" $2 ; cd_doflag="FALSE" ;;
                        -U) cd_upload "NOSHOW" $2 ; cd_doflag="FALSE" ;;
                        -g) cd_npwd="$2" ;;
                        -d) cd_chdefm 1; cd_doflag="FALSE" ;;
                        -D) cd_chdefm 0; cd_doflag="FALSE" ;;
                        -r) cd_npwd="$2" ; cd_specDir=0 ; cd_doselection "$1" "$2";;
                        -R) cd_npwd="$2" ; CDS[0]=`pwd` ; cd_doselection "$1" "$2";;
                        -s) cd_npwd="${CDS[0]}" ;;
                        -S) cd_npwd="${CDS[0]}"  ; CDS[0]=`pwd` ;;
                        -v) cd_version ; cd_doflag="FALSE";;
                esac
        fi
}

cd_chdefm (){
        if ${TEST} "${CD_MODE}" = "PREV"
        then
                CD_MODE=""
                if ${TEST} $1 -eq 1
                then
                        ${PRINTF} "${cd_mset}"
                fi
        else
                CD_MODE="PREV"
                if ${TEST} $1 -eq 1
                then
                        ${PRINTF} "${cd_mnset}"
                fi
        fi
}

cd_fsave (){
        local sfile=${CDPath}${2:-"$CDFile"}
        if ${TEST} "$1" = "SHOW"
        then
                ${PRINTF} "Saved to %s\n" $sfile
        fi
        ${RM} -f ${sfile}
        local -i count=0
        while ${TEST} ${count} -le ${cd_maxhistory}
        do
                echo "CD[$count]=\"${CD[$count]}\"" >> ${sfile}
                count=${count}+1
        done
        count=0
        while ${TEST} ${count} -le ${cd_maxspecial}
        do
                echo "CDS[$count]=\"${CDS[$count]}\"" >> ${sfile}
                count=${count}+1
        done
}

cd_upload (){
        local sfile=${CDPath}${2:-"$CDFile"}
        if ${TEST} "${1}" = "SHOW"
        then
                ${PRINTF} "Chargement de %s\n" ${sfile}
        fi
        . ${sfile}
}

cd_new ()
{
    local -i count
    local -i choose=0

        cd_npwd="${1}"
        cd_specDir=-1
        cd_doselection "${1}" "${2}"

        if ${TEST} ${cd_doflag} = "TRUE"
        then
                if ${TEST} "${CD[0]}" != "`pwd`"
                then
                        count=$cd_maxhistory
                        while ${TEST} $count -gt 0
                        do
                                CD[$count]=${CD[$count-1]}
                                count=${count}-1
                        done
                        CD[0]=`pwd`
                fi
                command cd "${cd_npwd}" 2>/dev/null
        if ${TEST} $? -eq 1
        then
            ${PRINTF} "Répertoire inconnu : %s\n" "${cd_npwd}"
            local -i ftflag=0
            for i in "${cd_npwd}"*
            do
                if ${TEST} -d "${i}"
                then
                    if ${TEST} ${ftflag} -eq 0
                    then
                        ${PRINTF} "Suggest:\n"
                        ftflag=1
                fi
                    ${PRINTF} "\t-a${choose} %s\n" "$i"
                                        cd_sugg[$choose]="${i}"
                    choose=${choose}+1
        fi
            done
        fi
        fi

        if ${TEST} ${cd_specDir} -ne -1
        then
                CDS[${cd_specDir}]=`pwd`
        fi

        if ${TEST} ! -z "${CDL_PROMPTLEN}"
        then
        cd_right_trunc "${PWD}" ${CDL_PROMPTLEN}
            cd_rp=${CDL_PROMPT_PRE}${tcd}${CDL_PROMPT_POST}
                export PS1="$(echo -ne ${cd_rp})"
        fi
}
#################################################################################
#                                                                               #
#                            Initialisation ici                                 #
#                                                                               #
#################################################################################
#
VERSION_MAJOR="1"
VERSION_MINOR="2.1"
VERSION_DATE="24 MAI 2003"
#
alias cd=cd_new
#
# Configuration des commandes
RM=/bin/rm
TEST=test
PRINTF=printf              # Utilise le printf interne

#################################################################################
#                                                                               #
# Modifiez ceci pour modifier les chaînes préfixe et suffixe de l'invite.       #
# Elles ne prennent effet que si CDL_PROMPTLEN est configuré.                   #
#                                                                               #
#################################################################################
if ${TEST} ${EUID} -eq 0
then
#   CDL_PROMPT_PRE=${CDL_PROMPT_PRE:="$HOSTNAME@"}
    CDL_PROMPT_PRE=${CDL_PROMPT_PRE:="\\[\\e[01;31m\\]"}    # Root est en rouge
    CDL_PROMPT_POST=${CDL_PROMPT_POST:="\\[\\e[00m\\]#"}
else
    CDL_PROMPT_PRE=${CDL_PROMPT_PRE:="\\[\\e[01;34m\\]"}    # Les utilisateurs sont en bleu
    CDL_PROMPT_POST=${CDL_PROMPT_POST:="\\[\\e[00m\\]$"}
fi
#################################################################################
#
# cd_maxhistory définit le nombre max d'entrées dans l'historique.
typeset -i cd_maxhistory=50

#################################################################################
#
# cd_maxspecial définit le nombre d'entrées spéciales.
typeset -i cd_maxspecial=9
#
#
#################################################################################
#
# cd_histcount définit le nombre d'entrées affichées dans la commande historique.
typeset -i cd_histcount=9
#
#################################################################################
export CDPath=${HOME}/
#  Modifiez-les pour utiliser un chemin et un nom de fichier                    #
#+ différent de la valeur par défaut                                            #
export CDFile=${CDFILE:=cdfile}                   # pour les commandes -u et -f #
#
#################################################################################
                                                                                #
typeset -i cd_lchar cd_rchar cd_flchar
                               #  Ceci est le nombre de caractères pour que                   #
cd_flchar=${FLCHAR:=75}        #+ cd_flchar puisse être autorisé pour l'historique de @s & @h #

typeset -ax CD CDS
#
cd_mset="\n\tLe mode par défaut est maintenant configuré - saisir cd sans paramètre correspond à l'action par défaut\n\tUtilisez cd -d ou -D pour que cd aille au répertoire précédent sans paramètres\n"
cd_mnset="\n\tL'autre mode est maintenant configuré - saisir cd sans paramètres est identique à saisir cd 0\n\tUtilisez cd -d ou -D pour modifier l'action par défaut de cd\n"

# ==================================================================== #



: &lt;&lt;DOCUMENTATION

Écrit par Phil Braham. Realtime Software Pty Ltd.
Sortie sous licence GNU. Libre à utiliser. Merci de passer toutes modifications
ou commentaires à l'auteur Phil Braham:

realtime@mpx.com.au
===============================================================================

cdll est un remplacement pour cd et incorpore des fonctionnalités similaires
aux commandes pushd et popd de bash mais est indépendent.

Cette version de cdll a été testée sur Linux en utilisant Bash. Il fonctionnera
sur la plupart des versions Linux mais ne fonctionnera probablement pas sur les
autres shells sans modification.

Introduction
============

cdll permet un déplacement facile entre les répertoires. En allant dans un autre
répertoire, celui en cours est placé automatiquement sur une pile. Par défaut,
50 entrées sont conservées mais c'est configurable. Les répertoires spéciaux
peuvent être gardés pour un accès facile - par défaut jusqu'à 10, mais ceci est
configurable. Les entrées les plus récentes de la pile et les entrées spéciales
peuvent être facilement visualisées.

La pile de répertoires et les entrées spéciales peuvent être sauvegardées dans
un fichier ou chargées à partir d'un fichier. Ceci leur permet d'être initialisé
à la connexion, sauvegardé avant la fin de la session ou déplacé en passant de
projet à projet.

En plus, cdll fournit une invite flexible permettant, par exemple, un nom de
répertoire en couleur, tronqué à partir de la gauche s'ilest trop long.


Configurer cdll
===============

Copiez cdll soit dans votre répertoire personnel soit dans un répertoire central
comme /usr/bin (ceci requiert un accès root).

Copiez le fichier cdfile dans votre répertoie personnel. Il requèrera un accès
en lecture et écriture. Ceci est un fichier par défaut contenant une pile de
répertoires et des entrées spéciales.

Pour remplacer la commande cd, vous devez ajouter les commandes à votre script
de connexion. Le script de connexion fait partie de :

    /etc/profile
    ~/.bash_profile
    ~/.bash_login
    ~/.profile
    ~/.bashrc
    /etc/bash.bashrc.local

Pour configurer votre connexion, ~/.bashrc est recommandé, pour la configuration
globale (et de root), ajoutez les commandes à /etc/bash.bashrc.local

Pour configurer la connexion, ajoutez la commande :
    . &lt;dir&gt;/cdll
Par exemple, si cdll est dans votre répertoire personnel :
    . ~/cdll
Si dans /usr/bin, alors :
    . /usr/bin/cdll

Si vous voulez utiliser ceci à la place de la commande cd interne, alors ajoutez :
    alias cd='cd_new'
Nous devrions aussi recommander les commandes suivantes :
    alias @='cd_new @'
    cd -U
    cd -D

Si vous utilisez la capacité de l'invite de cdll, alors ajoutez ce qui suit :
    CDL_PROMPTLEN=nn
Quand nn est un nombre décrit ci-dessous. Initialement, 99 serait un nombre
convenable.

Du coup, le script ressemble à ceci :

    ######################################################################
    # CD Setup
    ######################################################################
    CDL_PROMPTLEN=21        # Autorise une longueur d'invite d'un maximum
                            # de 21 caractères
    . /usr/bin/cdll         # Initialise cdll
    alias cd='cd_new'       # Remplace la commande cd interne
    alias @='cd_new @'      # Autorise @ sur l'invite pour affiche l'historique
    cd -U                   # Recharge le répertoire
    cd -D                   # Configure l'action par défaut en non posix
    ######################################################################

La signification complète de ces commandes deviendra claire plus tard.

Voici quelques astuces. Si un autre programme modifie le répertoire sans appeler
cdll, alors le répertoire ne sera pas placé sur la pile et aussi si la
fonctionnalité de l'invite est utilisée, alors ceci ne sera pas mise à jour.
Deux programmes qui peuvent faire ceci sont pushd et popd. Pour mettre à jour
l'invite et la pile, saisissez simplement :

    cd .

Notez que si l'entrée précédente sur la pile est le répertoire en cours, alors
la pile n'est pas mise à jour.

Usage
=====
cd [dir] [0-9] [@[s|h] [-g &lt;dir&gt;] [-d] [-D] [-r&lt;n&gt;]
   [dir|0-9] [-R&lt;n&gt;] [&lt;dir&gt;|0-9] [-s&lt;n&gt;] [-S&lt;n&gt;]
   [-u] [-U] [-f] [-F] [-h] [-H] [-v]

    &lt;dir&gt; Se place sous le répertoire
    0-n         Se place sous le répertoire précedent (0 est le précédent, 1 est l'avant-dernier, etc)
                n va jusqu'au bout de l'historique (par défaut, 50)
    @           Liste les entrées de l'historique et les entrées spéciales
    @h          Liste les entrées de l'historique
    @s          Liste les entrées spéciales
    -g [&lt;dir&gt;]  Se place sous le nom littéral (sans prendre en compte les noms spéciaux)
                Ceci permet l'accès aux répertoires nommés '0','1','-h' etc
    -d          Modifie l'action par défaut - verbeux. (Voir note)
    -D          Modifie l'action par défaut - silencieux. (Voir note)
    -s&lt;n&gt;       Se place sous l'entrée spéciale &lt;n&gt;*
    -S&lt;n&gt;       Se place sous l'entrée spéciale &lt;n&gt; et la remplace avec le répertoire en cours*
    -r&lt;n&gt; [&lt;dir&gt;] Se place sous le répertoire &lt;dir&gt; and then put it on special entry &lt;n&gt;*
    -R&lt;n&gt; [&lt;dir&gt;] Se place sous le répertoire &lt;dir&gt; et place le répertoire en cours dans une entrée spéciale &lt;n&gt;*
    -a&lt;n&gt;       Autre répertoire suggéré. Voir la note ci-dessous.
    -f [&lt;file&gt;] Fichier des entrées &lt;file&gt;.
    -u [&lt;file&gt;] Met à jour les entrées à partir de &lt;file&gt;.
                Si aucun nom de fichier n'est fourni, utilise le fichier par défaut (${CDPath}${2:-"$CDFile"})
                -F et -U sont les versions silencieuses
    -v          Affiche le numéro de version
    -h          Aide
    -H          Aide détaillée



Exemples
========

Ces exemples supposent que le mode autre que celui par défaut est configuré (qui
est, cd sans paramètres ira sur le répertoire le plus récent de la pile), que
les alias ont été configurés pour cd et @ comme décrits ci-dessus et que la
fonctionnalité de l'invite de cd est active et la longueur de l'invite est de
21 caractères.

    /home/phil$ @                                                   # Liste les entrées avec le @
    History:                                                        # Affiche la commande @
    .....                                                           # Laissé ces entrées pour être bref
    1 /home/phil/ummdev               S1 /home/phil/perl            # Les deux entrées les plus récentes de l'historique
    0 /home/phil/perl/eg              S0 /home/phil/umm/ummdev      # et deux entrées spéciales sont affichées

    /home/phil$ cd /home/phil/utils/Cdll                            # Maintenant, modifie les répertoires
    /home/phil/utils/Cdll$ @                                        # L'invite reflète le répertoire.
    History:                                                        # Nouvel historique
    .....   
    1 /home/phil/perl/eg              S1 /home/phil/perl            # L'entrée 0 de l'historique a été déplacé dans 1
    0 /home/phil                      S0 /home/phil/umm/ummdev      # et la plus récente a été entrée

Pour aller dans une entrée de l'historique :

    /home/phil/utils/Cdll$ cd 1                                     # Va dans l'entrée 1 de l'historique.
    /home/phil/perl/eg$                                             # Le répertoire en cours est maintenant celui du 1

Pour aller dans une entrée spéciale :

    /home/phil/perl/eg$ cd -s1                                      # Va dans l'entrée spéciale 1
    /home/phil/umm/ummdev$                                          # Le répertoire en cours est S1

Pour aller dans un répertoire nommé, par exemple, 1 :

    /home/phil$ cd -g 1                                             # -g ignore la signification spéciale de 1
    /home/phil/1$

Pour placer le répertoire en cours sur la liste spéciale en tant que S1 :
    cd -r1 .        #  OU
    cd -R1 .        #  Elles ont le même effet si le répertoire est
                    #+ . (le répertoire en cours)

Pour aller dans un répertoire et l'ajouter comme entrée spéciale
    Le répertoire pour -r&lt;n&gt; ou -R&lt;n&gt; pourrait être un nombre. Par exemple :
        $ cd -r3 4  Va dans l'entrée 4 de l'historique et placez-la dans l'entrée spéciale 3
        $ cd -R3 4  Placez le répertoire en cours sur l'entrée spéciale 3 et allez dans l'entrée spéciale 4
        $ cd -s3    Allez dans l'entrée spéciale 3

    Notez que les commands R,r,S et s pourraient être utilisées sans un numéro et faire référence à 0 :
        $ cd -s     Va dans l'entrée spéciale 0
        $ cd -S     Va dans l'entrée spéciale 0 et fait de l'entrée spéciale 0 le répertoire en cours
        $ cd -r 1   Va dans l'entrée 1 de l'historique et la place sur l'entrée spéciale 0
        $ cd -r     Va dans l'entrée 0 de l'historique et la place sur l'entrée spéciale 0


    Autres répertoires suggérés :

    Si un répertoire est introuvable, alors CD suggèrera toute possibilité.
    Il s'agit des répertoires commençant avec les mêmes lettres et si des
    correspondances sont trouvées, ils sont affichés préfixés avec -a&lt;n&gt;
    où &lt;n&gt; est un numéro. Il est possible d'aller dans un répertoire
    de saisir cd -a&lt;n&gt; sur la ligne de commande.

        Utilisez cd -d ou -D pour modifier l'action par défaut de cd. cd -H
        affichera l'action en cours.

        Les entrées de l'historique (0-n) sont stockées dans les variables
        d'environnement CD[0] - CD[n]
        De façon similaire, les répertoires spéciaux S0 - 9 sont dans la variable
        d'environnement CDS[0] - CDS[9] et pourraient être accédés à partir de
        la ligne de commande, par exemple :

            ls -l ${CDS[3]}
            cat ${CD[8]}/file.txt

        Le chemin par défaut pour les commandes -f et -u est ~
        Le nom du fichier par défaut pour les commandes -f et -u est cdfile


Configuration
=============

    Les variables d'environnement suivantes peuvent être configurées :

            CDL_PROMPTLEN  - Configuré à la longueur de l'invite que vous demandez.
                La chaîne de l'invite est configurée suivant les caractères de droite du
                répertoire en cours. Si non configuré, l'invite n'est pas modifiée.
                Notez que ceci est le nombre de caractères raccourcissant le répertoire,
                pas le nombre de caractères total dans l'invite.

            CDL_PROMPT_PRE - Configure une chaîne pour préfixer l'invite.
                Default is:
                    non-root:  "\\[\\e[01;34m\\]"  (initialise la couleur à bleu).
                    root:      "\\[\\e[01;31m\\]"  (initialise la couleur à rouge).

            CDL_PROMPT_POST    - Configure une chaîne pour suffixer l'invite.
                Default is:
                    non-root:  "\\[\\e[00m\\]$"    (réinitialise la couleur et affiche $).
                    root:      "\\[\\e[00m\\]#"    (réinitialise la couleur et affiche #).

        Note:
            CDL_PROMPT_PRE & _POST only t

        CDPath - Configure le chemin par défaut pour les options -f & -u.
                 La valeur par défaut est le répertoire personnel
        CDFile - Configure le nom du fichier pour les options -f & -u.
                 La valeur par défaut est cdfile


    Il existe trois variables définies dans le fichier cdll qui contrôle le nombre
    d'entrées stockées ou affichées. Elles sont dans la sectioon labellées
    'Initialisation ici' jusqu'à la fin du fichier.

        cd_maxhistory       - Le nombre d'entrées stockées dans l'historique.
                              Par défaut, 50.
        cd_maxspecial       - Le nombre d'entrées spéciale autorisées.
                              Par défaut, 9.
        cd_histcount        - Le nombre d'entrées de l'historique et d'entrées spéciales
                              affichées. Par défaut, 9.

    Notez que cd_maxspecial devrait être >= cd_histcount pour afficher des entrées
    spéciales qui ne peuvent pas être initialisées.


Version: 1.2.1 Date: 24-MAY-2003

DOCUMENTATION

