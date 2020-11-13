package main

import (
	"fmt"
	"log"
	"os/exec"
	"os/user"
	"path/filepath"
	"strings"
	"time"

	"barista.run"
	"barista.run/bar"
	"barista.run/base/click"
	"barista.run/base/watchers/netlink"
	"barista.run/colors"
	"barista.run/format"
	"barista.run/group/modal"
	"barista.run/modules/battery"
	"barista.run/modules/clock"
	"barista.run/modules/cputemp"
	"barista.run/modules/diskio"
	"barista.run/modules/diskspace"
	"barista.run/modules/meminfo"
	"barista.run/modules/meta/split"
	"barista.run/modules/netinfo"
	"barista.run/modules/netspeed"
	"barista.run/modules/sysinfo"
	"barista.run/outputs"
	"barista.run/pango"
	"git.nerdworks.de/nerdworks/ptsd/5pkgs/nwi3status/fonts"
	"git.nerdworks.de/nerdworks/ptsd/5pkgs/nwi3status/modules/syncthing"
	"git.nerdworks.de/nerdworks/ptsd/5pkgs/nwi3status/modules/todoist"
	"git.nerdworks.de/nerdworks/ptsd/5pkgs/nwi3status/modules/wlan"

	"github.com/BurntSushi/toml"
	colorful "github.com/lucasb-eyer/go-colorful"
	"github.com/martinlindhe/unit"
)

var spacer = pango.Text(" ").XXSmall()
var mainModalController modal.Controller

func truncate(in string, l int) string {
	fromStart := false
	if l < 0 {
		fromStart = true
		l = -l
	}
	inLen := len([]rune(in))
	if inLen <= l {
		return in
	}
	if fromStart {
		return "⋯" + string([]rune(in)[inLen-l+1:])
	}
	return string([]rune(in)[:l-1]) + "⋯"
}

func hms(d time.Duration) (h int, m int, s int) {
	h = int(d.Hours())
	m = int(d.Minutes()) % 60
	s = int(d.Seconds()) % 60
	return
}

func home(path ...string) string {
	usr, err := user.Current()
	if err != nil {
		panic(err)
	}
	args := append([]string{usr.HomeDir}, path...)
	return filepath.Join(args...)
}

func deviceForMountPath(path string) string {
	mnt, _ := exec.Command("df", "-P", path).Output()
	lines := strings.Split(string(mnt), "\n")
	if len(lines) > 1 {
		devAlias := strings.Split(lines[1], " ")[0]
		dev, _ := exec.Command("realpath", devAlias).Output()
		devStr := strings.TrimSpace(string(dev))
		if devStr != "" {
			return devStr
		}
		return devAlias
	}
	return ""
}

func makeIconOutput(key string) *bar.Segment {
	return outputs.Pango(spacer, pango.Icon(key), spacer)
}

func threshold(out *bar.Segment, urgent bool, color ...bool) *bar.Segment {
	if urgent {
		return out.Urgent(true)
	}
	colorKeys := []string{"bad", "degraded", "good"}
	for i, c := range colorKeys {
		if len(color) > i && color[i] {
			return out.Color(colors.Scheme(c))
		}
	}
	return out
}

type config struct {
	TodoistAPIKey string
}

