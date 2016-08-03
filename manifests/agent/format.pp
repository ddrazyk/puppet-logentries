# follow a given logfile
define logentries::agent::format (
  $formatters_file  = $::logentries::params::formatters_file,
  $formatter_name   = $name,
  $function_name    = '',
) {

  include logentries::helpers::formatter

  concat::fragment { "${formatter_name}_function":
    target          =>  $formatters_file,
    content         =>  $function_name,
    order           =>  '51',
    notify          =>  Service['logentries'],
  }

  include logentries::agent
}
