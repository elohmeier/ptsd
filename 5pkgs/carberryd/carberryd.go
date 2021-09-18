package main

import (
	"log"

	"github.com/tarm/serial"
)

// import "github.com/pdf/kodirpc"

func main() {
	c := &serial.Config{Name: "/dev/ttyS0", Baud: 115200}
	s, err := serial.OpenPort(c)
	if err != nil {
		log.Fatal(err)
	}

	n, err := s.Write([]byte("AT"))
	if err != nil {
		log.Fatal(err)
	}

	buf := make([]byte, 128)
	n, err = s.Read(buf)
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("%q", buf[:n])
}
