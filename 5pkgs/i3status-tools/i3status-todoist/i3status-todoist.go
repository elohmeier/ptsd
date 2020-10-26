package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"
	"regexp"
	"sort"
	"time"

	stripmd "github.com/writeas/go-strip-markdown"
)

type TaskDue struct {
	Date string `json:"date"`
}

// https://developer.todoist.com/rest/v1/#get-active-tasks
type Task struct {
	Id       int     `json:"id"`
	Order    int     `json:"order"`
	Content  string  `json:"content"`
	Priority int     `json:"priority"`
	Due      TaskDue `json:"due"`
	Url      string  `json:"url"`
}

// https://github.com/greshake/i3status-rust/blob/master/blocks.md#custom
type Status struct {
	Icon  string `json:"icon"`
	State string `json:"state"` // Idle, Info, Good, Warning, Critical
	Text  string `json:"text"`
}

func printStatus(s Status) error {
	s.Text = stripmd.Strip(s.Text)                                                          // strip markdown
	s.Text = regexp.MustCompile(`[^0-9a-zA-Z :öäüÖÄÜß/\.\?]`).ReplaceAllString(s.Text, " ") // strip unwanted characters
	s.Text = regexp.MustCompile(`\s+`).ReplaceAllString(s.Text, " ")                        // kill double spaces

	res, err := json.Marshal(s)
	if err == nil {
		os.Stdout.Write(res)
	}
	return nil
}

func printError(v ...interface{}) {
	printStatus(Status{Icon: "tasks", State: "Idle", Text: fmt.Sprint(v...)})
}

func main() {
	token := flag.String("token", "", "api token for Todoist")
	flag.Parse()

	if *token == "" {
		log.Fatal("Please set token using -token")
	}

	todoistClient := http.Client{
		Timeout: time.Second * 5,
	}

	q := url.QueryEscape("(today|overdue)&(p1|p2)")
	req, err := http.NewRequest(http.MethodGet, "https://api.todoist.com/rest/v1/tasks?filter="+q, nil)
	if err != nil {
		printError("req setup failed")
		log.Fatal(err)
	}
	req.Header.Set("Authorization", "Bearer "+*token)
	res, getErr := todoistClient.Do(req)
	if getErr != nil {
		printError("")
		log.Fatal(getErr)
	}
	if res.Body != nil {
		defer res.Body.Close()
	}
	body, readErr := ioutil.ReadAll(res.Body)
	if readErr != nil {
		printError("")
		log.Fatal(readErr)
	}

	var tasks []Task
	json.Unmarshal(body, &tasks)

	// Sort by Priority DESC, Due Date ASC, Order ASC
	sort.SliceStable(tasks, func(i, j int) bool {
		ti, erri := time.Parse("2006-01-02", tasks[i].Due.Date)
		tj, errj := time.Parse("2006-01-02", tasks[j].Due.Date)

		if erri != nil || errj != nil {
			return tasks[i].Priority > tasks[j].Priority || tasks[i].Order < tasks[j].Order
		}

		return tasks[i].Priority > tasks[j].Priority || ti.Unix() < tj.Unix() || tasks[i].Order < tasks[j].Order
	})

	//fmt.Printf("%#v", tasks[0])

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
	err = printStatus(i3status)
	if err != nil {
		log.Fatal(err)
	}
}