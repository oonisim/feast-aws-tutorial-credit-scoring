#!/usr/bin/env bash
cd "$(realpath dirname $0)" || exit
sudo apt install python3-dev postgresql-client libpq-dev
pip install -r requirement.txt

# For Postgresql psycopg2.
# python3-dev does not work with the error (./psycopg/psycopg.h:35:10: fatal error: Python.h: No such file or directory)
# #include <Python.h>. Must be python<version>-dev.
pip install python3.11-dev libpq-dev psycopg2-binary psycopg2
