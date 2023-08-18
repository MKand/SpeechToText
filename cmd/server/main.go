//go:generate protoc -I ../../proto -I . --go_out=../../grpc --go_opt=paths=source_relative --go-grpc_out=../../grpc --go-grpc_opt=paths=source_relative stt.proto

package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"strconv"
	"time"

	stt "stt/grpc"

	"google.golang.org/grpc"

	speech "cloud.google.com/go/speech/apiv1"
	speechpb "cloud.google.com/go/speech/apiv1/speechpb"
)

// https://github.com/GoogleCloudPlatform/golang-samples/blob/3a844641ffa93bcbec84015fe1f1c13dfce5ecaf/speech/livecaption_from_file/livecaption_from_file.go

type STTServer struct {
	stt.UnimplementedSTTServiceServer
	dbClient *FireStore
}

func (s *STTServer) Transcribe(server stt.STTService_TranscribeServer) error {

	fmt.Println("Accepted connection")
	ctx := context.Background()
	client, err := speech.NewClient(ctx)
	if err != nil {
		fmt.Println(err)
	}
	stream, err := client.StreamingRecognize(ctx)
	if err != nil {
		fmt.Println(err)
	}
	sendConfigMessage(stream)
	go func() {
		for {
			block, err := server.Recv()
			if err != nil {
				if err == io.EOF {
					break
				} else {
					log.Printf("failed to receive: %v", err)
					return
				}
			}
			if err := stream.Send(&speechpb.StreamingRecognizeRequest{
				StreamingRequest: &speechpb.StreamingRecognizeRequest_AudioContent{
					AudioContent: block.GetBlock(),
				},
			}); err != nil {
				fmt.Println("Could not send audio: ", err)
			}

		}
	}()
	for {
		resp, err := stream.Recv()
		requestId := resp.RequestId
		if err == io.EOF {
			break
		}
		if err != nil {
			fmt.Println("Cannot stream results: ", err)
			break
		}
		if err := resp.Error; err != nil {
			fmt.Println("Could not recognize: ", err)
			break
		}
		for _, result := range resp.Results {
			tr := CreateTranscribeResult(result)
			err := s.dbClient.Create(tr, strconv.FormatInt(requestId, 10))
			if err != nil {
				fmt.Println(err)
			}
			server.Send(&stt.TranscribeResult{
				Text:       tr.Transcript,
				IsFinal:    tr.IsFinal,
				Confidence: tr.Confidence,
			})
		}
	}
	return nil
}
func newServer(dbClient *FireStore) *STTServer {
	return &STTServer{
		dbClient: dbClient,
	}
}

func main() {
	fmt.Println("Starting server")

	port := os.Getenv("PORT")

	dbName := os.Getenv("DBNAME")
	firestoreClient, err := NewFirebaseClient(dbName)
	if err != nil {
		panic(err)
	}
	startServer(port, firestoreClient)
}

func startServer(port string, dbClient *FireStore) {
	ln, err := net.Listen("tcp", ":"+port)

	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	grpcServer := grpc.NewServer()
	stt.RegisterSTTServiceServer(grpcServer, newServer(dbClient))
	grpcServer.Serve(ln)
	defer ln.Close()
}

func sendConfigMessage(stream speechpb.Speech_StreamingRecognizeClient) {
	audioRate, _ := strconv.Atoi(os.Getenv("AUDIO_RATE"))
	language := os.Getenv("LANGUAGE_CODE")
	if err := stream.Send(&speechpb.StreamingRecognizeRequest{
		StreamingRequest: &speechpb.StreamingRecognizeRequest_StreamingConfig{
			StreamingConfig: &speechpb.StreamingRecognitionConfig{
				Config: &speechpb.RecognitionConfig{
					Encoding:        speechpb.RecognitionConfig_LINEAR16,
					SampleRateHertz: int32(audioRate),
					LanguageCode:    language,
				},
			},
		},
	}); err != nil {
		fmt.Println(err)
	}
}

func handleConnection(conn net.Conn, dbClient *FireStore) {
	fmt.Println("Accecpting connection", &conn)
	ctx := context.Background()
	client, err := speech.NewClient(ctx)
	if err != nil {
		fmt.Println(err)
	}
	stream, err := client.StreamingRecognize(ctx)
	if err != nil {
		fmt.Println(err)
	}
	sendConfigMessage(stream)
	go transcribe(conn, stream)
	go writeResult(dbClient, conn, stream)
}

func writeResult(dbClient *FireStore, conn net.Conn, stream speechpb.Speech_StreamingRecognizeClient) {
	for {
		resp, err := stream.Recv()
		requestId := resp.RequestId
		if err == io.EOF {
			fmt.Println(err)
			break
		}
		if err != nil {
			fmt.Println("Cannot stream results: ", err)
			break
		}
		if err := resp.Error; err != nil {
			fmt.Println("Could not recognize: ", err)
			break
		}
		for _, result := range resp.Results {
			tr := CreateTranscribeResult(result)
			err := dbClient.Create(tr, strconv.FormatInt(requestId, 10))
			if err != nil {
				fmt.Println(err)
			}
		}
	}
	conn.Close()
}

func transcribe(conn net.Conn, stream speechpb.Speech_StreamingRecognizeClient) {
	data := make([]byte, 1024)
loop:
	for {
		err := conn.SetReadDeadline(time.Now().Add(time.Second))
		n, err := conn.Read(data)
		if n > 0 {
			if err := stream.Send(&speechpb.StreamingRecognizeRequest{
				StreamingRequest: &speechpb.StreamingRecognizeRequest_AudioContent{
					AudioContent: data[:n],
				},
			}); err != nil {
				fmt.Println("Could not send audio: ", err)
			}
		}
		if err == io.EOF {
			break loop
		}
		if err != nil && err != io.EOF {
			panic(err)
		}
	}
}
