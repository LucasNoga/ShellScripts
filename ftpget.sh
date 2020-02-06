#!/bin/sh 
#ftpget: Télécharger des fichiers via ftp

# $Id: ftpget.sh,v 1.8 2008-05-10 08:36:14 gleu Exp $ 
# Script pour réaliser une suite d'actions avec un ftp anonyme. Généralement,
# convertit une liste d'arguments de la ligne de commande en entrée vers ftp.
# ==> Ce script n'est rien de plus qu'un emballage shell autour de "ftp"...
# Simple et rapide - écrit comme compagnon de ftplist 
# -h spécifie l'hôte distant (par défaut prep.ai.mit.edu) 
# -d spécifie le répertoire distant où se déplacer - vous pouvez spécifier une
# séquence d'options -d - elles seront exécutées chacune leur tour. Si les
# chemins sont relatifs, assurez-vous d'avoir la bonne séquence. Attention aux
# chemins relatifs, il existe bien trop de liens symboliques de nos jours.
# (par défaut, le répertoire distant est le répertoire au moment de la connexion)
# -v active l'option verbeux de ftp et affiche toutes les réponses du serveur
# ftp
# -f fichierdistant[:fichierlocal] récupère le fichier distant et le renomme en
# localfile 
# -m modele fait un mget suivant le modèle spécifié. Rappelez-vous de mettre
# entre guillemets les caractères shell.
# -c fait un cd local vers le répertoire spécifié
# Par exemple example, 
#       ftpget -h expo.lcs.mit.edu -d contrib -f xplaces.shar:xplaces.sh \
#               -d ../pub/R3/fixes -c ~/fixes -m 'fix*' 
# récupèrera xplaces.shar à partir de ~ftp/contrib sur expo.lcs.mit.edu et
# l'enregistrera sous xplaces.sh dans le répertoire actuel, puis obtiendra
# tous les correctifs de ~ftp/pub/R3/fixes et les placera dans le répertoire
# ~/fixes.
# De façon évidente, la séquence des options est importante, car les commandes
# équivalentes sont exécutées par ftp dans le même ordre.
#
# Mark Moraes (moraes@csri.toronto.edu), Feb 1, 1989 
#


# ==> Ces commentaires ont été ajoutés par l'auteur de ce document.

# PATH=/local/bin:/usr/ucb:/usr/bin:/bin
# export PATH
# ==> Les deux lignes ci-dessus faisaient parti du script original et étaient
# ==> probablement inutiles

E_MAUVAISARGS=65

FICHIER_TEMPORAIRE=/tmp/ftp.$$
# ==> Crée un fichier temporaire, en utilisant l'identifiant du processus du
# ==> script ($$) pour construire le nom du fichier.

SITE=`domainname`.toronto.edu
# ==> 'domainname' est similaire à 'hostname'
# ==> Ceci pourrait être réécrit en ajoutant un paramètre ce qui rendrait son
# ==> utilisation plus générale.

usage="Usage: $0 [-h hotedistant] [-d repertoiredistant]... [-f fichierdistant:fichierlocal]... \
                [-c repertoirelocal] [-m modele] [-v]"
optionsftp="-i -n"
verbflag=
set -f          # So we can use globbing in -m
set x `getopt vh:d:c:m:f: $*`
if [ $? != 0 ]; then
        echo $usage
        exit $E_MAUVAISARGS
fi
shift
trap 'rm -f ${FICHIER_TEMPORAIRE} ; exit' 0 1    2            3     15
# ==>                          Signaux:     HUP  INT (Ctl-C)  QUIT  TERM
# ==> Supprimer FICHIER_TEMPORAIRE dans le cas d'une sortie anormale du script.
echo "user anonymous ${USER-gnu}@${SITE} > ${FICHIER_TEMPORAIRE}"
# ==> Ajout des guillemets (recommandé pour les echo complexes).
echo binary >> ${FICHIER_TEMPORAIRE}
for i in $*   # ==> Analyse les arguments de la ligne de commande.
do
        case $i in
        -v) verbflag=-v; echo hash >> ${FICHIER_TEMPORAIRE}; shift;;
        -h) hotedistant=$2; shift 2;;
        -d) echo cd $2 >> ${FICHIER_TEMPORAIRE}; 
            if [ x${verbflag} != x ]; then
                echo pwd >> ${FICHIER_TEMPORAIRE};
            fi;
            shift 2;;
        -c) echo lcd $2 >> ${FICHIER_TEMPORAIRE}; shift 2;;
        -m) echo mget "$2" >> ${FICHIER_TEMPORAIRE}; shift 2;;
        -f) f1=`expr "$2" : "\([^:]*\).*"`; f2=`expr "$2" : "[^:]*:\(.*\)"`;
            echo get ${f1} ${f2} >> ${FICHIER_TEMPORAIRE}; shift 2;;
        --) shift; break;;
        esac
# ==> 'lcd' et 'mget' sont des commandes ftp. Voir "man ftp"...
done
if [ $# -ne 0 ]; then
        echo $usage
        exit $E_MAUVAISARGS
        # ==> Modifié de l'"exit 2" pour se conformer avec le standard du style.
fi
if [ x${verbflag} != x ]; then
        optionsftp="${optionsftp} -v"
fi
if [ x${hotedistant} = x ]; then
        hotedistant=prep.ai.mit.edu
        # ==> À modifier pour utiliser votre site ftp favori.
fi
echo quit >> ${FICHIER_TEMPORAIRE}
# ==> Toutes les commandes sont sauvegardées dans fichier_temporaire.

ftp ${optionsftp} ${hotedistant} < ${FICHIER_TEMPORAIRE}
# ==> Maintenant, exécution par ftp de toutes les commandes contenues dans le
# ==> fichier fichier_temporaire.

rm -f ${FICHIER_TEMPORAIRE}
# ==> Enfin, fichier_temporaire est supprimé (vous pouvez souhaiter le copier
# ==> dans un journal).


# ==> Exercices:
# ==> ---------
# ==> 1) Ajouter une vérification d'erreurs.
# ==> 2) Ajouter des tas de trucs.

