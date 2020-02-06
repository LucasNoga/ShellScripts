#!/bin/bash
# archiveweblogs.sh : Préserver les weblogs

#  Ce script préservera les traces web habituellement supprimées à partir d'une
#+ installation RedHat/Apache par défaut.
#  Il sauvegardera les fichiers en indiquant la date et l'heure dans le nom du
#+ fichier, compressé avec bzip, dans un répertoire donné.
#
#  Lancez ceci avec crontab la nuit car bzip2 avale la puissance du CPU sur des
#+ journaux particulièrement gros.
#  0 2 * * * /opt/sbin/archiveweblogs.sh


PROBLEME=66

# Modifiez-le par votre répertoire de sauvegarde.
REP_SAUVEGARDE=/opt/sauvegardes/journaux_web

# Apache/RedHat par défaut
JOURS_DE_SAUVEGARDE="4 3 2 1"
REP_JOURNAUX=/var/log/httpd
JOURNAUX="access_log error_log"

# Emplacement par défaut des programmes RedHat
LS=/bin/ls
MV=/bin/mv
ID=/usr/bin/id
CUT=/bin/cut
COL=/usr/bin/column
BZ2=/usr/bin/bzip2

# Sommes-nous root?
USER=`$ID -u`
if [ "X$USER" != "X0" ]; then
  echo "PANIQUE : Seul root peut lancer ce script !"
  exit $PROBLEME
fi

# Le répertoire de sauvegarde existe-t'il ? est-il modifiable ?
if [ ! -x $REP_SAUVEGARDE ]; then
  echo "PANIQUE : $REP_SAUVEGARDE n'existe pas ou n'est pas modifiable !"
  exit $PROBLEME
fi

# Déplace, renomme et compresse avec bzip2 les journaux
for jour in $JOURS_DE_SAUVEGARDE; do
  for journal in $JOURNAUX; do
    MONFICHIER="$REP_JOURNAUX/$journal.$jour"
    if [ -w $MONFICHIER ]; then
      DTS=`$LS -lgo --time-style=+%Y%m%d $MONFICHIER | $COL -t | $CUT -d ' ' -f7`
      $MV $MONFICHIER $REP_SAUVEGARDE/$journal.$DTS
      $BZ2 $REP_SAUVEGARDE/$journal.$DTS
    else
            # Affiche une erreur seulement si le fichier existe (ne peut
            # s'écrire sur lui-même).
      if [ -f $MONFICHIER ]; then
        echo "ERREUR : $MONFICHIER n'est pas modifiable. Je passe au suivant."
      fi
    fi
  done
done

exit 0

