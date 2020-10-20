package i3dbus

import "github.com/godbus/dbus/v5"

func Notify(title string, message string) error {
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

func SetStatus(objName string, message string, icon string, state string) error {
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
