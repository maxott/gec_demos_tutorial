host=$1
slice=`ruby -e "print '$2'[/[^+]*$/]"`
echo $host > /etc/hostname
/bin/hostname -F /etc/hostname
echo "---
:uid: $host-$slice
:uri: xmpp://<%= \"$host-$slice-#{Process.pid}\" %>:<%= \"$host-$slice-#{Process.pid}\" %>@221.199.209.231
:environment: production
:debug: false" > /etc/omf_rc/config.yml
/etc/init.d/omf_rc restart