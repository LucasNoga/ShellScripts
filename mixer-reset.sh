#Ce script règle le volume du mixer audio en fonction de l'heure. C'est à dire qu'il monte le volume en journée et le baisse quand arrive le soir. Pratique quand on joue souvent des mp3 ou des CD, et que l'on ne voit pas le temps passer... Personnellement, il m'arrive souvent de me mettre devant ma machine vers 19h, et d'y rester jusqu'aux alentours de minuit, avec les mp3 qui défilent... Et évidemment, je ne pense pas à baisser le volume... Voilà pourquoi j'ai écrit ce script. Cette version utilise aumix; mais rien ne vous empêche de choisir un autre mixer (quelques variables à changer dans le script, c'est expliqué dedans).

#Depuis la version 2.0, le script accepte deux options : "reset" et "update". Voir plus bas dans cette page comment utiliser ces options.

#Tout comme pour ipcheck.sh, ce script est destiné à être appelé régulièrement par crond. Pour ma part, il est lancé toutes les heures. Voici la marche à suivre:

#    Loggez-vous en root (ou faites un "su")
#    Demandez à modifier la crontab par la commande "crontab -e"
#    Entrez la ligne suivante:

#    0 * * * * /usr/local/bin/mixer-reset.sh update

#    Sauvegardez, c'est fini.

#Evidemment, si vous décidez de placer le script ailleurs que dans /usr/local/bin, modifiez la ligne en conséquence.

#Pour plus de précisions sur la syntaxe du fichier crontab, "man 5 crontab".




#/////////////////////////////////////////////////////////////////////////////////////////

#! /bin/sh

# mixer-reset.sh - Version 2.0
# Uses an audio mixer to initialize the volume of your audio
# peripherals, and the main volume is set regarding the current time
# Put this in your crontab !
# By Raphaël HALIMI <raphaelh@easynet.fr>

FORMAT=`date | grep "  "`

if [ -z "$FORMAT" ] ; then
   HEURE=`date | cut -d " " -f 4 | cut -d ":" -f 1`
else
   HEURE=`date | cut -d " " -f 5 | cut -d ":" -f 1`
fi

# Some variables to make configuration easier - it is HIGHLY recommended to
# change these to suit your system... Or simply install aumix :-)

MIXER=aumix
MAIN_VOLUME_OPTION='-v'
MIXER_OPTIONS='-b90 -t70 -s90 -w90 -p90 -l80 -m60 -c100 -x90 -i90 -o0'


case "$1" in
     reset)
           $MIXER $MIXER_OPTIONS
	   ;;
     update)
           case "$HEURE" in
	        07)
		  MAIN_VOLUME=+10
		  ;;
		09)
		  MAIN_VOLUME=+15
		  ;;
		20)
		  MAIN_VOLUME=-5
		  ;;
		22)
		  MAIN_VOLUME=-10
		  ;;
		00)
		  MAIN_VOLUME=-10
		  ;;
		*)
		  MAIN_VOLUME=+0
		  ;;
	   esac
	   $MIXER $MAIN_VOLUME_OPTION$MAIN_VOLUME
	   ;;
      *)
           echo "Usage: mixer-reset.sh {reset|update}"
	   echo ; echo "reset: set everything but the main volume to the values specified in the script."
	   echo "update: increase or decrease the main volume according to the current time."
	   exit 1
	   ;;
esac
