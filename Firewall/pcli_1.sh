#!/bin/sh
read VAR_STDIN
ssh admin@172.16.101.254 << EOF > pcli1_out.txt
set cli scripting-mode on
set cli config-output-format set
$VAR_STDIN
exit
exit
EOF
