# follow a given logfile
define logentries::agent::follow (
  $path         = undef,
  $token        = undef,
  $destination  = undef,
  $multilog     = undef,
  $format       = undef,
) {
  include logentries::agent

  # use title as path if there's no path argument
  if $path {
    $my_path = $path
  } else {
    $my_path = $title
  }

  # convert filename/title to something that can be a filename in any case
  # colissions should be rare
  $clean_title = regsubst($title, '[^0-9A-Za-z.\-]', '_', 'G')
  $confd_path = "/etc/le/conf.d/${clean_title}"

  # Check if we need to use a wildcard in path
  if $multilog {
    $use_multilog = '--multilog '
  } else {
    $use_multilog = ''
  }

  if $logentries::params::use_server_config == true {
    if $token {
      fail 'can not use tokens with server_side_config=true'
    }

    exec { "/usr/bin/le follow ${my_path} ${use_multilog}--name=${title}":
      command => "/usr/bin/le follow '${my_path}' ${use_multilog}--name='${title}' && touch ${confd_path}.followed",
      creates => "${confd_path}.followed",
      require => Package['logentries-daemon'],
    }
  } else {
    if $token and $destination {
      $token_or_destination = "destination = ${::hostname}${my_path}"
    } elsif $destination {
      # FIXME: maybe make sure there's a / in there?
      $token_or_destination = "destination = ${destination}"
    } elsif $token {
      # FIXME: token should be regex checked
      $token_or_destination = "token = ${token}"
    } else {
      fail 'can not specify both, token and destination'
    }

    file { "${confd_path}.conf":
      content => template('logentries/autoscale.conf.erb'),
      require => File['/etc/le/conf.d'],
      notify  => Service['logentries'],
    }
  }

  case $format {
    'line_only': {
      logentries::agent::format { $name:
        function_name => "  \'${name}\' : lambda hostname, log_name, token: Form_Line_Only(hostname, log_name, token).format_line,\n",
      }
    }
    default: { }
  }
}
