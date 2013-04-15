define proftpd::instance::group(
  $ipaddress=undef,
  $port=undef,
  $group=undef,
  $gid=undef,
  $ensure = present
) {

  include proftpd

  $vhost_name = "${ipaddress}_${port}"

  if ($gid == undef) {
    $gid_real = '5001'
  } else {
    $gid_real = $gid
  }

  if $ensure in [ present, absent ] {
    $ensure_real = $ensure
  }
  else {
    fail("Proftpd::Instance::Group[${group}]: parameter ensure must be present or absent")
  }

  case $ensure_real {
    'absent':
      {
        Augeas <| title == "${vhost_name}.group/${group}/rm" |>
      }
    'present':
      {
        augeas { "${vhost_name}.group/${group}/add" :
          lens    => 'Group.lns',
          incl    => "/etc/proftpd/users.d/${vhost_name}.group",
          context => "/files/etc/proftpd/users.d/${vhost_name}.group",
          changes => [
            "set [last()+1] ${group}",
            "set ${group}/password x",
            "set ${group}/gid ${gid_real}"
          ],
          onlyif  => "match ${group} size == 0",
          require => Class['proftpd']
        }

        augeas { "${vhost_name}.group/${group}/modify" :
          lens    => 'Group.lns',
          incl    => "/etc/proftpd/users.d/${vhost_name}.group",
          context => "/files/etc/proftpd/users.d/${vhost_name}.group",
          changes => [
            "set ${group}/password x",
            "set ${group}/gid ${gid_real}"
          ],
          onlyif  => "match ${group} size == 1",
          require => Class['proftpd']
        }
      }
    default: { notice('The given ensure parameter is not supported') }
  }

  @augeas { "${vhost_name}.group/${group}/rm" :
    lens    => 'Group.lns',
    incl    => "/etc/proftpd/users.d/${vhost_name}.group",
    context => "/files/etc/proftpd/users.d/${vhost_name}.group",
    changes => [
      "rm ${group}",
    ],
    onlyif  => "match ${group} size > 0",
    require => Class['proftpd']
  }

}
