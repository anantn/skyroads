package main

import (
	"log"
	"os"

	"github.com/anantn/skyroads/levels"
)

func main() {
	f, err := os.Open(os.Args[1])
	if err != nil {
		log.Fatalln(err)
	}
	levels.Read(f)
}