func main() {
	var conf config
	if user, err := user.Current(); err == nil {
		if _, err := toml.DecodeFile(user.HomeDir+"/.config/i3/nwi3status.toml", &conf); err != nil {
			log.Fatal(err)
		}
	}

	if err := fonts.LoadMdi(); err != nil {
		log.Fatal(err)
	}
	if err := fonts.LoadTypicons(); err != nil {
		log.Fatal(err)
	}
	if err := fonts.LoadFontAwesome(); err != nil {
		log.Fatal(err)
	}

	colors.LoadBarConfig()
	bg := colors.Scheme("background")
	fg := colors.Scheme("statusline")
	if fg != nil && bg != nil {
		_, _, v := fg.Colorful().Hsv()
		if v < 0.3 {
			v = 0.3
		}
		colors.Set("bad", colorful.Hcl(40, 1.0, v).Clamped())
		colors.Set("degraded", colorful.Hcl(90, 1.0, v).Clamped())
		colors.Set("good", colorful.Hcl(120, 1.0, v).Clamped())
	}

	localdate := clock.Local().
		Output(time.Second, func(now time.Time) bar.Output {
			return outputs.Pango(
				pango.Icon("mdi-calendar-today").Alpha(0.6),
				now.Format("Mon Jan 2"),
			).OnClick(click.RunLeft("gsimplecal"))
		})

	localtime := clock.Local().
		Output(time.Second, func(now time.Time) bar.Output {
			return outputs.Text(now.Format("15:04:05")).
				OnClick(click.Left(func() {
					mainModalController.Toggle("timezones")
				}))
		})

	makeTzClock := func(lbl, tzName string) bar.Module {
		c, err := clock.ZoneByName(tzName)
		if err != nil {
			panic(err)
		}
		return c.Output(time.Minute, func(now time.Time) bar.Output {
			return outputs.Pango(pango.Text(lbl).Smaller(), spacer, now.Format("15:04"))
		})
	}

	battSummary, battDetail := split.New(battery.All().Output(func(i battery.Info) bar.Output {
		if i.Status == battery.Disconnected || i.Status == battery.Unknown {
			return nil
		}
		iconName := "battery"
		if i.Status == battery.Charging {
			iconName += "-charging"
		}
		tenth := i.RemainingPct() / 10
		switch {
		case tenth == 0:
			iconName += "-outline"
		case tenth < 10:
			iconName += fmt.Sprintf("-%d0", tenth)
		}
		mainModalController.SetOutput("battery", makeIconOutput("mdi-"+iconName))
		rem := i.RemainingTime()
		out := outputs.Group()
		// First segment will be used in summary mode.
		out.Append(outputs.Pango(
			pango.Icon("mdi-"+iconName).Alpha(0.6),
			pango.Textf("%d:%02d", int(rem.Hours()), int(rem.Minutes())%60),
		).OnClick(click.Left(func() {
			mainModalController.Toggle("battery")
		})))
		// Others in detail mode.
		out.Append(outputs.Pango(
			pango.Icon("mdi-"+iconName).Alpha(0.6),
			pango.Textf("%d%%", i.RemainingPct()),
			spacer,
			pango.Textf("(%d:%02d)", int(rem.Hours()), int(rem.Minutes())%60),
		).OnClick(click.Left(func() {
			mainModalController.Toggle("battery")
		})))
		out.Append(outputs.Pango(
			pango.Textf("%4.1f/%4.1f", i.EnergyNow, i.EnergyFull),
			pango.Text("Wh").Smaller(),
		))
		out.Append(outputs.Pango(
			pango.Textf("% +6.2f", i.SignedPower()),
			pango.Text("W").Smaller(),
		))
		switch {
		case i.RemainingPct() <= 5:
			out.Urgent(true)
		case i.RemainingPct() <= 15:
			out.Color(colors.Scheme("bad"))
		case i.RemainingPct() <= 25:
			out.Color(colors.Scheme("degraded"))
		}
		return out
	}), 1)

	wifiName, wifiDetails := split.New(wlan.Any().Output(func(i wlan.Info) bar.Output {
		if !i.Connecting() && !i.Connected() {
			mainModalController.SetOutput("network", makeIconOutput("mdi-ethernet"))
			return nil
		}
		mainModalController.SetOutput("network", makeIconOutput("mdi-wifi"))
		if i.Connecting() {
			return outputs.Pango(pango.Icon("mdi-wifi").Alpha(0.6), "...").
				Color(colors.Scheme("degraded"))
		}
		out := outputs.Group()
		// First segment shown in summary mode only.
		out.Append(outputs.Pango(
			pango.Icon("mdi-wifi").Alpha(0.6),
			pango.Text(truncate(i.SSID, -9)),
		).OnClick(click.Left(func() {
			mainModalController.Toggle("network")
		})))
		// Full name, frequency, bssid in detail mode
		out.Append(outputs.Pango(
			pango.Icon("mdi-wifi").Alpha(0.6),
			pango.Text(i.SSID),
		))
		out.Append(outputs.Textf("%2.1fG", i.Frequency.Gigahertz()))
		out.Append(outputs.Pango(
			pango.Icon("mdi-access-point").Alpha(0.8),
			pango.Text(i.AccessPointMAC).Small(),
		))
		return out
	}), 1)

	loadAvg := sysinfo.New().Output(func(s sysinfo.Info) bar.Output {
		out := outputs.Pango(
			pango.Icon("mdi-desktop-tower").Alpha(0.6),
			pango.Textf("%0.2f", s.Loads[0]),
		)
		// Load averages are unusually high for a few minutes after boot.
		if s.Uptime < 10*time.Minute {
			// so don't add colours until 10 minutes after system start.
			return out
		}
		threshold(out,
			s.Loads[0] > 128 || s.Loads[2] > 64,
			s.Loads[0] > 64 || s.Loads[2] > 32,
			s.Loads[0] > 32 || s.Loads[2] > 16,
		)
		out.OnClick(click.Left(func() {
			mainModalController.Toggle("sysinfo")
		}))
		return out
	})

	loadAvgDetail := sysinfo.New().Output(func(s sysinfo.Info) bar.Output {
		return pango.Textf("%0.2f %0.2f", s.Loads[1], s.Loads[2]).Smaller()
	})

	uptime := sysinfo.New().Output(func(s sysinfo.Info) bar.Output {
		u := s.Uptime
		var uptimeOut *pango.Node
		if u.Hours() < 24 {
			uptimeOut = pango.Textf("%d:%02d",
				int(u.Hours()), int(u.Minutes())%60)
		} else {
			uptimeOut = pango.Textf("%dd%02dh",
				int(u.Hours()/24), int(u.Hours())%24)
		}
		return pango.Icon("mdi-trending-up").Alpha(0.6).Concat(uptimeOut)
	})

	freeMem := meminfo.New().Output(func(m meminfo.Info) bar.Output {
		out := outputs.Pango(
			pango.Icon("mdi-memory").Alpha(0.8),
			format.IBytesize(m.Available()),
		)
		freeGigs := m.Available().Gigabytes()
		threshold(out,
			freeGigs < 0.5,
			freeGigs < 1,
			freeGigs < 2,
			freeGigs > 12)
		out.OnClick(click.Left(func() {
			mainModalController.Toggle("sysinfo")
		}))
		return out
	})

	swapMem := meminfo.New().Output(func(m meminfo.Info) bar.Output {
		return outputs.Pango(
			pango.Icon("mdi-swap-horizontal").Alpha(0.8),
			format.IBytesize(m["SwapTotal"]-m["SwapFree"]), spacer,
			pango.Textf("(% 2.0f%%)", (1-m.FreeFrac("Swap"))*100.0).Small(),
		)
	})

	temp := cputemp.New().
		RefreshInterval(2 * time.Second).
		Output(func(temp unit.Temperature) bar.Output {
			out := outputs.Pango(
				pango.Icon("mdi-fan").Alpha(0.6), spacer,
				pango.Textf("%2d℃", int(temp.Celsius())),
			)
			threshold(out,
				temp.Celsius() > 90,
				temp.Celsius() > 70,
				temp.Celsius() > 60,
			)
			return out
		})

	sub := netlink.Any()
	iface := sub.Get().Name
	sub.Unsubscribe()
	netsp := netspeed.New(iface).
		RefreshInterval(2 * time.Second).
		Output(func(s netspeed.Speeds) bar.Output {
			return outputs.Pango(
				pango.Icon("fa-upload").Alpha(0.5), spacer, pango.Textf("%7s", format.Byterate(s.Tx)),
				pango.Text(" ").Small(),
				pango.Icon("fa-download").Alpha(0.5), spacer, pango.Textf("%7s", format.Byterate(s.Rx)),
			)
		})

	net := netinfo.New().Output(func(i netinfo.State) bar.Output {
		if !i.Enabled() {
			return nil
		}
		if i.Connecting() || len(i.IPs) < 1 {
			return outputs.Text(i.Name).Color(colors.Scheme("degraded"))
		}
		return outputs.Group(outputs.Text(i.Name), outputs.Textf("%s", i.IPs[0]))
	})

	formatDiskSpace := func(i diskspace.Info, icon string) bar.Output {
		out := outputs.Pango(
			pango.Icon(icon).Alpha(0.7), spacer, format.IBytesize(i.Available))
		return threshold(out,
			i.Available.Gigabytes() < 1,
			i.AvailFrac() < 0.05,
			i.AvailFrac() < 0.1,
		)
	}

	rootDev := deviceForMountPath("/")
	var homeDiskspace bar.Module
	if deviceForMountPath(home()) != rootDev {
		homeDiskspace = diskspace.New(home()).Output(func(i diskspace.Info) bar.Output {
			return formatDiskSpace(i, "typecn-home-outline")
		})
	}
	rootDiskspace := diskspace.New("/").Output(func(i diskspace.Info) bar.Output {
		return formatDiskSpace(i, "fa-hdd")
	})

	mainDiskio := diskio.New(strings.TrimPrefix(rootDev, "/dev/")).
		Output(func(r diskio.IO) bar.Output {
			return pango.Icon("mdi-swap-vertical").
				Concat(spacer).
				ConcatText(format.IByterate(r.Total()))
		})

	syncthing := syncthing.New().
		Output(func(i syncthing.Info) bar.Output {
			return outputs.Pango(
				pango.Icon("fa-upload").Alpha(0.5), spacer, pango.Textf("%7s", format.Byterate(i.Tx)),
				pango.Text(" ").Small(),
				pango.Icon("fa-download").Alpha(0.5), spacer, pango.Textf("%7s", format.Byterate(i.Rx)),
			)
		})

	mainModal := modal.New()
	if conf.TodoistAPIKey != "" {
		todoist := todoist.New(conf.TodoistAPIKey)
		mainModal.Mode("todoist").
			SetOutput(makeIconOutput("mdi-format-list-checks")).
			Add(todoist)
	}
	mainModal.Mode("syncthing").
		SetOutput(makeIconOutput("mdi-sync")).
		Add(syncthing)
	sysMode := mainModal.Mode("sysinfo").
		SetOutput(makeIconOutput("mdi-chart-areaspline")).
		Add(loadAvg).
		Detail(loadAvgDetail, uptime).
		Add(freeMem).
		Detail(swapMem, temp)
	if homeDiskspace != nil {
		sysMode.Detail(homeDiskspace)
	}
	sysMode.Detail(rootDiskspace, mainDiskio)
	mainModal.Mode("network").
		SetOutput(makeIconOutput("mdi-ethernet")).
		Summary(wifiName).
		Detail(wifiDetails, net, netsp)
	mainModal.Mode("battery").
		// Filled in by the battery module if one is available.
		SetOutput(nil).
		Summary(battSummary).
		Detail(battDetail)
	mainModal.Mode("timezones").
		SetOutput(makeIconOutput("mdi-clock-outline")).
		Detail(makeTzClock("Los Angeles", "America/Los_Angeles")).
		Detail(makeTzClock("New York", "America/New_York")).
		Detail(makeTzClock("UTC", "Etc/UTC")).
		Detail(makeTzClock("London", "Europe/London")).
		Detail(makeTzClock("Berlin", "Europe/Berlin")).
		Detail(makeTzClock("Tokyo", "Asia/Tokyo")).
		Add(localdate)

	var mm bar.Module
	mm, mainModalController = mainModal.Build()
	panic(barista.Run(mm, localtime))
}
