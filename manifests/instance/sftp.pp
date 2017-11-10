# Type: proftpd::instance::sftp - creates an SFTP server instance
define proftpd::instance::sftp(
  $ensure=present,
  $ipaddress='0.0.0.0',
  $port='22',
  $server_name='sFTP server',
  $server_ident='sFTP server ready',
  $server_admin='root@server',
  $logdir='/var/log',
  $max_clients='45',
  $max_loginattempts='3',
  $default_root='~',
  $allowoverwrite='on',
  $sftprekey=undef,
  $timeoutidle=undef,
  $sftp_client_match=[],
  $authentication='file',
  $mysql_host=undef,
  $mysql_user=undef,
  $mysql_pass=undef,
  $mysql_db=undef,
  $manage_proftpd_conf=undef,
  $enable_auto_expiry=false,
  $expire_days='30'
) {

  if ($manage_proftpd_conf != undef) {
    class { 'proftpd':
      manage_proftpd_conf => $manage_proftpd_conf
    }
  } else {
    include 'proftpd'
  }

  $protocol = 'sftp'

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

  $vhost_name = "${ipaddress}_${port}"

  if ! defined(File["${logdir}/proftpd"]) {
    file { "${logdir}/proftpd":
      ensure  => directory,
      owner   => $proftpd::proftpd_user,
      group   => $proftpd::proftpd_group,
      mode    => '0750',

    }
  }

  if ! defined(File["${logdir}/proftpd/sftp"]) {
    file { "${logdir}/proftpd/sftp":
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
    content => template("${module_name}/sites.d/sftp.conf.erb"),
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
      replace => false
    }

    file { "/etc/proftpd/users.d/${vhost_name}.group":
      ensure  => file,
      owner   => 'root',
      group   => $proftpd::proftpd_group,
      mode    => '0640',
      replace => false
    }
  }

}
