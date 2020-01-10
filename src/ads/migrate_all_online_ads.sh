#!/bin/sh
#
# $HP: migrate_all_online_ads.sh,v 1.3 2000/12/20 18:42:11 slee Exp $
# $Id: migrate_all_online_ads.sh,v 1.3 2006/01/25 04:18:08 lukeh Exp $
#
# Copyright (c) 1997-2006 Luke Howard.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#        This product includes software developed by Luke Howard.
# 4. The name of the other may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE LUKE HOWARD ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL LUKE HOWARD BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

# generic migration script for flat files, YP and NetInfo.
# uses ldapadd

SHELL=/bin/sh
export SHELL

DB=/tmp/nis.$$.ldif

#if [ "X$ETC_ALIASES" = "X" ]; then
#	ETC_ALIASES=/etc/aliases
#fi
#if [ "X$ETC_FSTAB" = "X" ]; then
#	ETC_FSTAB=/etc/fstab
#fi
#if [ "X$ETC_HOSTS" = "X" ]; then
#	ETC_HOSTS=/etc/hosts
#fi
#if [ "X$ETC_NETWORKS" = "X" ]; then
#	ETC_NETWORKS=/etc/networks
#fi
if [ "X$ETC_PASSWD" = "X" ]; then
	ETC_PASSWD=/etc/passwd
fi
if [ "X$ETC_GROUP" = "X" ]; then
	ETC_GROUP=/etc/group
fi
#if [ "X$ETC_SERVICES" = "X" ]; then
#	ETC_SERVICES=/etc/services
#fi
#if [ "X$ETC_PROTOCOLS" = "X" ]; then
#	ETC_PROTOCOLS=/etc/protocols
#fi
#if [ "X$ETC_RPC" = "X" ]; then
#	ETC_RPC=/etc/rpc
#fi
#if [ "X$ETC_NETGROUP" = "X" ]; then
#	ETC_NETGROUP=/etc/netgroup
#fi

if [ -z "${LDAPMODIFY}" ]
  then
  LDAPMODIFY="/usr/xad/bin/ldapmodify"
fi

if [ ! -x "${LDAPMODIFY}" ]
  then
  echo "Error: Incomplete installation of the LDAP Client tools fileset."
  echo "       Missing ${LDAPMODIFY} tool"
else
  LDAPADD="/usr/xad/bin/ldapmodify -a -c"
fi

if [ -z "${PERL}" ]
  then
  PERL="/usr/bin/perl"
fi

if [ ! -x "${PERL}" ]
  then
  echo "Error: Incomplete installation of the LDAP Client tools fileset."
  echo "       Missing ${PERL} tool"
fi

if [ "X$LDAP_BASEDN" = "X" ]; then
	defaultcontext=`$PERL -e 'require "migrate_common.ph"; print \$DEFAULT_BASE';`
	question="Enter the X.500 naming context you wish to import into: [$defaultcontext]"
	echo "$question " | tr -d '\012' > /dev/tty
	read LDAP_BASEDN
	if [ "X$LDAP_BASEDN" = "X" ]; then
		if [ "$defaultcontext" = "X" ]; then
			echo "You must specify a default context."
			exit 2
		else
			LDAP_BASEDN=$defaultcontext
		fi
	fi
fi
export LDAP_BASEDN

if [ "X$SYNC_NISDOMAIN" = "X" ]; then
	defaultnisdomain=`$PERL -e 'require "migrate_common.ph"; print \$SYNC_NISDOMAIN';`
	question="Enter the NIS Domain you wish to import into: [$defaultnisdomain]"
	echo "$question " | tr -d '\012' > /dev/tty
	read SYNC_NISDOMAIN
	if [ "X$SYNC_NISDOMAIN" = "X" ]; then
		if [ "$defaultnisdomain" = "X" ]; then
			echo "You must specify a default NIS Domain."
			exit 2
		else
			SYNC_NISDOMAIN=$defaultnisdomain
		fi
	fi
fi
export SYNC_NISDOMAIN

if [ "X$LDAPHOST" = "X" ]; then
	question="Enter the name of your LDAP server [ldap]:"
	echo "$question " | tr -d '\012' > /dev/tty
	read LDAPHOST
	if [ "X$LDAPHOST" = "X" ]; then
		LDAPHOST="ldap"
	fi
fi

