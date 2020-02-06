if test -z $1 ; then
	echo "usage : horloge2.sh <heure>"
	exit
fi
echo "Nous sommes le `date'+%d %mm %Y, il est $1";