package syncthing

import (
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"os/user"
	"time"

	"barista.run/bar"
	"barista.run/base/value"
	"barista.run/outputs"
	"barista.run/timing"
)

func readSynchtingAPIKey(path string) (string, error) {
	xmlFile, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer xmlFile.Close()

	byteValue, err := ioutil.ReadAll(xmlFile)
	if err != nil {
		return "", err
	}

	var cfg stConfiguration
	err = xml.Unmarshal(byteValue, &cfg)
	if err != nil {
		return "", err
	}

	return cfg.Gui.Apikey, nil
}

type stConfiguration struct {
	Gui stConfigurationGui `xml:"gui"`
}

type stConfigurationGui struct {
	Apikey string `xml:"apikey"`
}

type stStatus struct {
	Total stTotalStatus `json:"total"`
}

type stTotalStatus struct {
	At            string `json:"at"`
	InBytesTotal  int64  `json:"inBytesTotal"`
	OutBytesTotal int64  `json:"outBytesTotal"`
}

func readSynchtingStatus(apiKey string) (stStatus, error) {
	apiClient := http.Client{
		Timeout: time.Second * 2,
	}

	req, err := http.NewRequest(http.MethodGet, "http://localhost:8384/rest/system/connections", nil)
	if err != nil {
		return stStatus{}, err
	}
	req.Header.Set("X-API-Key", apiKey)

	res, err := apiClient.Do(req)
	if err != nil {
		return stStatus{}, err
	}

	if res.Body != nil {
		defer res.Body.Close()
	}
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return stStatus{}, err
	}

	var status stStatus
	err = json.Unmarshal(body, &status)
	if err != nil {
		return stStatus{}, err
	}
	return status, nil
}

func calcRate(iOld int64, iNew int64, tOld time.Time, tNew time.Time) int64 {
	return (iNew - iOld) / int64(tNew.Sub(tOld).Seconds())
}

func formatByteCountBinary(b int64) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%d B", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %ciB", float64(b)/float64(div), "KMGTPE"[exp])
}

func (stCur *stStatus) CalcInfo(stPrev stStatus) Info {
	layout := "2006-01-02T15:04:05.999999999-07:00"
	tOld, errOld := time.Parse(layout, stPrev.Total.At)
	tNew, errNew := time.Parse(layout, stCur.Total.At)
	if errOld != nil || errNew != nil {
		return Info{}
	}

	return Info{
		RateOut: calcRate(stPrev.Total.OutBytesTotal, stCur.Total.OutBytesTotal, tOld, tNew),
		RateIn:  calcRate(stPrev.Total.InBytesTotal, stCur.Total.InBytesTotal, tOld, tNew),
	}
}

// Info holds statistics about a Syncthing instance
type Info struct {
	RateIn  int64
	RateOut int64
}

// Module represents a Syncthing Barista module
type Module struct {
	apiKey     string
	scheduler  *timing.Scheduler
	outputFunc value.Value // of func(Info) bar.Output
}

// New creates a Syncthing module, that fetches the status
// periodically from a local Syncthing instance.
func New() *Module {
	apiKey := ""
	if user, err := user.Current(); err == nil {
		apiKey, _ = readSynchtingAPIKey(user.HomeDir + "/.config/syncthing/config.xml")
	}
	m := &Module{
		apiKey:    apiKey,
		scheduler: timing.NewScheduler(),
	}
	m.RefreshInterval(10 * time.Second)
	m.Output(func(info Info) bar.Output {
		return outputs.Textf("⬆%s/s ⬇%s/s", formatByteCountBinary(info.RateOut), formatByteCountBinary(info.RateIn))
	})
	return m
}

// Stream starts the module.
func (m *Module) Stream(sink bar.Sink) {
	apiKey := m.apiKey
	stprev := stStatus{}
	st, err := readSynchtingStatus(apiKey)
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
		sink.Output(outf(st.CalcInfo(stprev)))
		select {
		case <-nextOutputFunc:
			outf = m.outputFunc.Get().(func(Info) bar.Output)
		case <-m.scheduler.C:
			stprev = st
			st, err = readSynchtingStatus(apiKey)
		}
	}
}

// Output sets the output format for the module.
func (m *Module) Output(outputFunc func(Info) bar.Output) *Module {
	m.outputFunc.Set(outputFunc)
	return m
}

// RefreshInterval sets the interval between Syncthing status updates.
func (m *Module) RefreshInterval(interval time.Duration) *Module {
	m.scheduler.Every(interval)
	return m
}
