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
)

// from https://github.com/writeas/go-strip-markdown/blob/master/strip.go

var (
	listLeadersReg = regexp.MustCompile(`(?m)^([\s\t]*)([\*\-\+]|\d\.)\s+`)

	headerReg = regexp.MustCompile(`\n={2,}`)
	strikeReg = regexp.MustCompile(`~~`)
	codeReg   = regexp.MustCompile("`{3}" + `.*\n`)

	htmlReg         = regexp.MustCompile("<(.*?)>")
	emphReg         = regexp.MustCompile(`\*\*([^*]+)\*\*`)
	emphReg2        = regexp.MustCompile(`\*([^*]+)\*`)
	emphReg3        = regexp.MustCompile(`__([^_]+)__`)
	emphReg4        = regexp.MustCompile(`_([^_]+)_`)
	setextHeaderReg = regexp.MustCompile(`^[=\-]{2,}\s*$`)
	footnotesReg    = regexp.MustCompile(`\[\^.+?\](\: .*?$)?`)
	footnotes2Reg   = regexp.MustCompile(`\s{0,2}\[.*?\]: .*?$`)
	imagesReg       = regexp.MustCompile(`\!\[(.*?)\]\s?[\[\(].*?[\]\)]`)
	linksReg        = regexp.MustCompile(`\[(.*?)\][\[\(].*?[\]\)]`)
	blockquoteReg   = regexp.MustCompile(`>\s*`)
	refLinkReg      = regexp.MustCompile(`^\s{1,2}\[(.*?)\]: (\S+)( ".*?")?\s*$`)
	atxHeaderReg    = regexp.MustCompile(`(?m)^\#{1,6}\s*([^#]+)\s*(\#{1,6})?$`)
	atxHeaderReg2   = regexp.MustCompile(`([\*_]{1,3})(\S.*?\S)?P1`)
	atxHeaderReg3   = regexp.MustCompile("(?m)(`{3,})" + `(.*?)?P1`)
	atxHeaderReg4   = regexp.MustCompile(`^-{3,}\s*$`)
	atxHeaderReg5   = regexp.MustCompile("`(.+?)`")
	atxHeaderReg6   = regexp.MustCompile(`\n{2,}`)
)

// Strip returns the given string sans any Markdown.
// Where necessary, elements are replaced with their best textual forms, so
// for example, hyperlinks are stripped of their URL and become only the link
// text, and images lose their URL and become only the alt text.
func StripMD(s string) string {
	res := s
	res = listLeadersReg.ReplaceAllString(res, "$1")

	res = headerReg.ReplaceAllString(res, "\n")
	res = strikeReg.ReplaceAllString(res, "")
	res = codeReg.ReplaceAllString(res, "")

	res = emphReg.ReplaceAllString(res, "$1")
	res = emphReg2.ReplaceAllString(res, "$1")
	res = emphReg3.ReplaceAllString(res, "$1")
	res = emphReg4.ReplaceAllString(res, "$1")
	res = htmlReg.ReplaceAllString(res, "$1")
	res = setextHeaderReg.ReplaceAllString(res, "")
	res = footnotesReg.ReplaceAllString(res, "")
	res = footnotes2Reg.ReplaceAllString(res, "")
	res = imagesReg.ReplaceAllString(res, "$1")
	res = linksReg.ReplaceAllString(res, "$1")
	res = blockquoteReg.ReplaceAllString(res, "  ")
	res = refLinkReg.ReplaceAllString(res, "")
	res = atxHeaderReg.ReplaceAllString(res, "$1")
	res = atxHeaderReg2.ReplaceAllString(res, "$2")
	res = atxHeaderReg3.ReplaceAllString(res, "$2")
	res = atxHeaderReg4.ReplaceAllString(res, "")
	res = atxHeaderReg5.ReplaceAllString(res, "$1")
	res = atxHeaderReg6.ReplaceAllString(res, "\n\n")
	return res
}

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
	s.Text = StripMD(s.Text)                                                                // strip markdown
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
