package todoist

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
	"net/url"
	"regexp"
	"sort"
	"time"

	"barista.run/bar"
	"barista.run/base/value"
	"barista.run/outputs"
	"barista.run/timing"
	stripmd "github.com/writeas/go-strip-markdown"
)

type taskDue struct {
	Date string `json:"date"`
}

// https://developer.todoist.com/rest/v1/#get-active-tasks
type task struct {
	ID       int     `json:"id"`
	Order    int     `json:"order"`
	Content  string  `json:"content"`
	Priority int     `json:"priority"`
	Due      taskDue `json:"due"`
	URL      string  `json:"url"`
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

func (t *task) Info() Info {
	return Info{
		CurrentTaskContent:  t.Content,
		CurrentTaskPriority: t.Priority,
	}
}

// Info holds statistics about Todoist
type Info struct {
	CurrentTaskContent  string
	CurrentTaskPriority int
}

// Module represents a Todoist Barista Module
type Module struct {
	apiToken   string
	scheduler  *timing.Scheduler
	outputFunc value.Value // of func(Info) bar.Output
}

// New creates a Todoist module, fetching current tasks periodically
func New(apiToken string) *Module {
	m := &Module{
		apiToken:  apiToken,
		scheduler: timing.NewScheduler(),
	}
	m.RefreshInterval(1 * time.Minute)
	m.Output(func(info Info) bar.Output {
		return outputs.Text(info.CurrentTaskContent)
	})
	return m
}

// Stream starts the module.
func (m *Module) Stream(sink bar.Sink) {
	apiToken := m.apiToken
	ct, err := fetchCurrentTask(apiToken)
	if sink.Error(err) {
		return
	}
	outf := m.outputFunc.Get().(func(Info) bar.Output)
	nextOutputFunc, done := m.outputFunc.Subscribe()
	defer done()
	for {
		if sink.Error(err) {
			return
		}
		sink.Output(outf(ct.Info()))
		select {
		case <-nextOutputFunc:
			outf = m.outputFunc.Get().(func(Info) bar.Output)
		case <-m.scheduler.C:
			ct, err = fetchCurrentTask(apiToken)
		}
	}
}

// Output sets the output format for the module.
func (m *Module) Output(outputFunc func(Info) bar.Output) *Module {
	m.outputFunc.Set(outputFunc)
	return m
}

// RefreshInterval sets the interval between Todoist status updates.
func (m *Module) RefreshInterval(interval time.Duration) *Module {
	m.scheduler.Every(interval)
	return m
}
