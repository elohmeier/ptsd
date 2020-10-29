package wlan

import (
	"net"
	"os/exec"
	"strconv"
	"strings"

	"barista.run/bar"
	"barista.run/base/value"
	"barista.run/base/watchers/netlink"
	l "barista.run/logging"
	"barista.run/outputs"
	"github.com/martinlindhe/unit"
)

// Info represents the wireless card status.
type Info struct {
	Name           string
	State          netlink.OperState
	IPs            []net.IP
	SSID           string
	AccessPointMAC string
	Channel        int
	Frequency      unit.Frequency
}

// Connecting returns true if a connection is in progress.
func (i Info) Connecting() bool {
	return i.State == netlink.Dormant
}

// Connected returns true if connected to a wireless network.
func (i Info) Connected() bool {
	return i.State == netlink.Up
}

// Enabled returns true if the wireless card is enabled.
func (i Info) Enabled() bool {
	return i.State > netlink.NotPresent
}

// Module represents a wlan bar module.
type Module struct {
	intf       string
	outputFunc value.Value // of func(Info) bar.Output
}

// Named constructs an instance of the wlan module for the specified interface.
func Named(iface string) *Module {
	m := &Module{intf: iface}
	l.Label(m, iface)
	l.Register(m, "outputFunc")
	// Default output is just the SSID when connected.
	m.Output(func(i Info) bar.Output {
		if i.Connected() {
			return outputs.Text(i.SSID)
		}
		return nil
	})
	return m
}

// Any constructs an instance of the wlan module that uses any available
// wireless interface, choosing the 'best' state from all available.
func Any() *Module {
	return Named("")
}

// Output configures a module to display the output of a user-defined function.
func (m *Module) Output(outputFunc func(Info) bar.Output) *Module {
	m.outputFunc.Set(outputFunc)
	return m
}

// Stream starts the module.
func (m *Module) Stream(s bar.Sink) {
	outputFunc := m.outputFunc.Get().(func(Info) bar.Output)
	nextOutputFunc, done := m.outputFunc.Subscribe()
	defer done()

	var linkSub *netlink.Subscription
	if m.intf == "" {
		linkSub = netlink.WithPrefix("wl")
	} else {
		linkSub = netlink.ByName(m.intf)
	}
	defer linkSub.Unsubscribe()

	info := handleUpdate(linkSub.Get())
	for {
		s.Output(outputFunc(info))
		select {
		case <-linkSub.C:
			info = handleUpdate(linkSub.Get())
		case <-nextOutputFunc:
			outputFunc = m.outputFunc.Get().(func(Info) bar.Output)
		}
	}
}

func handleUpdate(link netlink.Link) Info {
	info := Info{
		Name:  link.Name,
		State: link.State,
		IPs:   link.IPs,
	}
	fillWifiInfo(&info)
	return info
}

func fillWifiInfo(info *Info) {
	ssid, err := iwgetid(info.Name, "-r")
	if err != nil {
		return
	}
	info.SSID = ssid
	info.AccessPointMAC, _ = iwgetid(info.Name, "-a")
	ch, _ := iwgetid(info.Name, "-c")
	info.Channel, _ = strconv.Atoi(ch)
	freq, _ := iwgetid(info.Name, "-f")
	freqFloat, _ := strconv.ParseFloat(freq, 64)
	info.Frequency = unit.Frequency(freqFloat) * unit.Hertz
}

var iwgetid = func(intf, flag string) (string, error) {
	out, err := exec.Command("iwgetid", intf, "-r", flag).Output()
	return strings.TrimSpace(string(out)), err
}
