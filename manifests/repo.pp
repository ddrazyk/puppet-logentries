# Install the correct repository for the current OS/architecture
class logentries::repo {
  $key = "-----BEGIN PGP PUBLIC KEY BLOCK-----\nVersion: GnuPG v1\n\nmQENBE16w8YBCAC0U7hdeaZ99rZtTa81Au8bQPbDh016FvLSRom8gvUSLiAzPtAE\nF+xQE04hALWIMGUBaYdq0HVPa05k0shf5aOCJabmQaBNJdKtSC5Uj3VTA00NHTIs\n5ZIjrIngSzNvgPVBcAfNwQuPLHbQl2O1b7T6jR6p+W5a0tBuWnM+4/k+JelUc4t1\ndSehytant2SovIwtRLFY+hsnkrEVr4Rqbg3mwzc8itJJulGlR9+I7025KWIDzZfi\nkGjbCkbXmToewWa2smSzGLMr0s1y+AV36WO/qIFTeDEWhwmKTopXXCi3WrRIlXJz\nyQJ0e4Umt5WUxoUrw30xP/O2eH+V+YjU5lSzABEBAAG0LExvZ2VudHJpZXMgUmVs\nZWFzZSBLZXkgPGluZm9AbG9nZW50cmllcy5jb20+iQE4BBMBAgAiAhsDBgsJCAcD\nAgYVCAIJCgsEFgIDAQIeAQIXgAUCVuFl+AAKCRClJwKJxDx5rbHaCACHMuf7m6ye\nEnfL1iZ4JpNJarjpA5DJU1LZEGhGlafTg4nonZTYhhbRiIGQpUqrBS3+J/5PTsF2\ndbcGkeEDDyk6HTN3Z1Fa3XFVt1s+fW+1ZIoXD1JDcMuRPnqalecUFQoEmFOLE8Nu\nJNKuAGGEosXBy6l9p5AJmPZVhde1roPqSwCnV0/rUTaViG8+au4lQoq4DG82xEla\neYJK98PdsPucoxwDHTdI1L+QoJGlQf3u3NESfyLzD1O0T/tAQbVqN+30KGZDe6fI\n4IqAOvl5pHzw7wovblHOwmhjV9QgndBKJUkOLKiKgfydKzaClDDGTsnVlD8FpPLa\nCfMsVOiGTBa7uQENBE16w8YBCADHxn/lsy89Qs/gnNg3VUK8aVE2GqghbzQ3DLPb\nvNrKIhQsvOyiVgRsPiF0N8SbdX5HngdjBbhdiJyQnKmqvs1mma2U3bl6Sl+IAAnG\nbtgg6N+ggLd1WXfvXVZcgIJeEX8lRaJK7qe8rxv45s3f0v0XrmEZTKrm2TbH20/n\nr1prmNbCZJNKugak2lwuEtoT5ht3kFrY7FFixKfd0o/70rw6c9JfnRHTh6pgPkuj\nUrW3mv1z/HtbLk0xUY/DHR43UW4+0pmGAQpz6Dw7C+OZKscU+8HwM3w16R1Oj5hH\nbW+gkau+du4YK0pR5X0jUIMQTY/l9NuUB2niJRnNAhcjaXEbABEBAAGJAR8EGAEC\nAAkCGwwFAlbhZhEACgkQpScCicQ8ea23ygf/eA9q9LEaVvwPz9YLvR5LuBV9E1U9\nxeWMm6vXNTDqxZgLuEfvgkRH9BABG/PskBN147HWalYB+IVb+sgzVmHqxV9MszWA\nawr6Opk1KeKpxuMUA/nrjZFaBDQ8hQxQVZoH67kfVsWggcEhXmVQZ8c9NAMCs2k6\nZHfdBuzsJvqYg+m/B8njZ7nBFCq6qY+u1qDJ2HcTrHE6nyEBzyYEckfauGb8owPK\nAyfgVGQQ6B3svaohN5LVU2AjLrTLHGdqxKJ0degnCHJzuJs5nPgQlLO62El8ZMR7\ndmX+mnJnavfmwKTXsTwaZjki3VPSBrC4T/O+QESBXMM5nDOC5bhDnFYONA==\n=hF3n\n-----END PGP PUBLIC KEY BLOCK-----\n"
  $key_url = 'https://rep.logentries.com/RPM-GPG-KEY-logentries'

  # you can comment this if you have a similar workaround going or no
  # facter < 1.6.1
  include logentries::helpers::oldfacter

  case $::facts['os']['architecture'] {
    'x86': {
      $yum_architecture = 'i386'
    }
    'amd64': {
      $yum_architecture = 'x86_64'
    }
    default: {
      $yum_architecture = $::architecture
    }
  }
  case $::facts['os']['family'] {
    debian: {
      case $::lsbdistcodename {
        'karmic', 'lenny', 'lucid', 'maverick',
        'natty', 'oneiric', 'precise', 'quantal',
        'raring', 'saucy', 'squeeze', 'trusty',
        'utopic', 'vivid', 'wheezy', 'jessie': {
          include logentries::repo::apt
        }
        default: {
          fail "unknown compatibility for \
          ${::operatingsystem}/${::lsbdistcodename}"
          # in case you made sure, uncomment:
          # include logentries::repo::apt
        }
      }
    }
    redhat: {
      case $::facts['os']['release']['major'] {
        '6', '7': {
          class {'logentries::repo::yum':
            baseurl => "http://rep.logentries.com/centos6/${yum_architecture}",
          }
        }
        '5': {
          class {'logentries::repo::yum':
            baseurl => "http://rep.logentries.com/centos5/${yum_architecture}",
          }
        }
        default: {
          fail "unknown compatibility for \
          ${::operatingsystem}/${::lsbdistcodename}"
        }
      }
    }
  }
  # FIXME: add SuSE, more redhat
}
