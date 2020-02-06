#! /bin/bash



# Fonction tacherontab qui permet la programmation du service tacheron
# 

#
# 
#
#
# Zante - Chatiron
#
var=$*

#var="-u guizmo -e"

# La fonction define_user permet de définir l'utilisateur du fichier tacherontab traité
# Zante - Chatiron
# Derniére mise a jour : 12/06/2013



function tacherontab {
param=$*

#echo ${#param}
if [ -n "$param" ] ; # si la chaine de caractere existe
#if [ "$param" != ""  ] ;
	then
		#echo $param 			# Affichage de la chaine de caractere
		#nb_mot=$(echo $param | wc -w)	# Nombre de mots de la chaine de caractere
		dernier_mot=${param##* }	
		#echo $dernier_mot		# Affichage du dernier caractere de la chaine

		verif_validity=${param%% *} 
# Garder les caracteres jusqu'au premier espace

		#echo $verif_validity	# deux premiers caractéres de la chaine



# Verification syntaxique
		if [ "$verif_validity"  = "-u" ]
			then
				user=${param:3} 
# Supprime les deux premiers caractéres de la chaine

				#echo $user # chaine sans le -u du début
				user=${user%%-*}
				#echo "l'utilisateur est :" "$user"

				
				

			if [ "$dernier_mot" = "-l" ] 
				then
				echo "affichage du fichier tacherontab de l'utilisateur" $user
				
# Changement de répertoire pour trouver le repertoire de l'utilisteur concerné
				cd /home
				cd $user
				cd Bureau/
				cd projet/
				
# Affichage du fichier tacherontab
				more `find etc/tacheron/tacherontab$user`
				


			elif [ "$dernier_mot" = "-r" ] 
				then
				echo "efface le fichier tacherontab de l'utilisateur" $user

# Changement de répertoire pour trouver le repertoire de l'utilisteur concerné
				cd /home
				cd $user
				cd Bureau/
				cd projet/

# Suppression et création du fichier
				cd `find etc/tacheron/`
				rm tacherontab$user
				touch tacherontab$user
				

			elif [ "$dernier_mot" = "-e" ] 
				then
				echo "creation ou édition"
			
# Changement de répertoire pour trouver le repertoire de l'utilisteur concerné
				cd /home
				cd $user
				cd Bureau/
				cd projet/
				
# Trouver le fichier /etc/tacheron/tachrontab$user
				cd `find etc/tacheron/`
				fichier=tacherontab$user
				
				#echo $fichier
				if [ -f $fichier ] ;
					then
					#echo "sa marche"
					mkdir -p ../../tmp
					cp $fichier ../../tmp/$fichier
					vi ../../tmp/$fichier
					cp ../../tmp/$fichier $fichier
					rm -rf ../../tmp/$fichier
					echo "le fichier $fichier a été édité"
				else
					echo "le fichier $fichier n'existe pas"
					
					mkdir -p ../../tmp
					vi ../../tmp/$fichier
					cp ../../tmp/$fichier $fichier
					echo "le fichier $fichier a été créé et édité"
				fi


			else
				echo "commande invalide" 
			fi	



		else
		echo "mauvaise expression!"


		fi
		#user=${param#-u } | grep ^..
		#echo $user
#		define_user $*


else 
	echo "aucun argument a executer"

fi
}

tacherontab $var
