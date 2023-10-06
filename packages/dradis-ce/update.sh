#!/usr/bin/env bash

wget https://raw.githubusercontent.com/dradis/dradis-ce/develop/Gemfile -O Gemfile
wget https://raw.githubusercontent.com/dradis/dradis-ce/develop/Gemfile.lock -O Gemfile.lock

bundix
