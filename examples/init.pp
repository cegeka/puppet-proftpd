proftpd::instance::ftp { 'proftpd ftp vhost':
  ipaddress => '0.0.0.0',
  port      => '21',
  logdir    => '/data/logs',
}

proftpd::instance::user { 'foo user for ftp':
  ipaddress => '0.0.0.0',
  port      => '21',
  username  => 'foo',
  password  => 'FnLeyPMkwzkPE',
  comment   => 'Test FTP User'
}
