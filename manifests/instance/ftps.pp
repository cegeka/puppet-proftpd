# == Define: proftpd::instance::ftps
#
# Used to configure an ftps instance
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
# === Authors
#
# === Copyright
#
# MIT License
#
# Copyright (c) 2020 Cegeka
#
define proftpd::instance::ftps(
  $ipaddress=['0.0.0.0'],
  $first_ip=Array($ipaddress,true)[0],
  $port='990',
  $protocol='ftps',
  $server_name='FTP server',
  $server_ident='FTP server ready',
  $server_admin='root@server',
  $logdir='/var/log',
  $max_clients='45',
  $max_loginattempts='3',
  $default_root='~',
  $allowoverwrite='on',
  $passive_ports='60000 65535',
  $custom_logformat=[],
  $authentication='file',
  $mysql_host=undef,
  $mysql_user=undef,
  $mysql_pass=undef,
  $mysql_db=undef,
  $manage_proftpd_conf=undef,
  $enable_auto_expiry=false,
  $expire_days='30',
  $tls_enabled=true,
  $tls_required='auth+data',
  $tls_ca_cert='/etc/pki/tls/certs/ca-bundle.crt',
  $tls_rsa_key=undef,
  $tls_rsa_cert=undef,
  $tls_rsa_chain=undef,
  $tls_cipher='EECDH+AESGCM:EDH+AESGCM',
  $tls_protocol='TLSv1.2',
  $tls_options='NoCertRequest',
  $tls_renegotiate='required off',
  $readonly_enabled=false,
  $readonly_users=[],
  $readonly_groups=['readonly']
) {

  if ($logdir == undef) {
    fail("Proftpd::Instance::Ftp[${title}]: parameter logdir must be defined")
  }

  if ($tls_enabled != false) and (($tls_rsa_key == undef) or ($tls_rsa_cert == undef) or ($tls_rsa_chain == undef)) {
    fail("Proftpd::Instance::Ftp[${title}]: tls enabled, but key, certificate or chain are missing")
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

  $vhost_name   = "${real_first_ip}_${port}"
  $tls_log      = "${logdir}/proftpd/${protocol}/${real_first_ip}_${port}_tlslog"
  $transfer_log = "${logdir}/proftpd/${protocol}/${real_first_ip}_${port}_xferlog"
  $extended_log = "${logdir}/proftpd/${protocol}/${real_first_ip}_${port}_commands.log"

  if ! defined(File["${logdir}/proftpd"]) {
    file { "${logdir}/proftpd":
      ensure  => directory,
      owner   => 'proftpd',
      group   => 'proftpd',
    }
  }

  if ! defined(File["${logdir}/proftpd/${protocol}"]) {
    file { "${logdir}/proftpd/${protocol}":
      ensure  => directory,
      owner   => 'proftpd',
      group   => 'proftpd',
      require => File["${logdir}/proftpd"],
      notify  => Class['proftpd::service']
    }
  }

  file { "/etc/proftpd/sites.d/${vhost_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0640',
    content => template("${module_name}/sites.d/${protocol}.conf.erb"),
    notify  => Class['proftpd::service']
  }

  file { "/etc/proftpd/users.d/${vhost_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0640',
    content => template("${module_name}/users.d/users.conf.erb"),
    notify  => Class['proftpd::service']
  }

  if $authentication == 'file' {
    file { "/etc/proftpd/users.d/${vhost_name}.passwd":
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0640',
      replace => false,
      notify  => Class['proftpd::service']
    }

    file { "/etc/proftpd/users.d/${vhost_name}.group":
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0640',
      replace => false,
      notify  => Class['proftpd::service']
    }
  }

}
