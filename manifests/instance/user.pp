define proftpd::instance::user($ipaddress=undef, $port=undef, $username=undef, $password=undef, $comment='', $home="/home/$username", $ensure = present) {

  $vhost_name = "${ipaddress}_${port}"

  if $ensure in [ present, absent ] {
    $ensure_real = $ensure
  }
  else {
    fail("Proftpd::Instance::User[${username}]: parameter ensure must be present or absent")
  }

  case $ensure_real {
    'absent':
      {
        Augeas <| title == "$vhost_name.passwd/$username/rm" |>
      }
    'present':
      {

        Augeas <| title == "$vhost_name.passwd/$username/rm" |>

        augeas { "$vhost_name.passwd/$username/add" :
          lens    => 'Passwd.lns',
          incl    => "/etc/proftpd/users.d/${vhost_name}.passwd",
          context => "/files/etc/proftpd/users.d/${vhost_name}.passwd",
          changes => [
            "set [last()+1] $username",
            "set $username/password $password",
            "set $username/uid 1001",
            "set $username/gid 1001",
            "set $username/name $comment",
            "set $username/home $home",
            "set $username/shell /bin/false"
          ],
          onlyif  => "match $username size == 0",
          require => Augeas["$vhost_name.passwd/$username/rm"]
        }
      }
    default: { notice('The given ensure parameter is not supported') }
  }

  @augeas { "$vhost_name.passwd/$username/rm" :
    lens    => 'Passwd.lns',
    incl    => "/etc/proftpd/users.d/${vhost_name}.passwd",
    context => "/files/etc/proftpd/users.d/${vhost_name}.passwd",
    changes => [
      "rm $username",
    ],
    onlyif  => "match $username size > 0"
  }

}
