# == Class: gerritbot
#
class gerritbot(
  $channel_file,
  $nick,
  $password,
  $server,
  $user,
  $ssh_rsa_key_contents    = undef,
  $ssh_rsa_pubkey_contents = undef,
  $vhost_name              = $::fqdn,
  # Where to fetch the git repository from
  $git_source_repo = 'https://git.openstack.org/openstack-infra/gerritbot',
  # Destination directory for the git repository
  $git_root_dir = '/opt/gerritbot',
  # The git branch
  $git_revision_branch = 'master',

) {
  include ::pip

  # Clone the git repository
  vcsrepo { $git_root_dir:
    ensure   => latest,
    provider => git,
    revision => $git_revision_branch,
    source   => $git_source_repo,
    require  => Package['git']
  }

  # Install gerritbot using pip
  exec { 'install-gerritbot' :
    command     => "pip install ${git_source_repo}",
    path        => '/usr/local/bin:/usr/bin:/bin/',
    refreshonly => true,
    subscribe   => Vcsrepo[$git_root_dir],
    notify      => Service['gerritbot'],
  }

  file { '/etc/init.d/gerritbot':
    ensure  => present,
    group   => 'root',
    mode    => '0555',
    owner   => 'root',
    require => Package['gerritbot'],
    source  => 'puppet:///modules/gerritbot/gerritbot.init',
  }

  service { 'gerritbot':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => File['/etc/init.d/gerritbot'],
    subscribe  => [
      Package['gerritbot'],
      File['/etc/gerritbot/gerritbot.config'],
      File['/etc/gerritbot/channel_config.yaml'],
    ],
  }

  file { '/etc/gerritbot':
    ensure => directory,
  }

  file { '/var/log/gerritbot':
    ensure => directory,
    group  => 'gerrit2',
    mode   => '0775',
    owner  => 'root',
  }

  file { '/etc/gerritbot/channel_config.yaml':
    ensure  => present,
    group   => 'gerrit2',
    mode    => '0440',
    owner   => 'root',
    replace => true,
    require => User['gerrit2'],
    source  => $channel_file,
  }

  file { '/etc/gerritbot/logging.config':
    ensure  => present,
    group   => 'gerrit2',
    mode    => '0440',
    owner   => 'root',
    replace => true,
    require => User['gerrit2'],
    source  => 'puppet:///modules/gerritbot/logging.config',
  }

  file { '/etc/gerritbot/gerritbot.config':
    ensure  => present,
    content => template('gerritbot/gerritbot.config.erb'),
    group   => 'gerrit2',
    mode    => '0440',
    owner   => 'root',
    replace => true,
    require => User['gerrit2'],
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
