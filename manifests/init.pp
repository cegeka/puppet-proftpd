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

  package { 'proftpd':
    ensure => present
  }

  file { '/etc/proftpd':
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    require => Package['proftpd']
  }

  file { [ '/etc/proftpd/sites.d', '/etc/proftpd/users.d' ]:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0755',
    require => File['/etc/proftpd']
  }

  file { '/etc/proftpd.conf':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/proftpd.conf.erb"),
    require => Package['proftpd']
  }

  file { '/etc/proftpd/modules.conf':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/modules.conf.erb"),
    require => File['/etc/proftpd']
  }

  service { 'proftpd':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => [ File['/etc/proftpd.conf'], File['/etc/proftpd/modules.conf'] ]
  }

  user { 'proftpd':
    ensure     => present,
    uid        => '5001',
    gid        => 'proftpd',
    shell      => '/bin/sh',
    comment    => 'ProFTPd user',
    home       => '/var/run/proftpd',
    managehome => false,
    require    => Group['proftpd']
  }

  group { 'proftpd':
    ensure => present,
    gid    => '5001'
  }

}
