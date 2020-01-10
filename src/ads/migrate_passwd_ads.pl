#!/usr/bin/perl
#
# $HP: migrate_passwd_ads.pl,v 1.3 2000/12/20 18:42:13 slee Exp $
# $Id: migrate_passwd_ads.pl,v 1.3 2006/01/25 04:18:08 lukeh Exp $
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

require 'migrate_common.ph';

$PROGRAM = "migrate_passwd.pl";
$NAMINGCONTEXT = &getsuffix($PROGRAM);

&parse_args();
&open_files();

while(<INFILE>)
{
    chop;
    next if /^#/;
    next if /^\+/;
    local($user, $pwd, $uid, $gid, $gecos, $homedir, $shell) = split(/:/);
    
    if ($use_stdout) {
	&dump_user(STDOUT, $user, $pwd, $uid, $gid, $gecos, $homedir, $shell);
    } else {
	&dump_user(OUTFILE, $user, $pwd, $uid, $gid, $gecos, $homedir, $shell);
    }
}

sub dump_user
{
	local($HANDLE, $user, $pwd, $uid, $gid, $gecos, $homedir, $shell) = @_;
	local($name,$office,$wphone,$hphone)=split(/,/,$gecos);
	local($sn);	
	local($givenname);	
	local($cn);
	local(@tmp);

        if ($DEFAULT_CN eq "yes") {
            if ($name) { $cn = $name; } else { $cn = $user; }
        }
        else {
            $cn = $user;
        }

	$_ = $cn;
	@tmp = split(/\s+/);
	$sn = $tmp[$#tmp];
	pop(@tmp);
	$givenname=join(' ',@tmp);
	
	print $HANDLE "dn: cn=$cn,$NAMINGCONTEXT\n";
	print $HANDLE "objectClass: user\n";
	print $HANDLE "cn: $cn\n";
	print $HANDLE "sAMAccountName: $user\n";
	print $HANDLE "uid: $user\n";

#        if ($SYNC_NISDOMAIN) {
#		print $HANDLE "syncNisDomain: $SYNC_NISDOMAIN\n";
#        }

	if ($EXTENDED_SCHEMA) {
		if ($wphone) {
			print $HANDLE "telephoneNumber: $wphone\n";
		}
		if ($office) {
			print $HANDLE "roomNumber: $office\n";
		}
		if ($hphone) {
			print $HANDLE "homePhone: $hphone\n";
		}
		if ($givenname) {
			print $HANDLE "givenName: $givenname\n";
		}
		print $HANDLE "sn: $sn\n";
		if ($DEFAULT_MAIL_DOMAIN) {
			print $HANDLE "mail: $user@","$DEFAULT_MAIL_DOMAIN\n";
		}
	}

	if ($shell) {
		print $HANDLE "loginShell: $shell\n";
	}

	if ($uid ne "") {
		print $HANDLE "uidNumber: $uid\n";
	} 

	if ($gid ne "") {
		print $HANDLE "gidNumber: $gid\n";
	} 

	if ($homedir) {
		print $HANDLE "unixHomeDirectory: $homedir\n";
	}   

	if ($gecos) {
		print $HANDLE "gecos: $gecos\n";
	}

#	if ($pwd && $pwd ne "x" && $pwd ne "*") {
#		print $HANDLE "userPassword: {CRYPT}$pwd\n";
#	}


	print $HANDLE "\n";
}

close(INFILE);
if (OUTFILE != STDOUT) { close(OUTFILE); }

