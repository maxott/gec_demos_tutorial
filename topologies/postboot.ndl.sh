#!/bin/bash
host=`echo $self.Name() | sed 's/NodeGroup[0-9]*\///g'`
slice=$sliceName
echo $host > /etc/hostname
/bin/hostname -F /etc/hostname
echo "---
:uid: $host-$slice
:uri: xmpp://<%= \"$host-$slice-#{Process.pid}\" %>:<%= \"$host-$slice-#{Process.pid}\" %>@emmy9.casa.umass.edu
:environment: production
:debug: false" > /etc/omf_rc/config.yml
until [[ `ifconfig eth1 | grep 192` ]]; do sleep 1; done
/etc/init.d/omf_rc restart
/etc/init.d/neuca stop