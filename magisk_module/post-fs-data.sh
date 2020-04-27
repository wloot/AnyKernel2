#!/system/bin/sh
MODDIR=${0%/*}

if test -z "$(uname -r|grep candy)"; then
    rm -rf $MODDIR
fi
