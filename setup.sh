#!/usr/bin/env bash
cd "$(realpath dirname $0)" || exit
sudo apt install postgresql-client
pip install -r requirement.txt
