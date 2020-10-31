package main

import (
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"regexp"
	"sort"
	"time"

	"git.nerdworks.de/nerdworks/ptsd/5pkgs/i3status-tools/i3dbus"
	stripmd "github.com/writeas/go-strip-markdown"
)

type taskDue struct {
	Date string `json:"date"`
}

// https://developer.todoist.com/rest/v1/#get-active-tasks
type task struct {
	Id       int     `json:"id"`
	Order    int     `json:"order"`
	Content  string  `json:"content"`
	Priority int     `json:"priority"`
	Due      taskDue `json:"due"`
	Url      string  `json:"url"`
	I3State  string
}

func fetchCurrentTask(token string) (task, error) {
	todoistClient := http.Client{
		Timeout: time.Second * 5,
	}

	q := url.QueryEscape("(today|overdue)&(p1|p2)")
	req, err := http.NewRequest(http.MethodGet, "https://api.todoist.com/rest/v1/tasks?filter="+q, nil)
	if err != nil {
		return task{}, err
	}
	req.Header.Set("Authorization", "Bearer "+token)
	res, err := todoistClient.Do(req)
	if err != nil {
		return task{}, err
	}
	if res.Body != nil {
		defer res.Body.Close()
	}
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return task{}, err
	}

	var tasks []task
	err = json.Unmarshal(body, &tasks)
	if err != nil {
		return task{}, err
	}

	// Sort by Priority DESC, Due Date ASC, Order ASC
	sort.SliceStable(tasks, func(i, j int) bool {
		ti, erri := time.Parse("2006-01-02", tasks[i].Due.Date)
		tj, errj := time.Parse("2006-01-02", tasks[j].Due.Date)

		if erri != nil || errj != nil {
			return tasks[i].Priority > tasks[j].Priority || tasks[i].Order < tasks[j].Order
		}

		return tasks[i].Priority > tasks[j].Priority || ti.Unix() < tj.Unix() || tasks[i].Order < tasks[j].Order
	})

	if len(tasks) > 0 {
		currentTask := tasks[0]
		currentTask.Content = cleanupTaskContent(currentTask.Content)
		if currentTask.Priority == 4 {
			currentTask.I3State = "Critical"
		} else if tasks[0].Priority == 3 {
			currentTask.I3State = "Warning"
		} else {
			currentTask.I3State = "Info"
		}
		return currentTask, nil
	}

	return task{}, nil
}

func cleanupTaskContent(s string) string {
	s = stripmd.Strip(s)                                                          // strip markdown
	s = regexp.MustCompile(`[^0-9a-zA-Z :öäüÖÄÜß/\.\?]`).ReplaceAllString(s, " ") // strip unwanted characters
	s = regexp.MustCompile(`\s+`).ReplaceAllString(s, " ")                        // kill double spaces
	return s
}

func main() {
	token := flag.String("token", "", "api token for Todoist")
	flag.Parse()

	if *token == "" {
		log.Fatal("Please set token using -token")
	}

	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	for {
		<-ticker.C // blocking, waits for tick

		currentTask, err := fetchCurrentTask(*token)
		if err != nil {
			log.Printf("%+v", err)
		} else {
			err = i3dbus.SetStatus("TodoistStatus", currentTask.Content, "tasks", currentTask.I3State)
			if err != nil {
				log.Fatal(err)
			}
		}
	}
}
