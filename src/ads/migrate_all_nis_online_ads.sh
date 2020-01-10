#!/bin/sh
#
# $HP: migrate_all_nis_online_ads.sh,v 1.2 2000/11/21 06:37:04 slee Exp $
# $Id: migrate_all_nis_online_ads.sh,v 1.3 2006/01/25 04:18:08 lukeh Exp $
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

#
# Migrate NIS/YP accounts using ldapadd
#

PATH=$PATH:.
export PATH


TMPDIR="/tmp"
ETC_PASSWD="$TMPDIR/passwd.$$.ldap"
ETC_GROUP="$TMPDIR/group.$$.ldap"
#ETC_SERVICES="$TMPDIR/services.$$.ldap"
#ETC_PROTOCOLS="$TMPDIR/protocols.$$.ldap"
#ETC_FSTAB="$TMPDIR/fstab.$$.ldap"
#ETC_RPC="$TMPDIR/rpc.$$.ldap"
#ETC_HOSTS="$TMPDIR/hosts.$$.ldap"
#ETC_NETWORKS="$TMPDIR/networks.$$.ldap"
#ETC_ALIASES="$TMPDIR/aliases.$$.ldap"
EXIT=no

question="Enter the NIS domain to import from (optional): "
echo "$question " | tr -d '\012' > /dev/tty
read DOM
if [ "X$DOM" = "X" ]; then
        DOMFLAG=""
else
	DOMFLAG="-d $DOM"
fi

ypcat $DOMFLAG passwd > $ETC_PASSWD
ypcat $DOMFLAG group > $ETC_GROUP
#ypcat $DOMFLAG services > $ETC_SERVICES
#ypcat $DOMFLAG protocols > $ETC_PROTOCOLS
#touch $ETC_FSTAB
#ypcat $DOMFLAG rpc.byname > $ETC_RPC
#ypcat $DOMFLAG hosts > $ETC_HOSTS
#ypcat $DOMFLAG networks > $ETC_NETWORKS
##ypcat $DOMFLAG -k aliases > $ETC_ALIASES

. migrate_all_online_ads.sh

rm -f $ETC_PASSWD
rm -f $ETC_GROUP
#rm -f $ETC_SERVICES
#rm -f $ETC_PROTOCOLS
#rm -f $ETC_FSTAB
#rm -f $ETC_RPC
#rm -f $ETC_HOSTS
#rm -f $ETC_NETWORKS
#rm -f $ETC_ALIASES

