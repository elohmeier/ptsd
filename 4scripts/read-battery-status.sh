#!/usr/bin/env bash

DEVICE=/org/freedesktop/UPower/devices/mouse_hidpp_battery_0
BATTERY_POWER=$(upower -i "$DEVICE" | grep -E percentage | awk '{print $2}' | tr -d '%')

if [[ "${BATTERY_POWER}" -gt 87 ]]; then
	BATTERY_ICON=""
elif [[ "${BATTERY_POWER}" -gt 63 ]]; then
	BATTERY_ICON=""
elif [[ "${BATTERY_POWER}" -gt 38 ]]; then
	BATTERY_ICON=""
elif [[ "${BATTERY_POWER}" -gt 13 ]]; then
	BATTERY_ICON=""
elif [[ "${BATTERY_POWER}" -le 13 ]]; then
	BATTERY_ICON=""
else
	BATTERY_ICON=""
fi

if (($BATTERY_POWER < 13)); then
	class="alert"
fi

jq --null-input --unbuffered --compact-output --arg text "${BATTERY_ICON}" --arg percentage "${BATTERY_POWER}" --arg tooltip "${DEVICE}: ${BATTERY_POWER}%" --arg class "$class" '{"text": $text, "tooltip": $tooltip, "percentage": $percentage, "class": $class}'
