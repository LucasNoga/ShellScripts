while read 1
do
	nb=0
	somme=0
	for mot in $1; do
		#si le nombre n'ets pas une note comprise entre 0 et 20
		if [[ $nb -lt 0 ]]; then
			echo $mot
		else
			let somme=somme+mot
		fi
		#on incremente le nombre de note
		let nb=nb+1
	done
	let nb=nb-2
	moy=$(echo "scale=5";$somme/$nb" | bc)
	echo "moyenne = $moy"
done < notes