package main

import (
	"fmt"
	"log"
	"os"
	"strconv"

	"github.com/anantn/skyroads/levels"
)

func main() {
	f, err := os.Open(os.Args[1])
	if err != nil {
		log.Fatalln(err)
	}
	parsed, err := levels.Read(f)
	if err != nil {
		log.Fatalln(err)
	}

	var script bool
	var levelNum int64 = -1
	if len(os.Args) > 2 {
		levelNum, err = strconv.ParseInt(os.Args[2], 10, 64)
		if err != nil {
			log.Fatalf("Invalid arg %s\n", os.Args[2])
		}
	}
	if len(os.Args) > 3 {
		script = true
	}

	if levelNum != -1 {
		if script {
			fmt.Printf("%s\n", parsed[int(levelNum)].GDScript())
		} else {
			fmt.Printf("%s\n", parsed[int(levelNum)])
		}
	} else {
		for i, l := range parsed {
			fmt.Printf("Level %d:\n%s\n\n", i, l)
		}
	}
}
