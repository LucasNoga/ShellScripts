#!/bin/bash
rep = '/Movies'
if [ test $# -eq 1 ]
then
	"donner le repertoire a deplacer"
	read dir;
else
	dir=$1
fi

if [[ test -d $dir ]]; then
	cd $dir
	for i in `ls`; do
	 	if [[ test -d $i ]]; then
	 		mv -r $i $rep 
	 	fi
	 done
fi

echo "tout est deplacer"