#!/bin/sh
#
# $Id: migrate_all_nisplus_online.sh,v 1.7 2004/09/24 05:49:08 lukeh Exp $
#
# Copyright (c) 1997-2003 Luke Howard.
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

#
# Migrate NIS+ accounts using ldapadd
#

PATH=$PATH:.
export PATH


TMPDIR="/tmp"
ETC_PASSWD="$TMPDIR/passwd.$$.ldap"
ETC_GROUP="$TMPDIR/group.$$.ldap"
ETC_SERVICES="$TMPDIR/services.$$.ldap"
ETC_PROTOCOLS="$TMPDIR/protocols.$$.ldap"
ETC_FSTAB="$TMPDIR/fstab.$$.ldap"
ETC_RPC="$TMPDIR/rpc.$$.ldap"
ETC_HOSTS="$TMPDIR/hosts.$$.ldap"
ETC_NETWORKS="$TMPDIR/networks.$$.ldap"
ETC_NETGROUP="$TMPDIR/netgroup.$$.ldap"
ETC_ALIASES="$TMPDIR/aliases.$$.ldap"
EXIT=no

question="Enter the NIS+ domain to import from (optional): "
echo "$question " | tr -d '\012' > /dev/tty
read DOM
if [ "X$DOM" = "X" ]; then
        DOM="`domainname`."
else
        DOM="$DOM."
fi

nisaddent -d passwd $DOM > $ETC_PASSWD
nisaddent -d group $DOM > $ETC_GROUP
nisaddent -d services $DOM > $ETC_SERVICES
nisaddent -d protocols $DOM > $ETC_PROTOCOLS
touch $ETC_FSTAB
nisaddent -d rpc $DOM > $ETC_RPC
nisaddent -d hosts $DOM > $ETC_HOSTS
nisaddent -d networks $DOM > $ETC_NETWORKS
nisaddent -d netgroup $DOM > $ETC_NETGROUP
niscat mail_aliases.org_dir.$DOM > $ETC_ALIASES

. migrate_all_online.sh

rm -f $ETC_PASSWD
rm -f $ETC_GROUP
rm -f $ETC_SERVICES
rm -f $ETC_PROTOCOLS
rm -f $ETC_FSTAB
rm -f $ETC_RPC
rm -f $ETC_HOSTS
rm -f $ETC_NETWORKS
rm -f $ETC_NETGROUP
rm -f $ETC_ALIASES

