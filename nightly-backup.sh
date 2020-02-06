#!/bin/bash
# nightly-backup.sh : Sauvegarde de nuit pour un disque firewire
# http://www.richardneill.org/source.php#nightly-backup-rsync


#  Ceci réalise une sauvegarde de l'ordinateur hôte vers un disque dur firewire
#+ connecté localement en utilisant rsync et ssh.
#  Il exécute ensuite une rotation des sauvegardes.
#  Exécutez-la via cron tous les jours à 5h du matin.
#  Cela ne sauvegarde que le répertoire principal.
#  Si le propriétaire (autre que l'utilisateur) doit être conservé,
#+ alors exécutez le processus rsync en tant que root (et ajoutez le -o).
#  Nous sauvegardons tous les jours pendant sept jours,
#+ puis chaque semaine pendant quatre semaines,
#+ puis chaque mois pendant trois mois.


#  Voir http://www.mikerubel.org/computers/rsync_snapshots/
#+ pour plus d'informations sur la théorie.
#  À sauvegarder sous : $HOME/bin/nightly-backup_firewire-hdd.sh


#  Bogues connus :
#  ---------------
#  i)  Idéalement, nous voulons exclure ~/.tmp et les caches du navigateur.
#  ii) Si l'utilisateur est devant son ordinateur à 5h du matin
#+     et que les fichiers sont modifiés alors que le rsync est en cours,
#+     alors la branche SAUVEGARDE_AUCASOU est appelée.
#      D'une certaine façon, c'est une fonctionnalité
#+     mais cela cause aussi une "fuite d'espace disque".


##### DÉBUT DE LA SECTION DE CONFIGURATION ###################################
UTILISATEUR_LOCAL=rjn         #  Utilisateur dont le répertoire principal sera
                              #+ sauvegardé.
POINT_MONTAGE=/backup         #  Point de montage du répertoire de sauvegarde.
                              #  Pas de slash à la fin !
                              #  Il doit être unique
                              #+ (par exemple en utilisant un lien symbolique udev)
REP_SOURCE=/home/$UTILISATEUR_LOCAL  # Pas de slash à la fin - important pour rsync.
REP_DEST_SAUVE=$POINT_MONTAGE/backup/`hostname -s`.${UTILISATEUR_LOCAL}.nightly_backup
ESSAI_A_BLANC=false           #  Si vrai, appelle rsync avec -n, réalisant un test.
                              #  Commentez ou configurez à faux pour une utilisation
                              #+ normale.
VERBEUX=false                 #  Si vrai, rend rsync verbeux.
                              #  Commentez ou configurez à faux sinon.
COMPRESSIONION=false          #  Si vrai, compresse.
                              #  Bon pour internet, mauvais sur LAN.
                              #  Commentez ou configurez à faux sinon.

### Codes d'erreur ###
E_VAR_NON_CONF=64
E_LIGNECOMMANDE=65
E_ECHEC_MONTAGE=70
E_PASREPSOURCE=71
E_NONMONTE=72
E_SAUVE=73
##### FIN DE LA SECTION DE CONFIGURATION #####################################


# Vérifie que toutes les variables importantes sont configurées :
if [ -z "$UTILISATEUR_LOCAL" ] ||
   [ -z "$REP_SOURCE" ] ||
   [ -z "$POINT_MONTAGE" ]  ||
   [ -z "$REP_DEST_SAUVE" ]
then
   echo "Une des variables n'est pas configurée ! Modifiez le fichier $0. ÉCHEC DE LA SAUVEGARDE."
   exit $E_VAR_NON_CONF
fi

if [ "$#" != 0 ]  # Si des paramètres en ligne de commande...
then              # Document(ation) en ligne.
  cat>FINDUTEXTE
    "Sauvegarde quotienne automatique exécutée par cron.
    Lisez les sources pour plus de détails : $0
    Le répertoire de sauvegarde est $REP_DEST_SAUVE .
    Il sera créé si nécessaire ; une initialisation est inutile.

    ATTENTION : le contenu de $REP_DEST_SAUVE est l'objet de rotation.
    Les répertoires nommés 'backup.\$i' seront éventuellement supprimés.
    Nous conservons des répertoires pour chaque jour sur sept jours (1-8),
    puis pour chaque semaine sur quatre semaines (9-12),
    puis pour chaque mois sur trois mois (13-15).

    Vous pouvez ajouter ceci à votre crontab en utilisant 'crontab -e'
    #  Fichiers sauvegardés : $REP_SOURCE dans $REP_DEST_SAUVE
    #+ chaque nuit à 3:15 du matin
         15 03 * * * /home/$UTILISATEUR_LOCAL/bin/nightly-backup_firewire-hdd.sh

    N'oubliez pas de vérifier que les sauvegardes fonctionnent, surtout si vous
    ne lisez pas le mail de cron !"
   exit $E_LIGNECOMMANDE
