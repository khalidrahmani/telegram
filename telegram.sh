#!/bin/bash
$phone="$1"
$first="$2"
$last="$3"
tgpath=/home/yahya/Desktop/tests/tg/bin/ 
cd ${tgpath}
./telegram-cli -u user -e "add_contact $phone $first $last" --json <<EOF
safe_quit
EOF
