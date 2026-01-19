package main

import (
	"fmt"
	"log"

	"golang.org/x/crypto/bcrypt"
)

func main() {
	password := "admin123"
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		log.Fatalf("Failed to generate hash: %v", err)
	}
	fmt.Printf("Bcrypt hash for '%s':\n%s\n", password, string(hash))
}
