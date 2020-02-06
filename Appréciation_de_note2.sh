#!bin/bash

note=0 
moyenne=0 
i=0 
 
until [ "$note" -lt 0 ]; do 

	echo "Saisir note: "
	read -r note
    if [ "$note" = "q" ]; then 
        note=-1 
        echo "au revoir !" 
    elif [ "$note" -ge 16 ]; then 
        echo "très bien" 
    elif [ "$note" -ge 14 ]; then 
        echo "bien" 
    elif [ "$note" -ge 12 ]; then 
        echo "assez bien" 
    elif [ "$note" -ge 10 ]; then 
        echo "moyen" 
    elif [ "$note" -ge 0 ]; then 
        echo "insuffisant" 
    else 
        echo "au revoir !" 
    fi 
 
    if [ "$note" -ge 0 ]; then 
        let moyenne=$moyenne+$note 
        let i=$i+1 
    fi 
done 
 
if [ "$i" -le 0 ]; then 
    let i=1 
fi 
 
let moyenne=$moyenne/$i 
echo "La moyenne est de $moyenne ($i notes)"