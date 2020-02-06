 Exemple A.33. 

#!/bin/bash
# bashpodder.sh : Un script de podcasting


# Trouve le dernier script sur :
# http://linc.homeunix.org:8080/scripts/bashpodder


# ==>  L'auteur de ce script a donné gentimment sa permission
# ==>+ pour son ajout dans le guide ABS.
# ==> ################################################################
# ==> Qu'est-ce que "podcasting" ?
# ==> C'est l'envoi d'émissions de radio sur Internet.
# ==> Ces émissions peuvent être écoutées sur des iPod ainsi que sur
#+==> d'autres lecteurs de fichiers musicaux.
# ==> Ce script rend ceci possible.
# ==> Voir la documentation sur le site de l'auteur du script.

# Rend ce script compatible avec crontab :
cd $(dirname $0)
# ==> Change de répertoire par celui où ce script réside.

# repdonnees est le répertoire où les fichiers podcasts ont été sauvegardés :
repdonnees=$(date +%Y-%m-%d)
# ==> Créera un répertoire de nom : YYYY-MM-DD

# Vérifie et crée repdonnees si nécessaire :
if test ! -d $repdonnees
        then
        mkdir $repdonnees
fi

# Supprime tout fichier temporaire :
rm -f temp.log

# Lit le fichier bp.conf et récupère toute URL qui ne se trouve pas dans le fichier podcast.log :
while read podcast
        do # ==> L'action principale suit.
        fichier=$(wget -q $podcast -O - | tr '\r' '\n' | tr \' \" | \
        sed -n 's/.*url="\([^"]*\)".*/\1/p')
        for url in $fichier
                do
                echo $url >> temp.log
                if ! grep "$url" podcast.log > /dev/null
                        then
                        wget -q -P $repdonnees "$url"
                fi
                done
        done < bp.conf

# Déplace le journal créé dynamiquement dans le journal permanent :
cat podcast.log >> temp.log
sort temp.log | uniq > podcast.log
rm temp.log
# Crée une liste musicale m3u :
ls $repdonnees | grep -v m3u > $repdonnees/podcast.m3u


exit 0

:"Notes
-----------
Pour une approche différente de l'écriture de script pour le Podcasting,
voir l'article de Phil Salkie,
Internet Radio to Podcast with Shell Tools
dans le numéro de septembre 2005 du LINUX JOURNAL,
http://www.linuxjournal.com/article/8171"

