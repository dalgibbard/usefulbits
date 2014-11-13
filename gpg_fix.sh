#!/bin/bash
#
# Fix missing apt GPG keys
# 
if [ "x$1" = "x" ]; then
	echo "Usage: $0 <GPG_PUBKEY_STRING>"
	exit 1
fi

KEY=$1
SERVER=keyserver.ubuntu.com

if [ "x`which gpg | head -n 1`" = "x" ]; then
	echo "Error: Could not find gpg binary. Please install gpg, or ensure it is in your \$PATH."
	exit 2
fi

gpg --keyserver $SERVER --recv-keys $KEY
if [ ! "$?" = 0 ]; then
	echo "An error occured whilst attempting to retrieve the Keys for $KEY from $SERVER."
	exit 3
fi
gpg --armor --export $KEY | apt-key add -
if [ "$?" = 0 ]; then
	echo "Key Import completed successfully. Remember to run 'apt-get update'."
	exit 0
else
	echo "An error occured whilst attempting to add the Key to apt."
	exit 4
fi
