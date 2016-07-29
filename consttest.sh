#!/bin/bash

CONST_SCRIPT=./getconsts.sh
GOSECCO_CONSTANTS=/git/gosecco/constants/go_constants.go

echo "Checking for any malformed output..."
$CONST_SCRIPT | egrep -v  '[_a-z]+\s+[_A-Za-z0-9]+[A-Za-z0-9]*\s+.*[0-9].*'

ALL_CATEGORIES=`$CONST_SCRIPT | awk '{print $1}' | sort -u`

ALL_GOSECCO_CONSTANTS=`cat $GOSECCO_CONSTANTS | egrep '\s*AllConstants\["|\s*AllErrors\["|\s*Syscalls\["' | awk -F '"' '{print $2}'| sort -u`
ALL_OUR_CONSTANTS=`$CONST_SCRIPT | awk '{print $2}' | sort -u`

echo "Checking to make sure we aren't missing variables from gosecco..."

for i in $ALL_GOSECCO_CONSTANTS; do 
	in=0

	for element in $ALL_OUR_CONSTANTS; do

		if [[ $element == $i ]]; then
			in=1
			break;
		fi
	done

	if [ $in == 0 ]; then
		echo Variable $i was not found...
	fi
	
done


for i in $ALL_CATEGORIES; do
	echo " - Testing $i for duplicates..."
	DUPLICATES=`$CONST_SCRIPT | egrep "^$i " | awk '{print $3}' | sort | uniq -d`

	for j in $DUPLICATES; do
		$CONST_SCRIPT | egrep "^$i " | egrep " $j"'$'
	done
 
done
