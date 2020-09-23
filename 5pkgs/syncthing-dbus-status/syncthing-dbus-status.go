package main

import (
	"encoding/json"
	"encoding/xml"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"os/user"
	"time"

	"github.com/godbus/dbus/v5"
)

func dbusNotify(title string, message string) error {
	conn, err := dbus.SessionBus()
	if err != nil {
		return err
	}
	obj := conn.Object("org.freedesktop.Notifications", "/org/freedesktop/Notifications")
	call := obj.Call("org.freedesktop.Notifications.Notify", 0, "", uint32(0),
		"", title, message, []string{},
		map[string]dbus.Variant{}, int32(5000))
	if call.Err != nil {
		return call.Err
	}
	return nil
}

func dbusI3rsSetStatus(objName string, message string, icon string, state string) error {
	// see https://github.com/greshake/i3status-rust/blob/master/blocks.md#custom-dbus
	// for icons see https://github.com/greshake/i3status-rust/blob/master/src/icons.rs

	conn, err := dbus.SessionBus()
	if err != nil {
		return err
	}
	obj := conn.Object("i3.status.rs", dbus.ObjectPath("/"+objName))
	call := obj.Call("i3.status.rs.SetStatus", 0, message, icon, state)
	if call.Err != nil {
		return call.Err
	}
	return nil
}

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

func updateI3Status(rateOut int64, rateIn int64) error {
	objName := "SyncthingStatus"
	return dbusI3rsSetStatus(objName, fmt.Sprintf("ST ⬆%s/s ⬇%s/s", formatByteCountBinary(rateOut), formatByteCountBinary(rateIn)), "", "Idle")
}

func setStatus(oldStatus stStatus, newStatus stStatus) error {
	layout := "2006-01-02T15:04:05.999999999-07:00"
	tOld, errOld := time.Parse(layout, oldStatus.Total.At)
	tNew, errNew := time.Parse(layout, newStatus.Total.At)
	if errOld != nil || errNew != nil {
		err := updateI3Status(0, 0)
		if err != nil {
			return err
		}
		return nil
	}

	rateOut := calcRate(oldStatus.Total.OutBytesTotal, newStatus.Total.OutBytesTotal, tOld, tNew)
	rateIn := calcRate(oldStatus.Total.InBytesTotal, newStatus.Total.InBytesTotal, tOld, tNew)

	err := updateI3Status(rateOut, rateIn)
	if err != nil {
		return err
	}

	return nil
}

func main() {
	user, err := user.Current()
	if err != nil {
		panic(err)
	}
	apiKey, err := readSynchtingAPIKey(user.HomeDir + "/.config/syncthing/config.xml")
	if err != nil {
		panic(err)
	}
	fmt.Println(fmt.Sprintf("Syncthing API-Key: %s", apiKey))

	// flush with empty data on startup
	err = setStatus(stStatus{}, stStatus{})
	if err != nil {
		panic(err)
	}

	oldStatus, err := readSynchtingStatus(apiKey)
	if err != nil {
		panic(err)
	}

	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	for {
		<-ticker.C // blocking, waits for tick

		newStatus, err := readSynchtingStatus(apiKey)
		if err != nil {
			panic(err)
		}
		err = setStatus(oldStatus, newStatus)
		if err != nil {
			panic(err)
		}
		oldStatus = newStatus
	}
}
