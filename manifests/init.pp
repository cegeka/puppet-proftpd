# Class: proftpd
#
# This module manages proftpd
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class proftpd {

  package { 'proftpd' :
    ensure => present
  }

  file { '/etc/proftpd.conf':
    owner   => root,
    group   => root,
    mode    => '0444',
    content => template("${module_name}/proftpd.erb"),
    require => Package['proftpd']
  }

  service { 'proftpd':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File['/etc/proftpd.conf']
  }

  user { 'proftpd':
    ensure     => present,
    uid        => '101',
    gid        => 'proftpd',
    shell      => '/bin/sh',
    comment    => 'ProFTPd user',
    home       => '/var/run/proftpd',
    managehome => false,
    require    => Group['proftpd']
  }

  group { 'proftpd':
    ensure => present,
    gid    => '1001'
  }

}
