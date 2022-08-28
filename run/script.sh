#!/usr/bin/env sh

# restart dbus session
sed '1,/^exit$/d' $0 | dbus-run-session sh
exit

# mount ftp host
gio mount --anonymous ftp://ftp.mtps.gov.br

gio copy $SOURCE /tmp/'${SOURCE}'
gsutil -m cp /tmp/'${SOURCE}' $DESTINATION

gio mount --unmount ftp://ftp.mtps.gov.br
