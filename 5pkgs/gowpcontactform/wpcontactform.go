package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hi %s", r.URL.Path[1:])
}

type FormResponse struct {
	Into           string `json:"into"`
	Status         string `json:"status"`
	Message        string `json:"message"`
	PostedDataHash string `json:"posted_data_hash"`
}

func form_handler(w http.ResponseWriter, r *http.Request) {
	res := FormResponse{"#wpcf7-f2330-p1948-o1", "mail_failed", "Es gab einen Fehler beim Versuch, Ihre Nachricht zu senden. Bitte versuchen Sie es später noch einmal.", "72d6926969c70d0b79ce18d777828d47"}

	js, err := json.Marshal(res)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(js)
}

func main() {
	http.HandleFunc("/", form_handler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
