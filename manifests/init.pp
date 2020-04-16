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
  $proftpd_user = 'proftpd',
  $proftpd_user_id = '5001',
  $proftpd_group = 'proftpd',
  $proftpd_group_id = '5001',
  $service_state = 'running',
  $service_enable = true,
  $max_instances = 20
) {

  include stdlib

  anchor { 'proftpd::begin': }
  anchor { 'proftpd::end': }

  class { 'proftpd::package': }

  class { 'proftpd::config':
    manage_proftpd_conf => $manage_proftpd_conf
  }

  class { 'proftpd::service':
    ensure => $service_state,
    enable => $service_enable
  }

  Anchor['proftpd::begin'] -> Class['Proftpd::Package'] -> Class['Proftpd::Config'] ~> Class['Proftpd::Service'] -> Anchor['proftpd::end']

}
