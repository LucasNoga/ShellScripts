i=1
flag=0
echo "Entrer un mot"
read str
l=`expr "$str" : ".*"`
ll=`expr $l / 2`
while [ $i -le $ll ] do
	c1=`echo $str | cut -c$i`
	c2=`echo $str | cut -c$l`
	if [ $c1 != $c2 ] then
	 	flag=1
	fi	
	i=`expr $i + 1`
	l=`expr $l - 1` 
done
if [ $flag -eq 0 ] then
	echo "$str est un palindrome"
else
	echo "$str n'est pas un palindrome"
fi

