# == Define: proftpd::instance::user
#
# Used to configure a user for an ftp instance
#
# === Parameters
#
# [*ipaddress*]
#
# [*port*]
#
# [*username*]
#
# [*password*]
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

  Augeas {
    lens      => 'Passwd.lns',
    incl      => "/etc/proftpd/users.d/${vhost_name}.passwd",
    context   => "/files/etc/proftpd/users.d/${vhost_name}.passwd",
    load_path => "${settings::vardir}/lib/augeas/lenses"
  }

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
          changes   => [
            "set [last()+1] ${username}",
            "set ${username}/password ${password}",
            "set ${username}/uid ${uid_real}",
            "set ${username}/gid ${gid_real}",
            "set ${username}/name '${comment}'",
            "set ${username}/home ${home}",
            "set ${username}/shell /sbin/nologin"
          ],
          onlyif  => "match ${username} size == 0",
          require => Class['proftpd']
        }

        augeas { "${vhost_name}.passwd/${username}/modify" :
          changes   => [
            "set ${username}/password ${password}",
            "set ${username}/uid ${uid_real}",
            "set ${username}/gid ${gid_real}",
            "set ${username}/name '${comment}'",
            "set ${username}/home ${home}",
            "set ${username}/shell /sbin/nologin"
          ],
          onlyif  => "match ${username} size == 1",
          require => Class['proftpd']
        }
      }
    default: { notice('The given ensure parameter is not supported') }
  }

  @augeas { "${vhost_name}.passwd/${username}/rm" :
    changes   => [
      "rm ${username}",
    ],
    onlyif  => "match ${username} size > 0",
    require => Class['proftpd']
  }

}
