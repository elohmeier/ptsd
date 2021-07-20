package main

import (
	"crypto/tls"
	"encoding/base64"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"net/smtp"
	"strings"
)

type FormResponse struct {
	Into           string `json:"into"`
	Status         string `json:"status"`
	Message        string `json:"message"`
	PostedDataHash string `json:"posted_data_hash"`
}

func send_mail(addr string, smtphost string, rcpt string, txt string) error {
	tlsconfig := &tls.Config{
		InsecureSkipVerify: false,
		ServerName:         smtphost,
	}

	conn, err := net.Dial("tcp", addr)
	if err != nil {
		return err
	}

	c, err := smtp.NewClient(conn, smtphost)
	if err != nil {
		return err
	}
	defer c.Close()

	if err = c.Hello(smtphost); err != nil {
		return err
	}

	if err = c.StartTLS(tlsconfig); err != nil {
		return err
	}

	if err = c.Mail("donotreply@fraam.de"); err != nil {
		return err
	}
	if err = c.Rcpt(rcpt); err != nil {
		return err
	}
	w, err := c.Data()
	if err != nil {
		return err
	}

	msg := "To: " + rcpt + "\r\n" +
		"From: fraam.de <donotreply@fraam.de>\r\n" +
		"Subject: Kontaktformular\r\n" +
		"MIME-Version: 1.0\r\n" +
		"Content-Type: text/plain; charset=\"utf-8\"\r\n" +
		"Content-Transfer-Encoding: base64\r\n" +
		"\r\n" + base64.StdEncoding.EncodeToString([]byte(txt)) + "\r\n"

	_, err = w.Write([]byte(msg))
	if err != nil {
		return err
	}

	c.Quit()
	return nil
}

func gen_form_handler(addr string, smtphost string, rcpt string) http.HandlerFunc {
	fn := func(w http.ResponseWriter, r *http.Request) {
		switch r.Method {
		case http.MethodPost:
			{

				err := r.ParseMultipartForm(1024)
				if err != nil {
					log.Println(err)
					http.Error(w, err.Error(), http.StatusBadRequest)
					return
				}

				txt := ""
				for key, value := range r.Form {
					if !strings.HasPrefix(key, "_") {
						txt += fmt.Sprintf("%s = %s\n", key, value)
					}
				}

				if txt == "" {
					log.Println("no text submitted")
					http.Error(w, "no text submitted", http.StatusBadRequest)
					return
				}

				res := FormResponse{}

				if err = send_mail(addr, smtphost, rcpt, txt); err != nil {
					log.Println(err)
					res = FormResponse{r.FormValue("_wpcf7_unit_tag"), "mail_failed", "Es gab einen Fehler beim Versuch, Ihre Nachricht zu senden. Bitte versuchen Sie es später noch einmal.", "72d6926969c70d0b79ce18d777828d47"}
				} else {
					log.Printf("sent mail to %s\n", rcpt)
					res = FormResponse{r.FormValue("_wpcf7_unit_tag"), "mail_sent", "Vielen Dank für Ihr Interesse. Sie erhalten in Kürze Post von uns.", "72d6926969c70d0b79ce18d777828d47"}
				}

				js, err := json.Marshal(res)
				if err != nil {
					log.Println(err)
					http.Error(w, err.Error(), http.StatusInternalServerError)
					return
				}

				w.Header().Set("Content-Type", "application/json")
				w.Write(js)
			}
		default:
			{
				w.Header().Set("Content-Type", "application/json")
				w.Write([]byte("[]"))
			}
		}
	}
	return fn
}

func main() {
	listen := flag.String("listen", ":8081", "listen address & port")
	addr := flag.String("addr", "smtp-relay.gmail.com:587", "smtp host address & port")
	smtphost := flag.String("smtphost", "smtp-relay.gmail.com", "smtp host name")
	rcpt := flag.String("rcpt", "enno.richter@fraam.de", "e-mail recipient")
	flag.Parse()

	http.HandleFunc("/", gen_form_handler(*addr, *smtphost, *rcpt))
	log.Printf("starting listener on %s", *listen)
	log.Fatal(http.ListenAndServe(*listen, nil))
}
