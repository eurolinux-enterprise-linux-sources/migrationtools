%define version 47
# disable the dependecy extractor, it would add
# Require: /usr/share/migrationtools/migrate_common.ph
%global __perl_requires /usr/bin/tail -n 0

Name:           migrationtools
Version:        %{version}
Release:        14%{?dist}
Summary:        Migration scripts for LDAP

Group:          System Environment/Daemons
License:        BSD
URL:            http://www.padl.com/OSS/MigrationTools.html
Source0:        http://www.padl.com/download/MigrationTools-%{version}.tar.gz
Source1:        migration-tools.txt
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
Requires:       perl, ldif2ldbm

Patch1: MigrationTools-38-instdir.patch
Patch2: MigrationTools-36-mktemp.patch
Patch3: MigrationTools-27-simple.patch
Patch4: MigrationTools-26-suffix.patch
Patch5: MigrationTools-46-schema.patch
Patch6: MigrationTools-45-noaliases.patch
Patch7: MigrationTools-46-ddp.patch
Patch8: MigrationTools-46-unique-hosts.patch
Patch9: MigrationTools-46-shadow-numbers.patch
Patch10: MigrationTools-46-gen-one-domain.patch
Patch11: MigrationTools-47-hosts.patch

%description
The MigrationTools are a set of Perl scripts for migrating users, groups,
aliases, hosts, netgroups, networks, protocols, RPCs, and services from 
existing nameservices (flat files, NIS, and NetInfo) to LDAP.

%prep
%setup -q -n MigrationTools-47

%patch1 -p1
%patch2 -p1
%patch3 -p1
%patch4 -p1
%patch5 -p1
%patch6 -p1
%patch7 -p1
%patch8 -p1
%patch9 -p1
%patch10 -p1
%patch11 -p1

%build
# nothing to build
cp %SOURCE1 .

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_datadir}/%{name}
install -m 755 migrate_* $RPM_BUILD_ROOT/%{_datadir}/%{name}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%attr(0755,root,root) %dir /%{_datadir}/%{name}
%attr(0644,root,root) /%{_datadir}/%{name}/*.ph
%attr(0755,root,root) /%{_datadir}/%{name}/*.pl
%attr(0755,root,root) /%{_datadir}/%{name}/*.sh
%doc README
%doc migration-tools.txt

%changelog
* Thu Aug  8 2013  <jsafrane@redhat.com> - 47-14
- Fixed importing /etc/hosts and /etc/services, duplicate entries
  are now skipped. (#916623)
- Added missing patches.

* Thu Feb 14 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 47-13
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild


* Fri Jul 20 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 47-12
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Mon Feb 20 2012 Jan Safranek <jsafrane@redhat.com> - 47-11
- re-added support for Fedora DS (when it provides ldif2ldbm)

* Fri Jan 13 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 47-10
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Tue Nov  8 2011 Jan Safranek <jsafrane@redhat.com> - 47-9
- Removed dependency on ldif2ldbm, nothing in Fedora provides it now

* Tue Feb 08 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 47-8
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Mon Feb 22 2010 Jan Safranek <jsafrane@redhat.com> 47-7
- Spec file cleanup

* Mon Feb 15 2010 Jan Safranek <jsafrane@redhat.com> 47-6
- Fixed package compilation problems (#565151)

* Wed Nov 11 2009 Jan Safranek <jsafrane@redhat.com> 47-5
- Removed unnecesary file dependency (#533968)

* Sat Jul 25 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 47-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Wed Feb 25 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 47-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Fri Aug 29 2008 Jan Safranek <jsafrane@redhat.com> 47-2
- added support for Fedora DS (when it provides ldif2ldbm)
- rediffed all patches to get rid of patch fuzz

* Thu Feb 28 2008 Jan Safranek <jsafrane@redhat.com> 47-1
- package carved out of openldap-servers

