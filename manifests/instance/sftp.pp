define proftpd::instance::sftp(
  $ensure=present,
  $ipaddress='0.0.0.0',
  $port='22',
  $server_name='sFTP server',
  $server_ident='sFTP server ready',
  $server_admin='root@server',
  $logdir=undef,
  $max_clients='45',
  $max_loginattempts='3',
  $default_root='~',
  $allowoverwrite='on',
) {

  include proftpd

  if ($logdir == undef) {
    fail("Proftpd::Instance::Ftp[${title}]: parameter logdir must be defined")
  }

  $vhost_name = "${ipaddress}_${port}"

  if ! defined(File["${logdir}/proftpd"]) {
    file { "${logdir}/proftpd":
      ensure  => directory,
      owner   => 'proftpd',
      group   => 'proftpd',
    }
  }

  file { "${logdir}/proftpd/sftp":
    ensure  => directory,
    owner   => 'proftpd',
    group   => 'proftpd',
    require => File["${logdir}/proftpd"],
    notify  => Service['proftpd']
  }

  file { "/etc/proftpd/sites.d/${vhost_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/sites.d/sftp.conf.erb"),
    notify  => Service['proftpd']
  }

  file { "/etc/proftpd/users.d/${vhost_name}.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/users.d/users.conf.erb"),
    notify  => Service['proftpd']
  }

  file { "/etc/proftpd/users.d/${vhost_name}.passwd":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    replace => false
  }

  file { "/etc/proftpd/users.d/${vhost_name}.group":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    replace => false
  }

}
