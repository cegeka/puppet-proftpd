# == Class: proftpd::package
class proftpd::package {

  package { ['proftpd','proftpd-mysql','proftpd-postgresql','proftpd-ldap']:
    ensure => present
  }

}
