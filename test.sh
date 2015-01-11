#!/bin/bash

number=$1
koniec=$2
proby=1

rm -R results2_old
mv results2 results2_old
mkdir results2
args=--print_time_only
#args=--time_only

while [ $number -le $koniec  ];
do
	echo "Test for N= $number * 2^14"
	cat constants2.cl | sed "s/NUMBER/$number/g"	> clinclude/constants.cl
	make clean
	make all -j6 &> build_$number.txt

	j=0
	while [ $j -lt $proby ];
	do
		echo "Test for N= $number * 2^14   ---   test # $j"
		date
		./nbodyProject $args | tee results2/res_$number.$j.txt
		j=$(( $j + 1 ))
	done
	number=$(( $number + 1 ))
done
exit 0

number=$1
while [ $number -le $koniec ];
do
	j=0
	sumy=(0 0 0 0 0 0 0 0 0);
	while [ $j -lt $proby ];
	do
		plik=results2/res_$number_$j.txt

		k=0
		while read line
		do
			sumy[$k]=$(( ${sumy[$k]} + $line ))
		done < $plik

		j=$(( $j + 1 ))
	done

	k=0
	while [ $k -lt 9 ];
	do
		echo ${sumy[$k]} >> results2/ares_$number.txt
	done
	number=$(( $number + 1 ))
done
