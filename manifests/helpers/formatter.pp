# Creates the base skeleton files for the formatter type to be used

  class logentries::helpers::formatter (
    $formatters_dir          = $::logentries::params::formatters_dir,
    $formatters_file         = $::logentries::params::formatters_file,
  ) inherits logentries::params {

    concat { $formatters_file:
      ensure  =>  present,
      owner   =>  'root',
      group   =>  'root',
      mode    =>  '0644',
    }

    concat::fragment { 'formatter_form':
      target          =>  $formatters_file,
      content         =>  template('logentries/formatters/formatters_form_line_only.py.erb'),
      order           =>  '01',
    }

    # This will create the section where we can subscribe to predefined formatters
    concat::fragment{ 'formatter_header':
      target  => $formatters_file,
      content => "\nformatters = { \n",
      order   => '50'
    }

    concat::fragment{ 'formatter_footer':
      target  => $formatters_file,
      content => "\n}\n",
      order   => '99'
    }

  }
