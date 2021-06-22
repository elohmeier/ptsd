package main

import (
	"bytes"
	"fmt"
	"log"
	"os/exec"

	"go.i3wm.org/i3/v4"
)

func main() {
	i3.SocketPathHook = func() (string, error) {
		out, err := exec.Command("sway", "--get-socketpath").CombinedOutput()
		if err != nil {
			return "", fmt.Errorf("getting sway socketpath: %v (output: %s)", err, out)
		}
		return string(out), nil
	}

	i3.IsRunningHook = func() bool {
		out, err := exec.Command("pgrep", "-c", "sway\\$").CombinedOutput()
		if err != nil {
			log.Printf("sway running: %v (output: %s)", err, out)
		}
		return bytes.Compare(out, []byte("1")) == 0
	}

	// tree, err := i3.GetTree()
	// if err != nil {
	// 	log.Fatal(err)
	// }

	ws, err := i3.GetWorkspaces()
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("workspaces:\n %s\n", ws)
}
