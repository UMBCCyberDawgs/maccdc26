#!/bin/sh
read VAR_STDIN
ssh admin@172.16.101.254 << EOF > pcli1_out.txt
$VARSTDIN
EOF
