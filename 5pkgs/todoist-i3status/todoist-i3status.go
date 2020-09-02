package main

import (
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"
	"sort"
	"time"
)

// https://developer.todoist.com/rest/v1/#get-active-tasks
type Task struct {
	Id       int    `json:"id"`
	Order    int    `json:"order"`
	Content  string `json:"content"`
	Priority int    `json:"priority"`
	Url      string `json:"url"`
}

// https://github.com/greshake/i3status-rust/blob/master/blocks.md#custom
type Status struct {
	Icon  string `json:"icon"`
	State string `json:"state"` // Idle, Info, Good, Warning, Critical
	Text  string `json:"text"`
}

func main() {
	token := flag.String("token", "", "api token for Todoist")
	flag.Parse()

	if *token == "" {
		log.Fatal("Please set token using -token")
	}

	todoistClient := http.Client{
		Timeout: time.Second * 2,
	}

	q := url.QueryEscape("(today|overdue)&(p1|p2)")
	req, err := http.NewRequest(http.MethodGet, "https://api.todoist.com/rest/v1/tasks?filter="+q, nil)
	if err != nil {
		log.Fatal(err)
	}
	req.Header.Set("Authorization", "Bearer "+*token)
	res, getErr := todoistClient.Do(req)
	if getErr != nil {
		log.Fatal(getErr)
	}
	if res.Body != nil {
		defer res.Body.Close()
	}
	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		log.Fatal(readErr)
	}

	var tasks []Task
	json.Unmarshal(body, &tasks)

	sort.SliceStable(tasks, func(i, j int) bool {
		return tasks[i].Priority > tasks[j].Priority || tasks[i].Order < tasks[j].Order
	})

	i3status := Status{Icon: "tasks", State: "Idle", Text: ""}
	if len(tasks) > 0 {
		if tasks[0].Priority == 4 {
			i3status.State = "Critical"
		} else if tasks[0].Priority == 3 {
			i3status.State = "Warning"
		} else {
			i3status.State = "Info"
		}

		i3status.Text = tasks[0].Content
	}
	i3res, err := json.Marshal(i3status)
	if err != nil {
		log.Fatal(err)
	}
	//fmt.Printf("%#v", tasks)
	os.Stdout.Write(i3res)
}
