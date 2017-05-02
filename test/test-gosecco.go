package main

import "fmt"

import sg_constants "github.com/shw700/constants"
import g_constants "github.com/twtiger/gosecco/constants"


func main() {
	fmt.Println("Scanning...")

//var AllConstantNumbers = make(map[int][]string)
//var AllErrorNumbers = make(map[int]string)

	for name, val := range g_constants.Syscalls {
//		fmt.Printf("SYSCALL: %s -> %v\n", name, val)
		sgval, exists := sg_constants.GetConstant(name)

		if !exists {
			fmt.Println("Warning : syscall value exists in gosecco but not in sgconstants: ", name)
		} else if sgval != uint32(val) {
			fmt.Printf("Error: syscall value for %s mismatches in gosecco and sgconstants: %v vs %v\n", name, val, sgval)
		}

	}

	for num, val := range g_constants.SyscallNumbers {
//		fmt.Printf("SYSCALL NO: %v -> %s\n", num, val)
		scname, err := sg_constants.GetConstByNo("syscall_name", uint(num))

		if err != nil {
			fmt.Println("Warning: syscall number exists in gosecco but not in sgconstants: ", num)
		} else if scname != val {
			fmt.Printf("Error: syscall number for %v mismatches in gosecco and sgconstants: %s vs %s\n", num, val, scname)
		}

	}

	for name, val := range g_constants.AllErrors {
//		fmt.Printf("ERROR: %s -> %v\n", name, val)
		sgval, exists := sg_constants.GetConstant(name)

		if !exists {
			fmt.Println("Warning: errno value exists in gosecco but not in sgconstants: ", name)
		} else if sgval != uint32(val) {
			fmt.Printf("Error: errno value for %s mismatches in gosecco and sgconstants: %v vs %v\n", name, val, sgval)
		}

	}

	for num, val := range g_constants.AllErrorNumbers {
//		fmt.Printf("ERROR NO: %v -> %s\n", num, val)
		errname, err := sg_constants.GetConstByNo("errno", uint(num))

		if err != nil {
			fmt.Println("Warning: error number exists in gosecco but not in sgconstants: ", num)
		} else if errname != val {
			fmt.Printf("Error: error number for %v mismatches in gosecco and sgconstants: %s vs %s\n", num, val, errname)
		}

	}


	for name, val := range g_constants.AllConstants {
//		fmt.Printf("CONSTANT: %s -> %v\n", name, val)
		sgval, exists := sg_constants.GetConstant(name)

		if !exists {
			fmt.Println("Warning: constant value exists in gosecco but not in sgconstants: ", name)
		} else if sgval != uint32(val) {
			fmt.Printf("Error: constant value for %s mismatches in gosecco and sgconstants: %v vs %v\n", name, val, sgval)
		}

	}

}
