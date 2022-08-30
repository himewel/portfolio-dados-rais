
// Sample helloworld-shell is a Cloud Run shell-script-as-a-service.
package main

import (
	"encoding/json"
	"log"
	"io/ioutil"
	"net/http"
	"os"
	"os/exec"
)

type PubSubMessage struct {
    Message struct {
        Data []byte `json:"data"`
        ID string `json:"id"`
    } `json:"message"`
    Subscription string `json:"subscription"`
}

type PubSubMessageData struct {
	System string `json:"system"`
	Source string `json:"source"`
	Destination string `json:"destination"`
}

func main() {
	http.HandleFunc("/", scriptHandler)

	// Determine port for HTTP service.
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("Defaulting to port %s", port)
	}

	// Start HTTP server.
	log.Printf("Listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func scriptHandler(w http.ResponseWriter, r *http.Request) {
	var message PubSubMessage
	var data PubSubMessageData

	body, err := ioutil.ReadAll(r.Body)
    if err != nil {
	    log.Printf("ioutil.ReadAll: %v", err)
	    http.Error(w, "Bad Request", http.StatusBadRequest)
	    return
    }
    if err := json.Unmarshal(body, &message); err != nil {
        log.Printf("json.Unmarshal: %v", err)
        http.Error(w, "Bad Request", http.StatusBadRequest)
        return
    }
	if err := json.Unmarshal(message.Message.Data, &data); err != nil {
		log.Printf("json.Unmarshal: %v", err)
		http.Error(w, "Bad Request", http.StatusBadRequest)
		return
	}

	os.Setenv("SYSTEM", data.System)
	os.Setenv("SOURCE", data.Source)
	os.Setenv("DESTINATION", data.Destination)

	cmd := exec.CommandContext(r.Context(), "/bin/bash", "script.sh")
	cmd.Stderr = os.Stderr
	out, err := cmd.Output()
	if err != nil {
		w.WriteHeader(500)
	}
	w.Write(out)
}
