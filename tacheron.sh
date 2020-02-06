#! /bin/bash

# Fonction update: met a jour le fichier contenant l'historique d'utilisation du programme

#
# La fonction "update" reçoit en parametres deux informations: 
# - le nom de la commande
# - la valididité de la commande : si la commande c'est effectuee correctement "--succeed--", en cas d'echec "--error--"
#
#
# Zante - Chatiron
# Derniére mise a jour : 17/05/2013
#


info="allo salut a tous --succeed--"



# On vérifie si les taches de "tacherontab" sont sous la bonne forme
function verif_syntax {

function verif_jour {

if [ $(echo $jour | grep "^[0-9]\{1,2\}$") ] && [ $jour -le 6 ]; #nombre simple et inférieur à 60
then
commande
elif [ $( echo $jour | grep "^\([0-9]\{1,2\},\)*[0-9]\{1,2\}$") ]; #liste séparée par des virgules
then
commande
elif [ $( echo $jour | grep "^\([0-9]\{1,2\}-\)*[0-9]\{1,2\}$") ]; #intervale -
then
commande
elif awk '{if(( $6 == "x" ))}' etc/tacherontab #si seconde = *
then
commande
elif [ $(echo $jour | grep "^\x\/[0-9]\{1,2\}$") ]; # sous la forme */X avec X un nb
then
commande
elif [ $( echo $jour | grep "^\([0-9]\{1,2\}-[0-9]\{1,2\}\)\/[0-9]\{1,2\}$") ]; # X-Y/Z
then 
commande
elif [ $( echo $jour | grep "^\([0-9]\{1,2\}-[0-9]\{1,2\}\)\{1\}\(~[0-9]\{1,2\}\)*$") ]; #X-Y~Z liste avec exception
then 
commande
else 
echo "Erreur syntaxique jour"
fi
}

function verif_mois {

if [ $(echo $mois | grep "^[0-9]\{1,2\}$") ] && [ $mois -le 12 ]; #nombre simple et inférieur à 60
then
verif_jour
elif [ $( echo $mois | grep "^\([0-9]\{1,2\},\)*[0-9]\{1,2\}$") ]; #liste séparée par des virgules
then
verif_jour
elif [ $( echo $mois | grep "^\([0-9]\{1,2\}-\)*[0-9]\{1,2\}$") ]; #intervale -
then
verif_jour
elif awk '{if(( $5 == "x" ))}' etc/tacherontab #si seconde = *
then
verif_jour
elif [ $(echo $mois | grep "^\x\/[0-9]\{1,2\}$") ]; # sous la forme */X avec X un nb
then
verif_jour
elif [ $( echo $mois | grep "^\([0-9]\{1,2\}-[0-9]\{1,2\}\)\/[0-9]\{1,2\}$") ]; # X-Y/Z
then 
verif_jour
elif [ $( echo $mois | grep "^\([0-9]\{1,2\}-[0-9]\{1,2\}\)\{1\}\(~[0-9]\{1,2\}\)*$") ]; #X-Y~Z liste avec exception
then 
verif_jour
else
echo "erreur syntaxique mois"
fi

}

function verif_num_jour {

if [ $(echo $num_jour | grep "^[0-9]\{1,2\}$") ] && [ $num_jour -le 31 ]; #nombre simple et inférieur à 60
then
verif_mois
elif [ $( echo $num_jour | grep "^\([0-9]\{1,2\},\)*[0-9]\{1,2\}$") ]; #liste séparée par des virgules
then
verif_mois
elif [ $( echo $num_jour | grep "^\([0-9]\{1,2\}-\)*[0-9]\{1,2\}$") ]; #intervale -
then
verif_mois
elif awk '{if(( $4 == "x" ))}' etc/tacherontab #si seconde = *
then
verif_mois 
elif [ $(echo $num_jour | grep "^\x\/[0-9]\{1,2\}$") ]; # sous la forme */X avec X un nb
then
verif_mois
elif [ $( echo $num_jour | grep "^\([0-9]\{1,2\}-[0-9]\{1,2\}\)\/[0-9]\{1,2\}$") ]; # X-Y/Z
then 
verif_mois
elif [ $( echo $num_jour | grep "^\([0-9]\{1,2\}-[0-9]\{1,2\}\)\{1\}\(~[0-9]\{1,2\}\)*$") ]; #X-Y~Z liste avec exception
then 
verif_mois
else
echo "erreur synatxique num jour"
fi

}

function verif_heure {

if [ $(echo $heure | grep "^[0-9]\{1,2\}$") ] && [ $heure -le 23 ]; #nombre simple et inférieur à 60
then
verif_num_jour
elif [ $( echo $heure | grep "^\([0-9]\{1,2\},\)*[0-9]\{1,2\}$") ]; #liste séparée par des virgules
then
verif_num_jour
elif [ $( echo $heure | grep "^\([0-9]\{1,2\}-\)*[0-9]\{1,2\}$") ]; #intervale -
then
verif_num_jour
elif awk '{if(( $3 == "x" ))}' etc/tacherontab #si seconde = *
then
verif_num_jour
elif [ $(echo $heure | grep "^\x\/[0-9]\{1,2\}$") ]; # sous la forme */X avec X un nb
then
verif_num_jour
elif [ $( echo $heure | grep "^\([0-9]\{1,2\}-[0-9]\{1,2\}\)\/[0-9]\{1,2\}$") ]; # X-Y/Z
then 
verif_num_jour
elif [ $( echo $heure | grep "^\([0-9]\{1,2\}-[0-9]\{1,2\}\)\{1\}\(~[0-9]\{1,2\}\)*$") ]; #X-Y~Z liste avec exception
then 
verif_num_jour
else
echo "erruer syntaxique heure"
fi

}

function verif_minute {

if [ $(echo $minute | grep "^[0-9]\{1,2\}$") ] && [ $minute -le 59 ]; #nombre simple et inférieur à 60
then
verif_heure
elif [ $( echo $minute | grep "^\([0-9]\{1,2\},\)*[0-9]\{1,2\}$") ]; #liste séparée par des virgules
then
verif_heure
elif [ $( echo $minute | grep "^\([0-9]\{1,2\}-\)*[0-9]\{1,2\}$") ]; #intervale -
then
verif_heure
elif awk '{if(( $2 == "x" ))}' etc/tacherontab #si seconde = *
then
verif_heure 
elif [ $(echo $minute | grep "^\x\/[0-9]\{1,2\}$") ]; # sous la forme */X avec X un nb
then
verif_heure
elif [ $( echo $minute | grep "^\([0-9]\{1,2\}-[0-9]\{1,2\}\)\/[0-9]\{1,2\}$") ]; # X-Y/Z
then 
verif_heure
elif [ $( echo $minute | grep "^\([0-9]\{1,2\}-[0-9]\{1,2\}\)\{1\}\(~[0-9]\{1,2\}\)*$") ]; #X-Y~Z liste avec exception
then 
verif_heure
else
echo "erreur syntaxique minute"
fi

}

function verif_seconde {
while read C1 C2 C3 C4 C5 C6
do 
seconde=$C1
minute=$C2
heure=$C3
num_jour=$C4
mois=$C5
jour=$C6

if [ $(echo $seconde | grep "^[0-9]\{1,2\}$") ] && [ $seconde -le 3 ]; #nombre simple et inférieur à 3
then
verif_minute
elif [ $( echo $seconde | grep "^\([0-9]\{1,2\},\)*[0-9]\{1,2\}$") ]; #liste séparée par des virgules
then
verif_minute
elif [ $( echo $seconde | grep "^\([0-9]\{1,2\}-\)*[0-9]\{1,2\}$") ]; #intervale -
then
verif_minute
elif awk '{if(( $1 == "x" ))}' etc/tacherontab #si seconde = *
then
verif_minute
elif [ $(echo $seconde | grep "^\x\/[0-9]\{1,2\}$") ]; # sous la forme */X avec X un nb
then
verif_minute
 elif [ $( echo $seconde | grep "^\([0-9]\{1,2\}-[0-9]\{1,2\}\)\/[0-9]\{1,2\}$") ]; # X-Y/Z
then 
verif_minute
elif [ $( echo $seconde | grep "^\([0-9]\{1,2\}-[0-9]\{1,2\}\)\{1\}\(~[0-9]\{1,2\}\)*$") ]; #X-Y~Z liste avec exception
then 
verif_minute
else 
echo "erreur suntaqiue seconde"
fi

done <etc/tacherontab
}

verif_seconde

}

