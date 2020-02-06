# premier
echo "Entrer un nombre"
read nombre

if [ 0 -eq `echo $nombre | grep -c '[^0-9][^0-9]*'` ] then
	flag=0
	i=2
	while [ $i -lt $nombre ] do
		val=`expr $nombre % $i`
		i=`expr $i + 1`
		if [ $val -eq 0 ] then
			flag=1
		fi 
	done
	if [ $flag -eq 1 ] then 	
		echo "$nombre n'est pas premier"
	else
		echo "$nombre est premier"
	fi
else
	echo "Les caractères saisis ne comportent pas que des chiffres"
fi	