fi


# Analyse des options.
# ====================

if [ "$ESSAI_A_BLANC" == "true" ]; then
  ESSAI_A_BLANC="-n"
  echo "ATTENTION"
  echo "CECI EST UN TEST SIMPLE !"
  echo "Aucune donnée ne sera réellement transférée !"
else
  ESSAI_A_BLANC=""
fi

if [ "$VERBEUX" == "true" ]; then
  VERBEUX="-v"
else
  VERBEUX=""
fi

if [ "$COMPRESSION" == "true" ]; then
  COMPRESSION="-z"
else
  COMPRESSION=""
fi


#  Chaque semaine (en fait tous les huit jours) et chaque mois,
#+ des sauvegardes supplémentaires seront effectuées.
JOUR_DU_MOIS=`date +%d`            # Jour du mois (01..31).
if [ $JOUR_DU_MOIS = 01 ]; then    # Premier du mois.
  DEBUTMOIS=true
elif [ $JOUR_DU_MOIS = 08 \
    -o $JOUR_DU_MOIS = 16 \
    -o $JOUR_DU_MOIS = 24 ]; then
    # Jour 8,16,24
    # (on utilise 8 et non pas 7 pour mieux gérer les mois à 31 jours)
      DEBUTSEMAINE=true
fi

#  Vérifie que le disque est monté.
#  En fait, vérifie que *quelque chose* est monté ici !
#  Nous pouvons utiliser quelque chose d'unique sur le périphérique
#+ plutôt que de simplement deviner l'ID SCSI en utilisant la bonne règle udev
#+ dans /etc/udev/rules.d/10-rules.local
#+ et en plaçant une entrée adéquate dans /etc/fstab.
#  Par exemple, cette règle udev :
# BUS="scsi", KERNEL="sd*", SYSFS{vendor}="WDC WD16",
# SYSFS{model}="00JB-00GVA0     ", NAME="%k", SYMLINK="lacie_1394d%n"

if mount | grep $POINT_MONTAGE >/dev/null; then
  echo "Le point de montage $POINT_MONTAGE est déjà utilisé. OK"
else
  echo -n "Tentative de montage de $POINT_MONTAGE..."   
           # S'il n'est pas monté, essaie de le monter.
  sudo mount $POINT_MONTAGE 2>/dev/null

  if mount | grep $POINT_MONTAGE >/dev/null; then
    DEMONTE_APRES=TRUE
    echo "OK"
    #  Note : s'assure qu'il sera aussi démonté
    #+ si nous quittons prématurément avec erreur.
  else
    echo "ÉCHEC"
    echo -e "Rien n'est monté sur $POINT_MONTAGE. ÉCHEC DE LA SAUVEGARDE!"
    exit $E_ECHEC_MONTAGE
  fi
fi

# Vérifie que le répertoire source existe et est lisible.
if [ ! -r  $REP_SOURCE ] ; then
  echo "$REP_SOURCE n'existe pas ou ne peut être lu. ÉCHEC DE LA SAUVEGARDE."
  exit $E_PASREPSOURCE
fi

# Vérifie que la structure du répertoire de sauvegarde est bonne.
# Sinon, il la crée.
# Crée les sous-répertoires.
# Notez que backup.0 sera créé si nécessaire par rsync.

for ((i=1;i<=15;i++)); do
  if [ ! -d $REP_DEST_SAUVE/backup.$i ]; then
    if /bin/mkdir -p $REP_DEST_SAUVE/backup.$i ; then
    #  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  Pas de tests entre crochets. Pourquoi ?
      echo "Attention : le répertoire $REP_DEST_SAUVE/backup.$i n'existe pas"
      echo "ou n'a pas été initialisé. (Re-)creation du répertoire."
    else
      echo "ERREUR : le répertoire $REP_DEST_SAUVE/backup.$i"
      echo "n'existe pas et n'a pas pu être créé."
    if  [ "$DEMONTE_APRES" == "TRUE" ]; then
        # Avant de quitter, démonte le point de montage si nécessaire.
        cd
        sudo umount $POINT_MONTAGE &&
        echo "Démontage de $POINT_MONTAGE. Abandon."
    fi
      exit $E_NONMONTE
  fi
fi
done