#permet de vérifier la date actulle avec la date située dans tacherontab

function dateOK() {
 date_actuelle="$1"
 date_tacheron="$2"
 return=1 

 if [ "$date_tacheron" = "x" ]; then # contient une étoile
   return=0 

 elif [ $(echo "$date_tacheron" | grep "^$date_actuelle$") ]; then # nombre simple
   return=0 

 elif [ $(echo "$date_tacheron" | grep "$date_actuelle" | grep -v [-~/]) ]; then  #virgule
   IFS=',' read -a array <<< "$date_tacheron"
   for element in "${array[@]}"
    do 
echo LOLOLO
    if [[ "$element" -eq "$date_actuelle" ]];then 

     return 0;
    fi;
   done

 elif [ $(echo "$date_tacheron" | grep "-" | grep -v [,~/]) ]; then  # intervalles
echo "$date_tacheron"
   champs1=$(echo "$date_tacheron" | cut -d'-' -f1)
   champs2=$(echo "$date_tacheron" | cut -d'-' -f2)
   if [[ "$champs1" -le "$date_actuelle" ]] && [[ "$champs2" -ge "$date_actuelle" ]]; then
      return 0
   fi

   elif [ $(echo "$date_tacheron" | grep "~") ]; then # "~"

       IFS='~' read -a array <<< "$date_tacheron"
       for element in "${array[@]}"
        do 
                if [[ "$element" -eq "$date_actuelle" ]];then 
                	return 1
		fi
                
        done
	return 0;

 elif [ $(echo "$date_tacheron" | grep "/") ];then # contient des slashs
    champs1=$(echo "$date_tacheron" | cut -d'/' -f1) 
    champs2=$(echo "$date_tacheron" | cut -d'/' -f2) 
   
    if [ "$champs1" = "x" ];then #commeance par *
        resultat=$(expr "$date_actuelle" % "$champs2")
        if [ "$resultat" -eq 0 ]; then
                return 0
        else
                return 1
        fi
  
    elif [ $(echo "$champs1" | grep "-" | grep -v [,~/]) ]; then #commence par intervalle
      c1=$(echo "$champs1" | cut -d'-' -f1)
      c2=$(echo "$champs1" | cut -d'-' -f2)
        if [ "$c1" -le "$date_actuelle" ] && [ "$c2" -ge "$date_actuelle" ]; then
                resultat=$(expr "$date_actuelle" % "$champs2")
                if [ "$resultat" -eq 0 ]; then
                        return 0
                else
                        return 1
                fi      
        fi
      
  
    fi
 fi

 return $return

}

