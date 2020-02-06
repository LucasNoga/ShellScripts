#!/bin/bash

reps=($HOME "/Applications")
#Chemin de la backup
Backup=$TMPDIR"BACKUP"
Desktop="$HOME/Desktop"


# Copy des repertoires d'archives, de la dev, et du bureau dans le repertoire choisi
######################################################################INUTILISER######################################################################
find_dir()
{
	for element in "${reps_search[@]}"
	do
		echo "Recherche du repertoire:" $element
		reps+=($(find / -type d -name $element | head -n 1))
		echo "Repertoire trouvé"
	done
}

display_directory()
{
	for element in "${reps[@]}"
	do
		echo -e "Le repertoire a dupliqué est" $element
	done
}

sauvegarde()
{
	cd $HOME
	### Creation du repertoire si il n'existe pas
	if [ ! -d $Backup ]
	then 
		mkdir $Backup
	fi
	
	cd $Backup
	echo -e "Copie dans le repertoire" $(pwd)
	for element in "${reps[@]}"
	do
		#Copie des elements
		echo -e "copie du repertoire" $element
		cp -rfp $element .
	done

	Deplacement du rep /tmp sur le bureau
	mv $Backup $Desktop
}

###
# Main body of script starts here
###


echo "Debut du script..."
display_directory
sauvegarde
echo "Fin du script..."

echo "End of script..."
echo $? ": valeur de sortie de la derniere commande executee."