package main

import (
	"context"
	"fmt"
	"os"
	"time"

	"cloud.google.com/go/firestore"
	speechpb "cloud.google.com/go/speech/apiv1/speechpb"
)

type FireStore struct {
	Client        *firestore.Client
	CTX           context.Context
	Database      string // ex: devices - t.Meta.Hub.Firestoredb
	SubCollection string // ex: messages
	DocRef        *firestore.DocumentRef
}

type TranscribeResult struct {
	Transcript string
	Confidence float32
	IsFinal    bool
}

func CreateTranscribeResult(sr *speechpb.StreamingRecognitionResult) *TranscribeResult {
	tr := TranscribeResult{
		Transcript: sr.Alternatives[0].Transcript,
		Confidence: sr.Alternatives[0].Confidence,
		IsFinal:    sr.GetIsFinal(),
	}
	return &tr
}

func NewFirebaseClient(dbName string) (*FireStore, error) {

	ctx := context.Background()
	project_id := os.Getenv("PROJECT_ID")

	fc, err := firestore.NewClient(ctx, project_id)
	if err != nil {
		return nil, err
	}

	return &FireStore{
		Client:   fc,
		CTX:      ctx,
		Database: dbName,
	}, nil
}

func (f *FireStore) Create(tr *TranscribeResult, collectionID string) error {

	dbref := f.Client.Collection(f.Database)
	if dbref == nil {
		return fmt.Errorf("Could not find database: %s", f.Database)
	}

	colref := dbref.Doc(collectionID)
	if colref == nil {
		return fmt.Errorf("Could not find subcollection: %s", collectionID)
	}

	subcolref := colref.Collection("mic1")
	if subcolref == nil {
		return fmt.Errorf("subcollection %s does not exist", f.SubCollection)
	}

	now := time.Now()
	doc, wr, err := subcolref.
		Add(f.CTX,
			map[string]interface{}{
				"confidence": tr.Confidence,
				"is_final":   false,
				"message":    tr.Transcript,
				"created_at": now.UTC().Format(time.RFC3339),
				"timestamp":  now.UTC().UnixNano() / int64(time.Millisecond), // Return miliseconds
			},
		)

	if err != nil {
		return err
	}

	// Setup document to store sentence group in
	f.DocRef = doc
	fmt.Println("doc is", doc)
	_ = wr
	return err
}

// func (f *FireStore) Update(tr *provider.TranscribeResult) error {

// 	now := time.Now()
// 	_, err := f.DocRef.Update(f.CTX, []firestore.Update{
// 		{Path: "confidence", Value: tr.Alternatives[0].Confidence},
// 		{Path: "is_final", Value: tr.IsFinal},
// 		{Path: "message", Value: tr.Alternatives[0].Transcript},
// 		{Path: "updated_at", Value: now.UTC().Format(time.RFC3339)},
// 	},
// 	)

// 	return err
// }
