#! /bin/bash

echo "Count of $USER initiated processes: "
ps -a -u $USER | wc -l