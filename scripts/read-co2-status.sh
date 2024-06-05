#!/usr/bin/env bash

export "$(grep -v '^#' /run/keys/hass-cli.env | xargs -d '\n')"
json=$(hass-cli -o json state get sensor.fraam_co2_mhz19b_carbondioxide)
state=$(echo "$json" | jq -r '.[0].state')
class=""

if ((state > 1000)); then
  class="alert"
fi

jq --null-input --unbuffered --compact-output --arg text "$state" --arg class "$class" '{"text": $text, "class": $class}'
