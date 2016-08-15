define gerritbot::bot ($channel_file,
  $password,
  $server,
  $user,
  $nick = $title,
  $vhost_name = $::fqdn) {

  include ::gerritbot

  file { "/etc/init.d/gerritbot-${name}":
    ensure  => present,
    group   => 'root',
    mode    => '0555',
    owner   => 'root',
    content => template('gerritbot/gerritbot.init.erb'),
    require => Class['gerritbot']
  }

  service { "gerritbot-${name}":
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => File["/etc/init.d/gerritbot-${nick}"],
    subscribe  => [
      Package['gerritbot'],
      File["/etc/gerritbot/gerritbot-${name}.config"],
      File["/etc/gerritbot/channel_config-${name}.yaml"],
    ],
  }

  file { "/etc/gerritbot/channel_config-${name}.yaml":
    ensure  => present,
    group   => 'gerrit2',
    mode    => '0440',
    owner   => 'root',
    replace => true,
    require => Class['gerritbot'],
    content => $channel_file,
  }

  file { "/etc/gerritbot/logging-${name}.config":
    ensure  => present,
    group   => 'gerrit2',
    mode    => '0440',
    owner   => 'root',
    replace => true,
    require => Class['gerritbot'],
    content => template('gerritbot/logging.config.erb'),
  }

  file { "/etc/gerritbot/gerritbot-${name}.config":
    ensure  => present,
    group   => 'gerrit2',
    mode    => '0440',
    owner   => 'root',
    replace => true,
    require => Class['gerritbot'],
    content => template('gerritbot/gerritbot.config.erb')
  }
}
