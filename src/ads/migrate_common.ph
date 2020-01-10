#
# $Id: migrate_common.ph,v 1.2 2006/01/25 04:10:31 lukeh Exp $
#
# Copyright (c) 1997 Luke Howard.
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
# Common defines for MigrationTools
#

#$NAMINGCONTEXT{'aliases'}           = "ou=Aliases";
#$NAMINGCONTEXT{'fstab'}             = "ou=Mounts";
$NAMINGCONTEXT{'passwd'}            = "cn=Users";
#$NAMINGCONTEXT{'netgroup_byuser'}   = "nisMapName=netgroup.byuser";
#$NAMINGCONTEXT{'netgroup_byhost'}   = "nisMapName=netgroup.byhost";
$NAMINGCONTEXT{'group'}             = "cn=Users";
#$NAMINGCONTEXT{'netgroup'}          = "ou=Netgroup";
#$NAMINGCONTEXT{'hosts'}             = "cn=Computers";
#$NAMINGCONTEXT{'networks'}          = "ou=Networks";
#$NAMINGCONTEXT{'protocols'}         = "ou=Protocols";
#$NAMINGCONTEXT{'rpc'}               = "ou=Rpc";
#$NAMINGCONTEXT{'services'}          = "ou=Services";

# Default DNS domain
$DEFAULT_MAIL_DOMAIN = "padl.com";

# Default base 
# If we haven't set the default base, guess it automagically.
if (!defined($DEFAULT_BASE)) {
	$DEFAULT_BASE = &domain_expand($DEFAULT_MAIL_DOMAIN);
	$DEFAULT_BASE =~ s/,$//;
}

#
# allow environment variables to override predefines
#
if (defined($ENV{'LDAP_BASEDN'})) {
	$DEFAULT_BASE = $ENV{'LDAP_BASEDN'};
}

if (defined($ENV{'SYNC_NISDOMAIN'})) {
	$SYNC_NISDOMAIN = $ENV{'SYNC_NISDOMAIN'};
}
elsif (defined($ENV{'LDAP_BASEDN'})) {
	$SYNC_NISDOMAIN = $ENV{'LDAP_BASEDN'};
	$SYNC_NISDOMAIN =~ s/^[^=]*=([^,]*),.*$/$1/;
	$SYNC_NISDOMAIN =~ s/^\s+//;
	$SYNC_NISDOMAIN =~ s/\s+$//;
}

if (defined($ENV{'LDAP_DEFAULT_MAIL_DOMAIN'})) {
	$DEFAULT_MAIL_DOMAIN = $ENV{'DEFAULT_MAIL_DOMAIN'};
}

# binddn used for alias owner (otherwise uid=root,...)
if (defined($ENV{'LDAP_BINDDN'})) {
	$DEFAULT_OWNER = $ENV{'LDAP_BINDDN'};
}


if (defined($ENV{'CN'})) {
    $DEFAULT_CN = $ENV{'CN'};
}
else {
    $DEFAULT_CN = "yes";
}
 
# turn this on to support more general object clases
# such as person.
$EXTENDED_SCHEMA = 0;

# Default Kerberos realm
if ($EXTENDED_SCHEMA) {
	$DEFAULT_REALM = $DEFAULT_MAIL_DOMAIN;
	$DEFAULT_REALM =~ tr/a-z/A-Z/;
}

if (-x "/usr/sbin/revnetgroup") {
	$REVNETGROUP = "/usr/sbin/revnetgroup";
} elsif (-x "/usr/lib/yp/revnetgroup") {
	$REVNETGROUP = "/usr/lib/yp/revnetgroup";
}

sub parse_args
{
	if ($#ARGV < 0) {
		print STDERR "Usage: $PROGRAM infile [outfile]\n";
		exit 1;
	}
	
	$INFILE = $ARGV[0];
	
	if ($#ARGV > 0) {
		$OUTFILE = $ARGV[1];
	}
}

sub open_files
{
	open(INFILE);
	if ($OUTFILE) {
		open(OUTFILE,">$OUTFILE");
		$use_stdout = 0;
	} else {
		$use_stdout = 1;
	}
}

# moved from migrate_hosts.pl
# lukeh 10/30/97
sub domain_expand
{
	local($first) = 1;
	local($dn);
	local(@namecomponents) = split(/\./, $_[0]);
	foreach $_ (@namecomponents) {
		$first = 0;
		$dn .= "dc=$_,";
	}
	$dn .= $DEFAULT_BASE;
	return $dn;
}

# case insensitive unique
sub uniq
{
	local($name) = shift(@_);
	local(@vec) = sort {uc($a) cmp uc($b)} @_;
	local(@ret);
	local($next, $last);
	foreach $next (@vec) {
		if ((uc($next) ne uc($last)) &&
			(uc($next) ne uc($name))) {
			push (@ret, $next);
		}
		$last = $next;
	}
	return @ret;
}

# concatenate naming context and 
# organizational base
sub getsuffix
{
	local($program) = shift(@_);
	local($nc);
	$program =~ s/^migrate_(.*)\.pl$/$1/;
	$nc = $NAMINGCONTEXT{$program};
	if ($nc eq "") {
		return $DEFAULT_BASE;
	} else {
		return $nc . ',' . $DEFAULT_BASE;
	}
}

1;

