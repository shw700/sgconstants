#!/bin/bash

CONST_SCRIPT=./getconsts.sh


cat << EOF
package constants

import "errors"


type ConstTableEntry struct {
        name string
        val uint
}

type ConstTable struct {
        name string
        entries []ConstTableEntry
}

var AllConstants = []ConstTable { 
EOF

#var AllConstants = []ConstTable { { name: "prefix", entries: []ConstTableEntry { { name: "a", val: 1 } } } }


ALL_CATEGORIES=`$CONST_SCRIPT | awk '{print $1}' | sort -u`

echo $PREAMBLE

FIRST=1

#for i in errno syscall syscall_name epoll readdir; do
for i in $ALL_CATEGORIES; do

	if [ $FIRST -eq 1 ]; then
		FIRST=0
		echo ""
	else
		echo ","
	fi

	echo "{ name: \"$i\", entries: []ConstTableEntry {"
	$CONST_SCRIPT | egrep "^$i " | awk 'BEGIN { first=1 } { if (first == 0) { printf ",\n" } else { first = 0 } printf "     { name: \""$2"\", val: "$3" }"; }'
	echo -n " }"; echo -n " }";
done

echo " }";

cat << EOF
func getConstantTableByName(category string) (ConstTable, error) {

        for i := 0; i < len(AllConstants); i++ {

                if (AllConstants[i].name == category) {
                        return AllConstants[i], nil
                }

        }

        empty := ConstTable { }
        return empty, errors.New("could not find specified category")
}


func getValByConstName(category string, name string) (uint, error) {
        table, err := getConstantTableByName(category)

        if err != nil {
                return 0, err
        }

        for i := 0; i < len(table.entries); i++ {

                if table.entries[i].name == name {
                        return table.entries[i].val, err
                }

        }

        return 0, errors.New("could not find constant in specified category")
}

func getConstByNo(category string, val uint) (string, error) {
        table, err := getConstantTableByName(category)

        if err != nil {
                return "", err
        }

        for i := 0; i < len(table.entries); i++ {

                if table.entries[i].val == val {
                        return table.entries[i].name, nil
                }

        }

        return "", errors.New("could not find value in specified category")
}
EOF
