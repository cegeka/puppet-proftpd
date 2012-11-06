define proftpd::instance::ftp($logdir=undef) {

  require proftpd

  if ($logdir == undef) {
    fail("Proftpd::Instance::Ftp[${title}]: parameter logdir must be defined")
  }

  file { '/etc/proftpd/sites.d/ftp.conf':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/sites.d/ftp.conf.erb")
  }

  file { '/etc/proftpd/users.d/ftp.conf':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/users.d/ftp.conf.erb")
  }

}
