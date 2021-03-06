#!/bin/bash
#
# Script to get CouchDB DB Sizes in MB, and push them to graphite using cdb_to_graphite.py
#

user=myuser
graphite=/usr/local/bin/cdb_to_graphite.py
list=$1
ssh_opts="-q -o ConnectTimeout=5 -l ${user} -i /home/${user}/.ssh/id_rsa"

if [ "x$graphite" = "x" ] ;then
    echo "Failed to locate $pushscript in \$PATH"
    exit 1
fi

if [ "x$list" = "x" ]; then
    echo "Usage: $0 [list_of_cdb_nodes_file.txt]"
    exit 1
fi

if [ ! -f $list ]; then
    echo "Failed to locate node list file: $list"
    exit 1
fi

while read line; do
    if [ "x$line" = "x" ]; then
        continue
    fi
    SIZE=$(ssh -n $ssh_opts $line "du -ms /opt/couchdb/dbs/pim.couch | awk '{print\$1}'")
    if [[ ! "x$SIZE" =~ x[0-9] ]]; then
        echo "Failed to obtain DB Size from $line"
        continue
    fi

    submit="$graphite ${line} $SIZE"
    echo "$submit"
    $graphite $submit
done < <(cat $list)