#  Configure les droits à 700 pour de la sécurité
#+ sur un système multi-utilisateur.
if ! /bin/chmod 700 $REP_DEST_SAUVE ; then
  echo "ERREUR : n'a pas pu configurer les droits du répertoire $REP_DEST_SAUVE à 700."

  if  [ "$DEMONTE_APRES" == "TRUE" ]; then
  # Avant de quitter, démonte le point de montage si nécessaire.
     cd ; sudo umount $POINT_MONTAGE && echo "Démontage de $POINT_MONTAGE. Abandon."
  fi

  exit $E_NONMONTE
fi

# Création du lien symbolique : current -> backup.1 si nécessaire.
# Un échec ici n'est pas critique.
cd $REP_DEST_SAUVE
if [ ! -h current ] ; then
  if ! /bin/ln -s backup.1 current ; then
    echo "Attention : n'a pas pu créer le lien symbolique current -> backup.1"
  fi
fi


# Maintenant, exécute le rsync.
echo "Sauvegarde en cours avec rsync..."
echo "Répertoire source : $REP_SOURCE"
echo -e "Répertoire destination : $REP_DEST_SAUVE\n"


/usr/bin/rsync $ESSAI_A_BLANC $VERBEUX -a -S --delete --modify-window=60 \
--link-dest=../backup.1 $REP_SOURCE $REP_DEST_SAUVE/backup.0/

#  Avertit seulement, plutôt que de quitter, si rsync a échoué,
#+ car cela pourrait n'être qu'un problème mineur.
#  Par exemple, si un fichier n'est pas lisible, rsync échouera.
#  Ceci ne doit pas empêcher la rotation.
#  Ne pas utiliser, par exemple, `date +%a` car ces répertoires
#+ sont plein de liens et ne consomment pas *tant* d'espace.

if [ $? != 0 ]; then
  SAUVEGARDE_AUCASOU=backup.`date +%F_%T`.justincase
  echo "ATTENTION : le processus rsync n'a pas complètement réussi."
  echo "Quelque chose s'est mal passé. Sauvegarde d'une copie supplémentaire dans : $SAUVEGARDE_AUCASOU"
  echo "ATTENTION : si cela arrive fréquemment, BEAUCOUP d'espace sera utilisé,"
  echo "même si ce ne sont que des liens !"
fi

# Ajoute un fichier readme dans le répertoire principal de la sauvegarde.
# En sauvegarde un autre dans le sous-répertoire recent.
echo "La sauvegarde de $REP_SOURCE sur `hostname` a été exécuté le \
`date`" > $REP_DEST_SAUVE/README.txt
echo "Cette sauvegarde de $REP_SOURCE sur `hostname` a été créé le \
`date`" > $REP_DEST_SAUVE/backup.0/README.txt

