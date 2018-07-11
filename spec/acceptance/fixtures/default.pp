$gerritbot_ssh_rsa_pubkey_contents = 'ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFnYsbHrGl99in5doo1uy+V3N3ayR4J0/sJprK+7E8exDwAGe1vZmUftjZ6uMi4RckxuFTuVJdxrFvTLEQpNrSU='

$gerritbot_ssh_rsa_key_contents = 'MHcCAQEEIJUIOR4hPwqds8ESewPHm+r5ejSqjuFjBfVa7jQTH99QoAoGCCqGSM49
AwEHoUQDQgAEWdixsesaX32Kfl2ijW7L5Xc3drJHgnT+wmmsr7sTx7EPAAZ7W9mZ
R+2Nnq4yLhFyTG4VO5Ul3GsW9MsRCk2tJQ==
-----END EC PRIVATE KEY-----'

file { '/etc/gerritbot-channels.yaml':
  ensure  => present,
  content => '',
}

include gerrit::user

file { '/home/gerrit2/.ssh':
  ensure  => directory,
  owner   => 'gerrit2',
  mode    => '0700',
  require => User['gerrit2'],
}

class { 'gerritbot':
  nick                    => 'openstackgerrit',
  password                => 'gerritbot_password',
  server                  => 'irc.freenode.net',
  user                    => 'gerritbot',
  vhost_name              => 'review.openstack.org',
  ssh_rsa_key_contents    => $gerritbot_ssh_rsa_key_contents,
  ssh_rsa_pubkey_contents => $gerritbot_ssh_rsa_pubkey_contents,
  channel_file            => '/etc/gerritbot-channels.yaml',
  require                 => File['/etc/gerritbot-channels.yaml',
}
