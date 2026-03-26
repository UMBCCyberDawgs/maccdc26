#!/bin/sh
ssh admin@172.16.101.254 << EOF > p1.txt
set cli scripting-mode on
set cli config-output-format set
configure
show
exit
exit
EOF
ssh admin@172.16.102.254 << EOF > p2.txt
set cli scripting-mode on
set cli config-output-format set
configure
show
exit
exit
EOF
