#!/bin/bash
number_of_iterations=$1
number_of_iterations=${number_of_iterations/.*}

i="0"
while [ $i -lt $number_of_iterations ]
do
	echo "--- i = $i"
    	
	i=$[$i+1]
	sleep 0.3
done 

