#!/bin/sh
read VAR_STDIN
ssh admin@172.16.102.254 << EOF > pcli2_out.txt
set cli scripting-mode on
set cli config-output-format set
$VARSTDIN
exit
exit
EOF
