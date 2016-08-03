# install, initialize, register and configure the agent
class logentries::agent (
  $account_key             = $::logentries::account_key,
  $agent_key               = $::logentries::agent_key,
  $v1_metrics              = $::logentries::params::v1_metrics,
  $use_server_config       = $::logentries::params::use_server_config,
  $formatters_dir          = $::logentries::params::formatters_dir,
  $formatters_file         = $::logentries::params::formatters_file,
  $filters_dir             = $::logentries::params::filters_dir,
  $filters_file            = $::logentries::params::filters_file,

  ) inherits logentries::params {

  if $::logentries::params::configured == undef {
    fail 'logentries class not configured'
  }

  Class['logentries::params'] -> Class['logentries::agent']
  package {['logentries', 'logentries-daemon']:
    ensure => latest,
  }

  # Create all the configuration directories
  file {
    [
      '/etc/le',
      '/etc/le/conf.d',
      $formatters_dir,
      $filters_dir,
    ]:
        ensure  => directory,
        require => Package['logentries-daemon'
    ],
  }

  # Create all the configuration skeleton files
  file {
    [

      "${formatters_dir}/__init__.py",
      "${filters_dir}/__init__.py",
    ]:
    ensure  => present,
    require => Package['logentries-daemon'],
  }

  $use_server_config_arg = $logentries::params::use_server_config ? {
    true  => '',
    false => '--pull-server-side-config=false ',
  }

  if $logentries::params::datahub != '' {
    $datahub_config_arg = "--datahub=${logentries::params::datahub} "
  } else {
    $datahub_config_arg = ''
  }

  # if we have an agent key, use le init and reload the daemon
  if $logentries::params::agent_key =~
    /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/ {
    exec { '/usr/bin/le init':
      command => "/usr/bin/le init ${use_server_config_arg}${datahub_config_arg} --account-key=${logentries::params::account_key} --host-key=${logentries::params::agent_key}",
      creates => '/etc/le/config',
      require => Package['logentries-daemon'],
      notify  => Service['logentries'],
    }
  } elsif ( $logentries::params::agent_key == '' ) and ( $logentries::params::register == false ) {
    # Basic configuration which only sends logs. Does not register host in UI. Useful with auto scaling. Has to be used with agent::follow and destination parameter.
    file { '/etc/le/config':
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      content => template('logentries/config.erb'),
      require => Package['logentries-daemon'],
      notify  => Service['logentries'],
    }
  } else {
    exec { '/usr/bin/le register':
      command => "/usr/bin/le register ${use_server_config_arg}${datahub_config_arg} --account-key=${logentries::params::account_key}",
      creates => '/etc/le/config',
      require => Package['logentries-daemon'],
    }
  }

  service {'logentries':
    ensure  => running,
    require => Package['logentries-daemon'],
  }
}
