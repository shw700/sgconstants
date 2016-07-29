#!/bin/bash

CONST_SCRIPT=./getconsts.sh


cat << EOF
package constants

import "errors"


type ConstTableEntry struct {
        Name string
        Val uint
}

type ConstTable struct {
        Name string
        entries []ConstTableEntry
}

var AllConstants = []ConstTable { 
EOF

#var AllConstants = []ConstTable { { Name: "prefix", entries: []ConstTableEntry { { Name: "a", Val: 1 } } } }


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

	echo "{ Name: \"$i\", entries: []ConstTableEntry {"
	$CONST_SCRIPT | egrep "^$i " | awk 'BEGIN { first=1 } { if (first == 0) { printf ",\n" } else { first = 0 } printf "     { Name: \""$2"\", Val: "$3" }"; }'
	echo -n " }"; echo -n " }";
done

echo " }";

cat << EOF


func GetConstantTableByName(category string) (ConstTable, error) {

        for i := 0; i < len(AllConstants); i++ {

                if (AllConstants[i].Name == category) {
                        return AllConstants[i], nil
                }

        }

        empty := ConstTable { }
        return empty, errors.New("could not find specified category")
}


func getValByConstName(category string, name string) (uint, error) {
        table, err := GetConstantTableByName(category)

        if err != nil {
                return 0, err
        }

        for i := 0; i < len(table.entries); i++ {

                if table.entries[i].Name == name {
                        return table.entries[i].Val, err
                }

        }

        return 0, errors.New("could not find constant in specified category")
}

func GetConstByNo(category string, val uint) (string, error) {
        table, err := GetConstantTableByName(category)

        if err != nil {
                return "", err
        }

        for i := 0; i < len(table.entries); i++ {

                if table.entries[i].Val == val {
                        return table.entries[i].Name, nil
                }

        }

        return "", errors.New("could not find value in specified category")
}

func GetConstByBitmask(category string, val uint) (string, error) {
        table, err := GetConstantTableByName(category)

        if err != nil {
                return "", err
        }

	constName := ""
	first := 1

        for i := 0; i < len(table.entries); i++ {

		// Just return if we have a straight up match.
		if table.entries[i].Val == val {
			return table.entries[i].Name, nil
		}

		if table.entries[i].Val != 0 && (table.entries[i].Val & val == table.entries[i].Val) {

			if first == 0 {
				constName += "|"
			} else {
				first = 0
			}

			constName += table.entries[i].Name
                }

        }

        return constName, nil
}

EOF
