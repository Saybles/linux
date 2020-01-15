#! /bin/bash

netstat -anp | grep :$0 | grep ESTABLISHED | wc -l