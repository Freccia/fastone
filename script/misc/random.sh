#!/usr/bin/env bash
base64 /dev/urandom | head -c 1G > random_file
