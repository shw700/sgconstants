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
        Entries []ConstTableEntry
}

var AllConstants = []ConstTable { 
EOF

#var AllConstants = []ConstTable { { Name: "prefix", Entries: []ConstTableEntry { { Name: "a", Val: 1 } } } }


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

	echo "{ Name: \"$i\", Entries: []ConstTableEntry {"
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

        for i := 0; i < len(table.Entries); i++ {

                if table.Entries[i].Name == name {
                        return table.Entries[i].Val, err
                }

        }

        return 0, errors.New("could not find constant in specified category")
}

func GetConstByNo(category string, val uint) (string, error) {
        table, err := GetConstantTableByName(category)

        if err != nil {
                return "", err
        }

        for i := 0; i < len(table.Entries); i++ {

                if table.Entries[i].Val == val {
                        return table.Entries[i].Name, nil
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

        for i := 0; i < len(table.Entries); i++ {

		// Just return if we have a straight up match.
		if table.Entries[i].Val == val {
			return table.Entries[i].Name, nil
		}

		if table.Entries[i].Val != 0 && (table.Entries[i].Val & val == table.Entries[i].Val) {

			if first == 0 {
				constName += "|"
			} else {
				first = 0
			}

			constName += table.Entries[i].Name
                }

        }

        return constName, nil
}

// Functions for gosecco compatibility

func GetSyscall(name string) (uint32, bool) {
        res, ok := getValByConstName("syscall_name", name)
        return uint32(res), ok==nil
}

func GetError(name string) (uint32, bool) {
        res, ok := getValByConstName("errno", name)
        return uint32(res), ok==nil
}

func GetConstant(name string) (uint32, bool) {

        for t := 0; t < len(AllConstants); t++ {
                table := AllConstants[t]

                for i := 0; i < len(table.Entries); i++ {

                        if table.Entries[i].Name == name {
                                return uint32(table.Entries[i].Val), true
                        }

                }

        }

        return 0, false
}


EOF
