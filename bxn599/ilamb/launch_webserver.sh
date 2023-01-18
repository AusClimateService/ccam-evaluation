#!/bin/bash

cd /g/data/xv83/users/bxn599/ACS/ilamb
module load python3
python3 -m http.server -b localhost 8000
