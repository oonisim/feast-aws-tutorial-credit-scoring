#!/usr/bin/env bash
# --------------------------------------------------------------------------------
# Setup EC2 (Ubuntu) Environment
# --------------------------------------------------------------------------------

cd "$(realpath dirname "$0")" || exit
# --------------------------------------------------------------------------------
# Ubuntu Python
# --------------------------------------------------------------------------------
sudo apt install python3.11 python3-dev build-essential libssl-dev libffi-dev python3.11-dev python3-pip python3.11-venv
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# --------------------------------------------------------------------------------
# For Postgresql psycopg2.
# python3-dev does not work with the error (./psycopg/psycopg.h:35:10: fatal error: Python.h: No such file or directory)
# #include <Python.h>. Must be python<version>-dev.
# --------------------------------------------------------------------------------
sudo apt install  postgresql-client libpq-dev
pip install psycopg2-binary psycopg2

# --------------------------------------------------------------------------------
# FEAST/Tutorial Dependencies
# --------------------------------------------------------------------------------
pip install -r requirement.txt

