//go:generate protoc -I ../../proto -I . --go_out=../../grpc --go_opt=paths=source_relative --go-grpc_out=../../grpc --go-grpc_opt=paths=source_relative stt.proto

package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"
	stt "stt/grpc"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	path, _ := os.Getwd()
	print(path)
	audioFile := os.Getenv("AUDIO_PATH")
	serverAddr := os.Getenv("SERVER_ADDR")

	conn, err := grpc.Dial(serverAddr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("failed to connect: %v", err)

	}

	client := stt.NewSTTServiceClient(conn)
	defer conn.Close()

	if err != nil {
		println("ResolveTCPAddr failed:", err.Error())
		os.Exit(1)
	}
	session, err := client.Transcribe(context.Background())
	defer session.CloseSend()
	if err != nil {
		log.Fatalf("failed to initiate transcribe: %v", err)
	}

	f, err := os.Open(audioFile)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	go func() {
		buf := make([]byte, 1024)
		for {
			n, err := f.Read(buf)
			if n > 0 {
				err = session.Send(&stt.AudioBlock{
					Block: buf[:n],
				})
				if err != nil {
					log.Fatalf("Could not send audio: %v", err)
				}
			}
			if n == 0 {
				session.CloseSend()
				log.Printf("Audio finished.")
				return
			}
			if err != nil {
				log.Printf("Could not read from %s: %v", audioFile, err)
				continue
			}
		}
	}()

	for {
		result, err := session.Recv()
		if err == io.EOF {
			break
		}
		if err != nil {
			fmt.Println("Error in results: ", err)
			break
		}

		fmt.Println("result ", result)
	}

}
