package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"flag"
	"fmt"
	"io"
	"os"
)

func main() {
	// Define command line arguments
	filePath := flag.String("file", "", "Path to the file")
	// Generate a key using the following command:
	// head -c 32 /dev/urandom | openssl enc > key.bin
	keyPath := flag.String("key", "", "Path to the symmetric key")
	operation := flag.String("operation", "", "Operation (encryption or decryption)")
	flag.Parse()

	// Check if required arguments are provided
	if *filePath == "" || *keyPath == "" || (*operation != "encryption" && *operation != "decryption") {
		fmt.Println("Usage: go run main.go -file <filepath> -key <keypath> -operation <encryption/decryption>")
		return
	}

	// Read the key from file
	key, err := os.ReadFile(*keyPath)
	if err != nil {
		fmt.Println("Error reading key:", err)
		return
	}
	fmt.Printf("Key: %s\n", key)

	// Create a new cipher block from the key
	block, err := aes.NewCipher(key)
	if err != nil {
		fmt.Println("Error creating cipher block:", err)
		return
	}

	if *operation == "encryption" {
		// Encrypt the file
		err := encryptFile(*filePath, block)
		if err != nil {
			fmt.Println("Error encrypting file:", err)
		} else {
			fmt.Println("File encrypted successfully.")
		}
	} else if *operation == "decryption" {
		// Decrypt the file
		err := decryptFile(*filePath, block)
		if err != nil {
			fmt.Println("Error decrypting file:", err)
		} else {
			fmt.Println("File decrypted successfully.")
		}
	}
}

func encryptFile(filePath string, block cipher.Block) error {
	// Read the file content
	plaintext, err := os.ReadFile(filePath)
	if err != nil {
		return err
	}

	// Generate a random nonce
	nonce := make([]byte, 12)
	_, err = io.ReadFull(rand.Reader, nonce)
	if err != nil {
		return err
	}

	// Create a new GCM cipher
	aesGCM, err := cipher.NewGCM(block)
	if err != nil {
		return err
	}

	// Encrypt the data
	ciphertext := aesGCM.Seal(nil, nonce, plaintext, nil)

	// Write the nonce and encrypted content to a file
	output := append(nonce, ciphertext...)

	// Write the encrypted content to a file
	err = os.WriteFile(filePath+".enc", output, 0644)
	if err != nil {
		return err
	}

	return nil
}

func decryptFile(filePath string, block cipher.Block) error {
	// Read the encrypted file content
	ciphertext, err := os.ReadFile(filePath)
	if err != nil {
		return err
	}

	// Extract the nonce
	nonce := ciphertext[:12]

	// Create a new GCM cipher
	aesGCM, err := cipher.NewGCM(block)
	if err != nil {
		return err
	}

	fmt.Printf("Nonce: %s\n", nonce)

	// Decrypt the data
	plaintext, err := aesGCM.Open(nil, nonce, ciphertext[12:], nil)
	if err != nil {
		return err
	}

	// Write the decrypted content to a file
	err = os.WriteFile(filePath+".dec", plaintext, 0644)
	if err != nil {
		return err
	}

	return nil
}