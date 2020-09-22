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

func notify(title string, message string) {
	conn, err := dbus.SessionBus()
	if err != nil {
		panic(err)
	}
	obj := conn.Object("org.freedesktop.Notifications", "/org/freedesktop/Notifications")
	call := obj.Call("org.freedesktop.Notifications.Notify", 0, "", uint32(0),
		"", title, message, []string{},
		map[string]dbus.Variant{}, int32(5000))
	if call.Err != nil {
		panic(call.Err)
	}
}

func set_i3rs_status(obj_name string, message string, icon string, state string) {
	conn, err := dbus.SessionBus()
	if err != nil {
		panic(err)
	}
	obj := conn.Object("i3.status.rs", dbus.ObjectPath("/"+obj_name))
	call := obj.Call("i3.status.rs.SetStatus", 0, message, icon, state)
	if call.Err != nil {
		panic(call.Err)
	}
}

func read_st_api_key(path string) (string, error) {
	xmlFile, err := os.Open(path)
	if err != nil {
		fmt.Println(err)
		return "", err
	}
	//fmt.Println("Successfully Opened " + path)
	defer xmlFile.Close()

	byteValue, err := ioutil.ReadAll(xmlFile)
	if err != nil {
		fmt.Println(err)
		return "", err
	}

	var cfg Configuration
	err = xml.Unmarshal(byteValue, &cfg)
	if err != nil {
		fmt.Println(err)
		return "", err
	}

	return cfg.Gui.Apikey, nil
}

type Configuration struct {
	Gui Gui `xml:"gui"`
}

type Gui struct {
	Apikey string `xml:"apikey"`
}

type Status struct {
	Total TotalStatus `json:"total"`
}

type TotalStatus struct {
	At            string `json:"at"`
	InBytesTotal  int    `json:"inBytesTotal"`
	OutBytesTotal int    `json:"outBytesTotal"`
}

func read_st_status(api_key string) (string, error) {

	apiClient := http.Client{
		Timeout: time.Second * 2,
	}

	req, _ := http.NewRequest(http.MethodGet, "http://localhost:8384/rest/system/connections", nil)
	req.Header.Set("X-API-Key", api_key)

	res, _ := apiClient.Do(req)

	if res.Body != nil {
		defer res.Body.Close()
	}
	body, _ := ioutil.ReadAll(res.Body)

	var status Status
	json.Unmarshal(body, &status)

	//fmt.Printf("%#v", status.Total.InBytesTotal)

	layout := "2006-01-02T15:04:05.999999999-07:00"
	t, _ := time.Parse(layout, status.Total.At)
	fmt.Println(t)

	return status.Total.At, nil
}

func main() {
	//notify("Hallo", "Welt")
	set_i3rs_status("SyncthingStatus", "huhuöäü", "music", "Critical")

	user, _ := user.Current()
	api_key, _ := read_st_api_key(user.HomeDir + "/.config/syncthing/config.xml")
	//fmt.Printf("%#v", api_key)

	status, _ := read_st_status(api_key)
	fmt.Printf("%#v", status)
}
