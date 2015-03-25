#!/usr/bin/python

#
# Quick hacked together script for taking in two args (Remote System name, Remote DB Size), and dumping them into Graphite.
#  -- Darren Gibbard
#

import sys
from time import time
try:
    import graphitesend
except ImportError:
    print("This program requires graphitesend. Install using:")
    print("sudo pip install graphitesend")
    print("")
    sys.exit(1)

# Setup our config
set_graphite_server = "localhost"
set_graphite_port = "2003"
set_prefix = None
set_suffix = None
set_connect_on_create = True
set_group = "cdb-disks"
set_lowercase_metric_names = True
set_fqdn_squash = False
set_dryrun = False
set_debug = True

## System Name Arg1
try:
    set_system_name = str(sys.argv[1])
except IndexError:
    print("Usage: %s [remote_server] [disk_size_mb]" % str(sys.argv[0]))
    sys.exit(1)

## Disk Size Arg2
try:
    diskmb = str(sys.argv[2])
except IndexError:
    print("Usage: %s [remote_server] [disk_size_mb]" % str(sys.argv[0]))
    sys.exit(1)

print("Hostname: %s    Disk Size: %s" % set_system_name, diskmb)

# Set epoch time
epoch=time()

# Setup connection
g = graphitesend.init(prefix=set_prefix, graphite_server=set_graphite_server, graphite_port=set_graphite_port, debug=set_debug, group=set_group, system_name=set_system_name, suffix=set_suffix, lowercase_metric_names=set_lowercase_metric_names, connect_on_create=set_connect_on_create, fqdn_squash=set_fqdn_squash, dryrun=set_dryrun)

# Send data
print g.send_list([('db_size_mb', disk_size_mb)], timestamp=epoch)
