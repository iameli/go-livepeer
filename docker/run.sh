#!/bin/bash

echo "> $*"
# Helper script for Windows to send Docker's RUN commands to the correct place.
bash -c "$*"