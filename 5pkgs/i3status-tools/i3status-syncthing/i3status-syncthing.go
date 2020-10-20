package main

import (
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/user"
	"time"

	"git.nerdworks.de/nerdworks/ptsd/5pkgs/i3status-tools/i3dbus"
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

func updateI3Status(objName string, rateOut int64, rateIn int64) error {
	state := "Idle"
	// 1kB threshold
	if (rateOut > 1024) || (rateIn > 1024) {
		state = "Info"
	}
	return i3dbus.SetStatus(objName, fmt.Sprintf("ST ⬆%s/s ⬇%s/s", formatByteCountBinary(rateOut), formatByteCountBinary(rateIn)), "", state)
}

func setStatus(objName string, oldStatus stStatus, newStatus stStatus) error {
	layout := "2006-01-02T15:04:05.999999999-07:00"
	tOld, errOld := time.Parse(layout, oldStatus.Total.At)
	tNew, errNew := time.Parse(layout, newStatus.Total.At)
	if errOld != nil || errNew != nil {
		err := updateI3Status(objName, 0, 0)
		if err != nil {
			return err
		}
		return nil
	}

	rateOut := calcRate(oldStatus.Total.OutBytesTotal, newStatus.Total.OutBytesTotal, tOld, tNew)
	rateIn := calcRate(oldStatus.Total.InBytesTotal, newStatus.Total.InBytesTotal, tOld, tNew)

	err := updateI3Status(objName, rateOut, rateIn)
	if err != nil {
		return err
	}

	return nil
}

func main() {
	objName := "SyncthingStatus"

	user, err := user.Current()
	if err != nil {
		i3dbus.SetStatus(objName, "ST n/a", "", "Idle")
		log.Fatal(err)
	}
	apiKey, err := readSynchtingAPIKey(user.HomeDir + "/.config/syncthing/config.xml")
	if err != nil {
		i3dbus.SetStatus(objName, "ST n/a", "", "Idle")
		log.Fatal(err)
	}
	fmt.Println(fmt.Sprintf("Syncthing API-Key: %s", apiKey))

	// flush with empty data on startup
	err = setStatus(objName, stStatus{}, stStatus{})
	if err != nil {
		log.Fatal(err)
	}

	oldStatus, err := readSynchtingStatus(apiKey)
	if err != nil {
		log.Fatal(err)
	}

	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	for {
		<-ticker.C // blocking, waits for tick

		newStatus, err := readSynchtingStatus(apiKey)
		if err != nil {
			log.Fatal(err)
		}
		err = setStatus(objName, oldStatus, newStatus)
		if err != nil {
			log.Fatal(err)
		}
		oldStatus = newStatus
	}
}
