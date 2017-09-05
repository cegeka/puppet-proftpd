require 'spec_helper_acceptance'

describe 'proftpd' do

  describe 'running puppet code' do
    it 'should work with no errors' do
      pp = <<-EOS

        include 'yum'
        include 'profile::package_management'
        include stdlib::stages 

        class { 'cegekarepos' : stage => 'setup_repo' }
        
        Yum::Repo <| title == 'epel' |>

        proftpd::instance::ftp { 'proftpd ftp vhost':
          ipaddress => '0.0.0.0',
          port      => '21',
          logdir    => '/var/log/',
        }
        proftpd::instance::sftp { 'proftpd sftp vhost':
          ipaddress => '0.0.0.0',
          port      => '2222',
          logdir    => '/var/log/',
        }
        proftpd::instance::ftps { 'proftpd ftps vhost':
          ipaddress => '0.0.0.0',
          port      => '990',
          logdir    => '/var/log/',
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe port(21) do
      it { is_expected.to be_listening }
    end
    describe port(2222) do
      it { is_expected.to be_listening }
    end

    describe service('proftpd') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
