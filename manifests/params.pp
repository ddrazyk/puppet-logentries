# namespace for configuration
class logentries::params {
  $agent_key          = ''
  $datahub            = ''
  $use_server_config  = false
  $register           = false
  $configured         = true
  $manage_repos       = true
  $v1_metrics         = false
  $formatters_dir     = '/etc/le/le_formatters.d'
  $formatters_file    = '/etc/le/le_formatters.d/formatters.py'
  $filters_dir        = '/etc/le/le_filters.d'
  $filters_file       = '/etc/le/le_filters.d/filters.py'
}
