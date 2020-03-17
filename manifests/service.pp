# == Class: proftpd::service
class proftpd::service (
  $ensure = 'running',
  $enable = true
) {

  validate_re($ensure, '^running$|^stopped$|^unmanaged$')

  case $ensure {
    'running', 'stopped': {
      service { 'proftpd':
        ensure     => $ensure,
        enable     => $enable,
        hasstatus  => true,
        hasrestart => true
      }
    }
    'unmanaged': {
      notice('Class[proftpd::service]: service is currently not being managed')
    }
    default: {
      fail('Class[proftpd::service]: parameter ensure must be running, stopped or unmanaged')
    }
  }

}
