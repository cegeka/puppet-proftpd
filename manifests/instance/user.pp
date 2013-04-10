define proftpd::instance::user(
  $ipaddress=undef,
  $port=undef,
  $username=undef,
  $password=undef,
  $uid=undef,
  $gid=undef,
  $comment='',
  $home="/home/${username}",
  $ensure = present
) {

  include proftpd

  $vhost_name = "${ipaddress}_${port}"

  if ($uid == undef) {
    $uid_real = '5001'
  } else {
    $uid_real = $uid
  }
  if ($gid == undef) {
    $gid_real = '5001'
  } else {
    $gid_real = $gid
  }

  if $ensure in [ present, absent ] {
    $ensure_real = $ensure
  }
  else {
    fail("Proftpd::Instance::User[${username}]: parameter ensure must be present or absent")
  }

  case $ensure_real {
    'absent':
      {
        Augeas <| title == "${vhost_name}.passwd/${username}/rm" |>
      }
    'present':
      {
        augeas { "${vhost_name}.passwd/${username}/add" :
          lens    => 'Passwd.lns',
          incl    => "/etc/proftpd/users.d/${vhost_name}.passwd",
          context => "/files/etc/proftpd/users.d/${vhost_name}.passwd",
          changes => [
            "set [last()+1] ${username}",
            "set ${username}/password ${passwora}d",
            "set ${username}/uid ${uid_real}",
            "set ${username}/gid ${gid_real}",
            "set ${username}/name '${comment}'",
            "set ${username}/home ${home}",
            "set ${username}/shell /bin/false"
          ],
          onlyif  => "match ${username} size == 0",
          require => Class['proftpd']
        }

        augeas { "${vhost_name}.passwd/${username}/modify" :
          lens    => 'Passwd.lns',
          incl    => "/etc/proftpd/users.d/${vhost_name}.passwd",
          context => "/files/etc/proftpd/users.d/${vhost_name}.passwd",
          changes => [
            "set ${username}/password ${password}",
            "set ${username}/uid ${uid_real}",
            "set ${username}/gid ${gid_real}",
            "set ${username}/name '${comment}'",
            "set ${username}/home ${home}",
            "set ${username}/shell /bin/false"
          ],
          onlyif  => "match ${username} size == 1",
          require => Class['proftpd']
        }
      }
    default: { notice('The given ensure parameter is not supported') }
  }

  @augeas { "${vhost_name}.passwd/${username}/rm" :
    lens    => 'Passwd.lns',
    incl    => "/etc/proftpd/users.d/${vhost_name}.passwd",
    context => "/files/etc/proftpd/users.d/${vhost_name}.passwd",
    changes => [
      "rm ${username}",
    ],
    onlyif  => "match ${username} size > 0",
    require => Class['proftpd']
  }

}
