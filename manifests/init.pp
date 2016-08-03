# check & set up configuration, and if desired, also the repo
class logentries (
  $account_key,
  $agent_key          = '',
  $datahub            = $::logentries::params::datahub,
  $register           = $::logentries::params::register,
  $use_server_config  = $::logentries::params::use_server_config,
  $manage_repos       = $::logentries::params::manage_repos,
  
) inherits logentries::params {
  if $account_key !~
    /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/ {
    fail "${account_key} argument doesn't look right"
  }
  if $agent_key != '' and $agent_key !~
    /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/ {
    fail "${agent_key} argument doesn't look right"
  }

  if $manage_repos {
    include logentries::repo
  }

  include logentries::agent
}
