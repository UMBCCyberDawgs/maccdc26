#!/bin/sh
read VAR_STDIN
ssh admin@172.16.102.254 << EOF > pcli2_out.txt
$VARSTDIN
EOF