#

function verifSeconde {

seconde_actuelle=$(date +'%S')
if [ "$seconde_actuelle" -le 10 ]; then
     seconde_actuelle=$(echo $seconde_actuelle | cut -c2)
fi

if [ "$seconde_actuelle" -le 14 ];then
   seconde_tacheron=0
elif [ "$seconde_actuelle" -le 29 ];then
   seconde_tacheron=1
elif [ "$seconde_actuelle" -le 44 ];then
   seconde_tacheron=2
else 
   seconde_tacheron=3
fi
}

#fonction principale

function commande {

while [ 1 ]
do

while read line
do
minute_actuelle=$(date +'%M')
heure_actuelle=$(date +'%H')
num_jour_actuel=$(date +'%d')		
mois_actuel=$(date +'%m')
jour_actuel=$(date +'%u')

seconde=$(echo $line | awk '{split($0,a," "); print a[1]}')
minute=$(echo $line | awk '{split($0,a," "); print a[2]}')
heure=$(echo $line | awk '{split($0,a," "); print a[3]}')
num_jour=$(echo $line | awk '{split($0,a," "); print a[4]}')
mois=$(echo $line | awk '{split($0,a," "); print a[5]}')
jour=$(echo $line | awk '{split($0,a," "); print a[6]}')
cmd=$(echo $line | cut -d" " -f7-)

if dateOK "$mois_actuel" "$mois" ; then
	if dateOK "$num_jour_actuel" "$num_jour" ; then
		if dateOK "$jour_actuel" "$jour" ; then
			if dateOK "$heure_actuelle" "$heure" ; then
				if dateOK "$minute_actuelle" "$minute"; then
				   verifSeconde
					if dateOK "$seconde_tacheron" "$seconde" ; then
`$cmd`

erreur=`echo $?`
if [ "${erreur}" -eq 0 ]; then
message_error="Tache accomplie! Aucune erreur a l'execution"


# Ecriture dans le fichier /var/log/tacheron.txt, historique d'utilisation des taches planifiées.

echo "date d'execution:" `date` >> var/log/tacheron.txt
echo "nom du fichier: $cmd"  >> var/log/tacheron.txt
echo -e "$message_error\n" >> var/log/tacheron.txt

else
message_error="ERREUR: Le fichier n'a pu etre execute"


# Ecriture dans le fichier /var/log/tacheron.txt, historique d'utilisation des taches planifiées.

echo "date d'execution:" `date` >> var/log/tacheron.txt
echo "nom du fichier: $cmd"  >> var/log/tacheron.txt
echo -e "$message_error\n" >> var/log/tacheron.txt

fi
					fi
				fi
			fi
		fi
	fi
fi

done <etc/tacherontab
 
done

}

# création des fichiers allow et deny s'il n'existe pas

if [ ! -f etc/tacheron.allow ]
then touch etc/tacheron.allow
fi

if [ ! -f etc/tacheron.deny ]
then touch etc/tacheron.deny
fi

# on va vérifier si le user est autorisé 

if [ $(whoami) = "root" ];
then
echo "Lancement du programme - root"
verif_syntax
else if awk 'BEGIN { print "Verification des Users dans etc/tacheron.allow";}
   $1 == $USER {print "User autorisé : "$0 } 
   END   { print "Fin" }' etc/tacheron.allow
then
echo "lancement du programme"
verif_syntax
else if awk 'BEGIN { print "Verification des Users dans etc/tacheron.deny";}
           $1 == $USER {print "User non autorisé : "$0 } 
           END   { print "Fin" }' etc/tacheron.deny 
	then
	echo "Vous n'êtes pas autorisé"
	fi
fi
fi