if [ "X$LDAP_BINDDN" = "X" ]; then
	question="Enter the manager DN: [cn=Administrator,cn=Users,$LDAP_BASEDN]:"
	echo "$question " | tr -d '\012' > /dev/tty
	read LDAP_BINDDN
	if [ "X$LDAP_BINDDN" = "X" ]; then
		LDAP_BINDDN="cn=Administrator,cn=Users,$LDAP_BASEDN"
	fi
fi
export LDAP_BINDDN

if [ "X$LDAP_BINDCRED" = "X" ]; then
	question="Enter the credentials to bind with:"
	echo "$question " | tr -d '\012' > /dev/tty
	stty -echo
	read LDAP_BINDCRED
	stty echo
        echo
fi

if [ "X$CN" = "X" ]; then
        echo
        echo "Do you wish to use the user's account name or proper name (as defined in the"
        echo "GECOS field) to define the entry's distinguished name?  Note: if you wish to"
        echo "use the proper name, it must be unique for each entry.  Examples:"
        echo
        echo "Account Name:"
        echo "  DN:  cn=jchan,cn=users,dc=localdom,dc=myorg,dc=org"
        echo
        echo "Proper Name:"
        echo "  DN:  cn=James Chan,cn=users,dc=localdom,dc=myorg,dc=org"
        echo
        while ( true )
           do
           question="[a]ccount Name or [p]roper name? [p]:"
	   echo "$question " | tr -d '\012' > /dev/tty
           CN="$(line | tr "[:upper:]" "[:lower:]")"
           if [ "$CN" = "a" ] ; then
              CN="no"
              break;
           elif [ "$CN" = "p" ] ; then
              CN="yes"
              break;
           else
              echo "Please select \"a\" or \"p\"."
           fi
        done
fi
export CN
echo
echo
echo "Importing into $LDAP_BASEDN..."
echo
#echo "Creating naming context entries..."
#$PERL migrate_base.pl -n		> $DB
#echo "Migrating aliases..."
#$PERL migrate_aliases.pl 	$ETC_ALIASES >> $DB
#echo "Migrating fstab..."
#$PERL migrate_fstab.pl		$ETC_FSTAB >> $DB
echo "Migrating groups..."
$PERL migrate_group_ads.pl	$ETC_GROUP >> $DB
#echo "Migrating hosts..."
#$PERL migrate_hosts.pl		$ETC_HOSTS >> $DB
#echo "Migrating networks..."
#$PERL migrate_networks.pl	$ETC_NETWORKS >> $DB
echo "Migrating users..."
$PERL migrate_passwd_ads.pl	$ETC_PASSWD >> $DB
#echo "Migrating protocols..."
#$PERL migrate_protocols.pl	$ETC_PROTOCOLS >> $DB
#echo "Migrating rpcs..."
#$PERL migrate_rpc.pl		$ETC_RPC >> $DB
#echo "Migrating services..."
#$PERL migrate_services.pl	$ETC_SERVICES >> $DB
#echo "Migrating netgroups..."
#$PERL migrate_netgroup.pl	$ETC_NETGROUP >> $DB
#echo "Migrating netgroups (by user)..."
#$PERL migrate_netgroup_byuser.pl	$ETC_NETGROUP >> $DB
#echo "Migrating netgroups (by host)..."
#$PERL migrate_netgroup_byhost.pl	$ETC_NETGROUP >> $DB

echo "Your data has been migrated to the following ldif file: $DB"
question="Do you wish to import that file into your directory now (y/n):"
echo "$question " | tr -d '\012' > /dev/tty
read yn
if [[ "$yn" = "y" || "$yn" = "Y" || "$yn" = "yes" ]]
  then
  echo "Importing into LDAP..."

  $LDAPADD -h $LDAPHOST -D "$LDAP_BINDDN" -w "$LDAP_BINDCRED" -f $DB
  err=$?

  if [ $err -ne 0 ]; then
        echo "$LDAPADD: returned error $err"
        echo "Your new ldif database file exists in: $DB"
        e=$?
  else
        echo "$LDAPADD: succeeded"
        rm -f $DB
        e=$?
  fi
else
  echo "You may import the ldif file into the directory with the following"
  echo "command: $LDAPADD -h $LDAPHOST -D "$LDAP_BINDDN" -w password -f $DB"
  exit 1
fi

if [ "X$EXIT" != "Xno" ]; then
	exit $e
fi
