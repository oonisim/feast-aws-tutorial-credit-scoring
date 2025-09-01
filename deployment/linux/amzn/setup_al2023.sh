#!/usr/bin/env bash
# --------------------------------------------------------------------------------
# Setup EC2 (Ubuntu) Environment
# --------------------------------------------------------------------------------
cd "$(realpath dirname "$0")" || exit
sudo dnf update -y

# --------------------------------------------------------------------------------
# Python
# --------------------------------------------------------------------------------
sudo dnf install -y python3.11 python3.11-pip python3.11-devel

# --------------------------------------------------------------------------------
# Postgresql
# --------------------------------------------------------------------------------
sudo dnf install -y postgresql-devel

# --------------------------------------------------------------------------------
# For Postgresql psycopg2.
# python3-dev does not work with the error (./psycopg/psycopg.h:35:10: fatal error: Python.h: No such file or directory)
# #include <Python.h>. Must be python<version>-dev.
# --------------------------------------------------------------------------------
sudo apt install postgresql-client libpq-dev
pip install psycopg2-binary psycopg2

# --------------------------------------------------------------------------------
# FEAST/Tutorial Dependencies
# --------------------------------------------------------------------------------
pip install -r requirement.txt