# Si nous n'avons pas fait un test, exécute une rotation des sauvegardes.
[ -z "$ESSAI_A_BLANC" ] &&

  #  Vérifie l'espace occupé du disque de sauvegarde.
  #  Avertissement si 90%.
  #  Si 98% voire plus, nous échouerons probablement, donc abandon.
  #  (Note : df peut afficher plus d'une ligne.)
  #  Nous le testons ici plutôt qu'avant pour donner une chance à rsync.
  DISK_FULL_PERCENT=`/bin/df $REP_DEST_SAUVE |
  tr "\n" ' ' | awk '{print $12}' | grep -oE [0-9]+ `
  echo "Vérification de l'espace disque sur la partition de sauvegarde \
  remplie à $POINT_MONTAGE $DISK_FULL_PERCENT%."
  if [ $DISK_FULL_PERCENT -gt 90 ]; then
    echo "Attention : le disque est rempli à plus de 90%."
  fi
  if [ $DISK_FULL_PERCENT -gt 98 ]; then
    echo "Erreur : le disque est rempli complètement ! Abandon."
      if  [ "$DEMONTE_APRES" == "TRUE" ]; then
        # Avant de quitter, démonte le point de montage si nécessaire.
        cd; sudo umount $POINT_MONTAGE &&
        echo "Démontage de $POINT_MONTAGE. Abandon."
      fi
    exit $E_NONMONTE
  fi


 # Crée une sauvegarde supplémentaire.
 # Si cette copie échoue, abandonne.
 if [ -n "$SAUVEGARDE_AUCASOU" ]; then
   if ! /bin/cp -al $REP_DEST_SAUVE/backup.0 $REP_DEST_SAUVE/$SAUVEGARDE_AUCASOU
   then
     echo "ERREUR : échec lors de la création de la copie de sauvegarde \
     $REP_DEST_SAUVE/$SAUVEGARDE_AUCASOU"
     if  [ "$DEMONTE_APRES" == "TRUE" ]; then
       # Avant de quitter, démonte le point de montage si nécessaire.
       cd ;sudo umount $POINT_MONTAGE &&
       echo "Démontage de $POINT_MONTAGE. Abandon."
     fi
     exit $E_NONMONTE
   fi
 fi


 # Au début du mois, exécute une rotation des huit plus anciens.
 if [ "$DEBUTMOIS" == "true" ]; then
   echo -e "\nDébut du mois. \
   Suppression de l'ancienne sauvegarde : $REP_DEST_SAUVE/backup.15"  &&
   /bin/rm -rf  $REP_DEST_SAUVE/backup.15  &&
   echo "Rotation mensuelle, sauvegardes hebdomadaires : \
   $REP_DEST_SAUVE/backup.[8-14] -> $REP_DEST_SAUVE/backup.[9-15]"  &&
     /bin/mv $REP_DEST_SAUVE/backup.14 $REP_DEST_SAUVE/backup.15  &&
     /bin/mv $REP_DEST_SAUVE/backup.13 $REP_DEST_SAUVE/backup.14  &&
     /bin/mv $REP_DEST_SAUVE/backup.12 $REP_DEST_SAUVE/backup.13  &&
     /bin/mv $REP_DEST_SAUVE/backup.11 $REP_DEST_SAUVE/backup.12  &&
     /bin/mv $REP_DEST_SAUVE/backup.10 $REP_DEST_SAUVE/backup.11  &&
     /bin/mv $REP_DEST_SAUVE/backup.9 $REP_DEST_SAUVE/backup.10  &&
     /bin/mv $REP_DEST_SAUVE/backup.8 $REP_DEST_SAUVE/backup.9

 # Au début de la semaine, exécute une rotation des quatre seconds plus anciens.
 elif [ "$DEBUTSEMAINE" == "true" ]; then
   echo -e "\nDébut de semaine. \
   Suppression de l'ancienne sauvegarde hebdomadaire : $REP_DEST_SAUVE/backup.12"  &&
   /bin/rm -rf  $REP_DEST_SAUVE/backup.12  &&

   echo "Rotation des sauvegardes hebdomadaires : \
   $REP_DEST_SAUVE/backup.[8-11] -> $REP_DEST_SAUVE/backup.[9-12]"  &&
     /bin/mv $REP_DEST_SAUVE/backup.11 $REP_DEST_SAUVE/backup.12  &&
     /bin/mv $REP_DEST_SAUVE/backup.10 $REP_DEST_SAUVE/backup.11  &&
     /bin/mv $REP_DEST_SAUVE/backup.9 $REP_DEST_SAUVE/backup.10  &&
     /bin/mv $REP_DEST_SAUVE/backup.8 $REP_DEST_SAUVE/backup.9

 else
   echo -e "\nSuppression de l'ancienne sauvegarde quotidienne : $REP_DEST_SAUVE/backup.8"  &&
     /bin/rm -rf  $REP_DEST_SAUVE/backup.8

 fi  &&

 # Chaque jour, rotation de huit plus anciens.
 echo "Rotation des sauvegardes quotidiennes : \
 $REP_DEST_SAUVE/backup.[1-7] -> $REP_DEST_SAUVE/backup.[2-8]"  &&
     /bin/mv $REP_DEST_SAUVE/backup.7 $REP_DEST_SAUVE/backup.8  &&
     /bin/mv $REP_DEST_SAUVE/backup.6 $REP_DEST_SAUVE/backup.7  &&
     /bin/mv $REP_DEST_SAUVE/backup.5 $REP_DEST_SAUVE/backup.6  &&
     /bin/mv $REP_DEST_SAUVE/backup.4 $REP_DEST_SAUVE/backup.5  &&
     /bin/mv $REP_DEST_SAUVE/backup.3 $REP_DEST_SAUVE/backup.4  &&
     /bin/mv $REP_DEST_SAUVE/backup.2 $REP_DEST_SAUVE/backup.3  &&
     /bin/mv $REP_DEST_SAUVE/backup.1 $REP_DEST_SAUVE/backup.2  &&
     /bin/mv $REP_DEST_SAUVE/backup.0 $REP_DEST_SAUVE/backup.1  &&

 SUCCES=true


if  [ "$DEMONTE_APRES" == "TRUE" ]; then
  # Démonte le point de montage s'il n'était pas monté au début.
  cd ; sudo umount $POINT_MONTAGE && echo "$POINT_MONTAGE de nouveau démonté."
fi


if [ "$SUCCES" == "true" ]; then
  echo 'SUCCÈS !'
  exit 0
fi

# Nous devrions avoir déjà quitté si la sauvegarde a fonctionné.
echo 'ÉCHEC DE LA SAUVEGARDE ! Est-ce un test ? Le disque est-il plein ?) '
exit $E_SAUVE

