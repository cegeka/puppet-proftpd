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
class proftpd (
  $manage_proftpd_conf = false,
  $proftpd_user  = 'proftpd',
  $proftpd_group = 'proftpd',
  $ensure = 'running'
) {

  include stdlib

  validate_re($ensure, '^running$|^stopped$|^unmanaged$')

  package { ['proftpd','proftpd-mysql','proftpd-postgresql','proftpd-ldap']:
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
    replace => $manage_proftpd_conf,
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

  case $ensure {
    'running', 'stopped': {
      service { 'proftpd':
        ensure     => $ensure,
        hasstatus  => true,
        hasrestart => true,
        subscribe  => [ File['/etc/proftpd.conf'], File['/etc/proftpd/modules.conf'] ]
      }
    }
    'unmanaged': {
      notice('Class[proftpd]: service is currently not being managed')
    }
    default: {
      fail('Class[proftpd]: parameter ensure must be running, stopped or unmanaged')
    }
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
