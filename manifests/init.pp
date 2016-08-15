# == Class: gerritbot
#
class gerritbot(
  $ssh_rsa_key_contents    = undef,
  $ssh_rsa_pubkey_contents = undef,
) {
  include ::pip

  package { 'gerritbot':
    ensure   => present,  # Pip upgrade is not working
    provider => openstack_pip,
    require  => Class['pip'],
  }

  file { '/etc/gerritbot':
    ensure => directory,
  }

  file { '/var/log/gerritbot':
    ensure  => directory,
    group   => 'gerrit2',
    mode    => '0775',
    owner   => 'root',
    require => Package['gerritbot'],
  }

  if $ssh_rsa_key_contents != undef {
    file { '/home/gerrit2/.ssh/gerritbot_rsa':
      owner   => 'gerrit2',
      group   => 'gerrit2',
      mode    => '0600',
      content => $ssh_rsa_key_contents,
      replace => true,
      require => File['/home/gerrit2/.ssh']
    }
  }

  if $ssh_rsa_pubkey_contents != undef {
    file { '/home/gerrit2/.ssh/gerritbot_rsa.pub':
      owner   => 'gerrit2',
      group   => 'gerrit2',
      mode    => '0644',
      content => $ssh_rsa_pubkey_contents,
      replace => true,
      require => File['/home/gerrit2/.ssh']
    }
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
