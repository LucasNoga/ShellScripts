#Un script génial pour tous les utilisateurs d'EsounD (esd). A essayer si c'est votre cas. Nouveau !

#Ce script est génial. Il vous permet de gérer facilement EsounD, le démon esd. Il est on ne peut plus simple à mettre en oeuvre : lancez-le... Et à partir de là, on peut lancer/tuer le serveur, le mettre en standby, voir les infos à propos du serveur ou des clients...

#Deux choses à savoir. D'abord, ce script utilise le bash prompting : il écrit en couleurs :-) Ensuite, il est "under heavy construction" : il marche bien, mais il y a plein de fonctions qu'on peut encore implémenter et que je n'ai pas eu le temps de mettre...

#A surveiller donc !




#/////////////////////////////////////////////////////////////////////////////////////////


#! /bin/sh

# esd-control.sh - v0.1
# A little script to easily control of EsounD, the Enlightened Sound Daemon
# By Raphaël HALIMI <raphaelh@easynet.fr>

# We check if we are owner of the currently running EsounD
# (in case it was already running before we launched the script)

if [ -e /tmp/.esd/socket -a ! -O /tmp/.esd/socket ] ; then
   OWNER=`ls -l /tmp/.esd/socket | awk '{print $3}'`
   echo "EsounD is running, but it doesn't belong to you : $OWNER started it."
   echo "You'll need $OWNER's password to control EsounD."
   su $OWNER -c esd-control.sh
   exit
fi

# Okay, if we made it so far, we can start

while true ; do

      clear

      # Welcome... :-)

      echo "Welcome to the Enlightened Sound Daemon controller !" ; echo

      # See if EsounD is running and/or on standby, it will be usefull later

      if [ -e /tmp/.esd/socket ] ; then
         RUNNING=1
	 if [ "`esdctl standbymode`" = "server is running" ] ; then
	    STANDBY=0
	 elif [ "`esdctl standbymode`" = "server is on standby" ] ; then
	    STANDBY=1
	 fi
      else
         RUNNING=0
	 STANDBY=0
      fi

      # We print some informations... In Technicolor :-)

      GREEN="\033[32m"
      RED="\033[31m"
      NORMAL="\033[0m"

      if [ $RUNNING = 1 ] ; then
         echo -e "EsounD started : "$GREEN"YES"$NORMAL
	 if [ $STANDBY = 0 ] ; then
	    echo -e "EsounD state : "$GREEN"RUNNING"$NORMAL
	 elif [ $STANDBY = 1 ] ; then
	    echo -e "EsounD state : "$RED"STANDBY"$NORMAL
	 fi
      elif [ $RUNNING = 0 ] ; then
           echo -e "EsounD started : "$RED"NO"$NORMAL
      fi

      echo

      # And now the menu

      echo "What do you want to do ?" ; echo

      if [ $RUNNING = 0 ] ; then
         echo "1. Start server"
      elif [ $RUNNING = 1 ] ; then
         echo "1. Kill server"
      fi

      if [ $STANDBY = 0 ] ; then
         echo "2. Standby server"
      elif [ $STANDBY = 1 ] ; then
         echo "2. Run server"
      fi

      echo "3. See server info"

      echo "4. See server/clients info"

      echo; echo -n "Which option (or press [ENTER] to exit) ? " ; read ACTION

      case "$ACTION" in
       1)
	if [ -e /tmp/.esd/socket ] ; then
	   echo ; echo "It may kill ALL currently running applications which use EsounD."
	   echo -n "Are you sure you want to kill the EsounD server ? (Y/N) " ; read SURE
	   if [ $SURE = Y -o $SURE = y ] ; then
	      killall esd ; echo ; echo -n "Server killed." ; sleep 1
	   fi
	else
	   esd &
	   echo ; echo -n "Server started." ; sleep 2
	fi
        ;;
       2)
        if [ $RUNNING = 0 ] ; then
	   echo ; echo -n "Er... The server's not started yet :-)" ; sleep 2
	elif [ $RUNNING = 1 ] ; then
	   if [ $STANDBY = 0 ] ; then
	      esdctl off
	   elif [ $STANDBY = 1 ] ; then
	      esdctl on
	   fi
	fi
        ;;
       3)
        clear ; esdctl serverinfo | more ; echo
	echo -n "Press ENTER to return to the menu. " ; read BOBO
	;;
       4)
        clear ; esdctl allinfo | more ; echo
	echo -n "Press ENTER to return to the menu. " ; read BOBO
	;;
      "")
	echo ; echo "Thank you for using my humble bash script :-)"
	break
	;;
       *)
        echo ; echo -n "That's not an option !" ; sleep 2
        ;;
      esac
done
