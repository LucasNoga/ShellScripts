palin(){
	i=1
	flag=0
	l=`expr "$1" : ".*"`
	ll=`expr $l / 2`
	while [ $i -le $ll ] do
		c1=`echo $1 | cut -c$i`
		c2=`echo $1 | cut -c$l`
		if [ $c1 != $c2 ] then
		 	flag=1
		fi	
		i=`expr $i + 1`
		l=`expr $l - 1` 
	done
	if [ $flag -eq 0 ] then
		return 1 
	else
		return 0 
	fi
}

tag=0
echo "Entrer un nom de fichier"
read fich
if [ -f $fich ] then
indice=0
	while read ligne do
		indice=`expr $indice + 1`
		if [ `expr "$ligne" : ".*"` -ne 0 ] then 
			set $ligne
			for ind in $* do
				palin $ind
				if [ $? -eq 1 ] then
					echo "Le mot $ind a la ligne $indice est un palindrome"
					tag=1
				fi  
			done
		fi
	done <$fich
	if [ $tag -eq 0 ] then
		echo "Le fichier ne contient pas de palindrome"
	fi
else
	echo "Le fichier $fich n'existe pas"
fi