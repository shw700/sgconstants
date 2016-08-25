package main

import "os"
import "fmt"
import "flag"
import "strings"
import "strconv"

import "github.com/shw700/constants"

var progName = ""


func usage() {
	fmt.Fprintln(os.Stderr, "Usage: "+progName+" [-c category] <-m> <val>     where")
	fmt.Fprintln(os.Stderr, "  -c / -category:   select a category (\"all\" by default),")
	fmt.Fprintln(os.Stderr, "  -h / -help:       display this help message,")
}

func main() {
	progName = os.Args[0]
	var findVal = ""
	var findValI uint64 = 0
	var searchVal = false

	var category = flag.String("category", "all", "Specify category for constant lookup")
	flag.StringVar(category, "c", "all", "Specify category for constant lookup")
	var guessMask = flag.Bool("mask", false, "Guess value as mask")
	flag.BoolVar(guessMask, "m", false, "Guess value as mask")

	flag.Usage = usage
	flag.Parse()

	var catName = strings.ToLower(*category)
	var foundCat = false

	var args = flag.Args()

	if len(args) > 1 {
		flag.Usage()
		os.Exit(-1)
	} else if len(args) == 1 {
		findVal = args[0]

		if (args[0][0] >= '0') && (args[0][0] <= '9') {
			var base = 10

			if (len(findVal) > 2) && ((findVal[0:2] == "0x") || (findVal[0:2] == "0X")) {
				findVal = findVal[2:]
				base = 16
			} else if findVal[0:1] == "0" {
				base = 8
			}

			fI, err := strconv.ParseUint(findVal, base, 64)

			if err != nil {
				fmt.Println(os.Stderr, "Error converting value: ", err)
				os.Exit(-1)
			}

			findValI = fI
			searchVal = true
		}

	}

	if *guessMask && !searchVal {
		fmt.Fprintln(os.Stderr, "Error: -m can only be used with a numerical lookup value.")
		os.Exit(-1)
	}

	var nFound = 0
	var nTotal = 0

	for i := 0; i < len(constants.AllConstants); i++ {

		if catName == "all" || catName == constants.AllConstants[i].Name {
			var hdrName = fmt.Sprintf("-%s [%d values]", constants.AllConstants[i].Name,
				len(constants.AllConstants[i].Entries))
			nTotal += len(constants.AllConstants[i].Entries);
			foundCat = true

			var bitRep = ""
			var bitVal = uint64(0)

			var longestNameLen = 0

			for j := 0; j < len(constants.AllConstants[i].Entries); j++ {
				var tlen = len(constants.AllConstants[i].Entries[j].Name)

				if *guessMask {
					var curName = constants.AllConstants[i].Entries[j].Name
					var curVal = uint64(constants.AllConstants[i].Entries[j].Val)

					if searchVal && ((findValI & curVal) == curVal) {
						bitVal |= curVal

						if bitRep != "" {
							bitRep += "|"
						}

						bitRep += curName
					}

				}

				if (searchVal && (uint64(constants.AllConstants[i].Entries[j].Val) == findValI)) ||
					(len(findVal) == 0) || (findVal == constants.AllConstants[i].Entries[j].Name) {

					if (tlen > longestNameLen) {
						longestNameLen = tlen
					}

				}

			}

			if (*guessMask) {

				if findValI != bitVal {
					var valLeft = findValI & ^(bitVal)

					if bitRep != "" {
						bitRep += "|"
					}

					bitRep += strconv.Itoa(int(valLeft))
				}

				fmt.Println(hdrName)
				fmt.Printf("  %s    = %d (0x%x)\n", bitRep, bitVal, bitVal)
				nFound++
				continue
			}

			fmtStr := "  %-" + strconv.Itoa(longestNameLen) + "s    = %d (0x%x)\n"
			var starting = true

			for j := 0; j < len(constants.AllConstants[i].Entries); j++ {

				if (searchVal && (uint64(constants.AllConstants[i].Entries[j].Val) == findValI)) ||
					(len(findVal) == 0) || (findVal == constants.AllConstants[i].Entries[j].Name) {

					if (starting) {
						fmt.Println(hdrName)
						starting = false
					}

					fmt.Printf(fmtStr, constants.AllConstants[i].Entries[j].Name,
						constants.AllConstants[i].Entries[j].Val, constants.AllConstants[i].Entries[j].Val)
					nFound++
				}

			}

		} else {
			continue
		}


	}

	if !foundCat {
		fmt.Printf("No categories matching \"%s\" was found.\n", catName)
		os.Exit(-1)
	} else {
		fmt.Printf("\n%d matching symbols found out of %d total.\n", nFound, nTotal)
	}

}
