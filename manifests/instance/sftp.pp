# == Define: proftpd::instance::sftp
#
# Used to configure an sftp instance
#
# === Parameters
#
# [*ipaddress*]
#
# [*port*]
#
# [*server_name*]
#
# [*server_ident*]
#
# ...
#
# === Examples
#
# class { 'proftpd':
#   manage_proftpd_conf => true,
#   proftpd_user        => proftpd,
#   proftpd_group       => proftpd,
#   service_state       => running,
#   service_enable      => enabled,
#   max_instances       => 10
# }
#
# Hiera based instance configuration:
#
# proftpd::instance::ftp:
#   'localhost':
#     ipaddress: '192.168.33.10'
#     port: '21'
#     server_name: 'FTP server'
#     server_ident: 'FTP server ready'
#     server_admin: 'root@server'
#     max_clients: '45'
#     max_loginattempts: '3'
#     default_root: '~'
#     allowoverwrite: 'on'
#     passive_ports: '60000 65535'
#     authentication: 'file'
#     enable_auto_expiry: false
#     expire_days: '30'
#     sftp_hostkey:
#       - /etc/ssh/ssh_host_ecdsa_key
#       - /etc/ssh/ssh_host_rsa_ke
#
# === Authors
#
# Computing <computing@cegeka.com>
# Fabian Dammekens <fabian.dammekens@cegeka.com>
##
# === Copyright
#
# MIT License
#
# Copyright (c) 2020 Cegeka
#
define proftpd::instance::sftp(
  $ensure=present,
  $ipaddress=['0.0.0.0'],
  $first_ip=Array($ipaddress,true)[0],
  $port='22',
  $protocol='sftp',
  $server_name='sFTP server',
  $server_ident='sFTP server ready',
  $server_admin='root@server',
  $logdir='/var/log',
  $max_clients='45',
  $max_loginattempts='3',
  $default_root='~',
  $allowoverwrite='on',
  $sftprekey=undef,
  $sftp_hostkey=['/etc/ssh/ssh_host_rsa_key'],
  $sftp_hostkey_insecure=false,
  $timeoutidle=undef,
  $sftp_client_match=[],
  $custom_logformat=[],
  $authentication='file',
  $mysql_host=undef,
  $mysql_user=undef,
  $mysql_pass=undef,
  $mysql_db=undef,
  $manage_proftpd_conf=undef,
  $enable_auto_expiry=false,
  $expire_days='30',
  $hidden_store=false,
  $hidden_store_dirs=[],
  $readonly_enabled=false,
  $readonly_users=[],
  $readonly_groups=['readonly'],
  $extended_log = "${logdir}/proftpd/${protocol}/${real_first_ip}_${port}_commands.log"
) {

  if ($logdir == undef) {
    fail("Proftpd::Instance::Ftp[${title}]: parameter logdir must be defined")
  }

  if ($sftprekey != undef) {
    if $sftprekey !~ /(?i-mx:^none\s*$|^required\s*$|^required\s+\d+\s+\d+\s*$|^required\s+\d+\s+\d+\s+\d+\s*$)/ {
      fail("Proftpd::Instance::Sftp[${title}]: usage: SFTPRekey 'none'|'required' [[interval (in seconds) bytes (in MB)] timeout (in seconds)]")
    }
  }

  if ($timeoutidle != undef) {
    if $timeoutidle !~ /(?-mx:^\s*\d+\s*$)/ {
      fail("Proftpd::Instance::Sftp[${title}]: usage: TimeoutIdle [timeout (in seconds)]")
    }
  }

  if ($ipaddress =~ Array) {
    $real_ipaddress = $ipaddress.map |$ip| {
      if (! empty($ip)) {
        "${ip}"
      } else {
        '127.0.0.1'
      }
    }
  } else {
    if (!empty($ipaddress)) {
      $real_ipaddress = $ipaddress
    } else {
      $real_ipaddress = '127.0.0.1'
    }
  }

  $real_first_ip = assert_type(String[1], $first_ip) |$expected, $actual| {
    warning( "The IP should be of type \'${expected}\', not \'${actual}\': \'${first_ip}\'. Using '127.0.0.1'." )
    '127.0.0.1'
  }

  $vhost_name = "${real_first_ip}_${port}"
  $transfer_log = "${logdir}/proftpd/${protocol}/${real_first_ip}_${port}_xferlog"

  if ! defined(File["${logdir}/proftpd"]) {
    file { "${logdir}/proftpd":
      ensure  => directory,
      owner   => $proftpd::proftpd_user,
      group   => $proftpd::proftpd_group,
      mode    => '0750',

    }
  }

  if ! defined(File["${logdir}/proftpd/${protocol}"]) {
    file { "${logdir}/proftpd/${protocol}":
      ensure  => directory,
      owner   => $proftpd::proftpd_user,
      group   => $proftpd::proftpd_group,
      mode    => '0750',
      require => File["${logdir}/proftpd"],
      notify  => Class['proftpd::service']
    }
  }

  file { "/etc/proftpd/sites.d/${vhost_name}.conf":
    ensure  => file,
    owner   => 'root',
    group   => $proftpd::proftpd_group,
    mode    => '0640',
    content => template("${module_name}/sites.d/${protocol}.conf.erb"),
    notify  => Class['proftpd::service']
  }

  file { "/etc/proftpd/users.d/${vhost_name}.conf":
    ensure  => file,
    owner   => 'root',
    group   => $proftpd::proftpd_group,
    mode    => '0640',
    content => template("${module_name}/users.d/users.conf.erb"),
    notify  => Class['proftpd::service']
  }

  if $authentication == 'file' {
    file { "/etc/proftpd/users.d/${vhost_name}.passwd":
      ensure  => file,
      owner   => 'root',
      group   => $proftpd::proftpd_group,
      mode    => '0640',
      replace => false,
      notify  => Class['proftpd::service']
    }

    file { "/etc/proftpd/users.d/${vhost_name}.group":
      ensure  => file,
      owner   => 'root',
      group   => $proftpd::proftpd_group,
      mode    => '0640',
      replace => false,
      notify  => Class['proftpd::service']
    }

    file { $sftp_hostkey :
      ensure => file,
      mode   => '0600',
      notify => Class['proftpd::service']
    }
  }

}
