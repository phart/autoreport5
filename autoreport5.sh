#!/usr/bin/bash
# verstion 1 - 2020-04-03
# John McLaughlan

PATH=/usr/nef/bin:/usr/nef/cli/sbin:/usr/nef/cli/bin:$PATH
export PATH
LOGFILE=./autoreport.txt
LOGFILE=/dev/tty
D=`date -u +"%Y%m%d%H%M%S"`
GUID=`license  show  | grep guid | nawk '{ print $2}'`
LOGFILE=/var/dropbox/$D.$GUID.autoreport.txt
echo "Auto Report for $GUID  run at `date -u`" into  $LOGFILE
echo "Auto Report run at `date`" > $LOGFILE


mkdir -p /var/dropbox
(
echo 'LINE="\\n------------------------\\n"'
NUM=1

(
cat <<EOF

# These are the CLI commands that will be run by the autoreport script

system status

uptime

software version -v
software list

license show

inventory cpu
inventory hba
inventory lu
inventory memory
inventory nic
inventory sensor
inventory tape-device

iostat -en

disk list

ip list

link list
link list aggr
link list port
link list vlan
link list vnic

route list

config list

enclosure list

net list host
net list dns
net list netmask

svc list 
svc get all ha
svc get all idmap
svc get all iscsit
svc get all ldapclient
svc get all ndmp
svc get all nfs
svc get all ntp
svc get all sedctl
svc get all smb
svc get all smbclient
svc get all snmp
svc get all stmf
svc get all vscan

hpr list
config list hpr
config get value hpr.dataAddress

node status

alert list

core list

profile show

user list

config get all rest.certificate

pool list
pool status

filesystem list
filesystem get all

hacluster status -e
haservice list
haservice status

disk get all
disk get all | grep pathCount 
disk get all | grep portCount 

# loops are a but tricker as the dollar variables have to be protected
# as command will be echo-ed into the CLI program and we want the CLI
# to do the variable interpretation

pool list | grep ONLINE | nawk '{ print \$1 }' | while read poolname ; do pool status \$poolname ; done

nfs list 
nfs list | grep online | nawk '{ print \$1 }' | while read fs ; do echo ; echo "\$fs" ; echo ; nfs get all  \$fs ; done

smb list 
smb list | grep online | nawk '{ print \$1 }' | while read fs ; do echo ; echo "\$fs" ; echo ; smb get all  \$fs ; done

volumegroup list

iscsitarget list

volume list
lunmapping list
hostgroup list

fctarget list
targetgroup list
logicalunit list

snapping list

ndmpauth list
vscan list

journal list

journal tail -c 300  messages
journal tail -c 300  rsf/rsfmon

EOF
) | sed -e '/^$/d' -e '/^#/d' |  while read cmd
do
	echo "echo \"\${LINE} $NUM:  $cmd \${LINE}\""
	NUM=`expr $NUM + 1`
	echo $cmd
done


)   | cli 2>&1  >> $LOGFILE
#)   

(

echo '\n------------------------\n"'
echo "cat /etc/system" 
echo '\n------------------------\n"'
cat /etc/system | sed -e '/^*/d'  -e '/^[\t ]*$/d'


echo '\n------------------------\n"'
echo "sasinfo hba-port -y"
echo '-\n-----------------------\n"'
sasinfo hba-port -y

echo '\n-----------------------\n"'
echo "cat /etc/syslog.conf"
echo '\n-----------------------\n"'
cat /etc/syslog.conf

echo
)  >> $LOGFILE


echo "Auto Report:  $LOGFILE"
