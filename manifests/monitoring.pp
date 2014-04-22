# == Class kafkatee::monitoring
# Installs kafkatee python ganglia module.
#
class kafkatee::monitoring(
    $ensure = 'present'
)
{
    Class['kafkatee'] -> Class['kafkatee::monitoring']

    $log_statistics_file     = $::kafkatee::log_statistics_file
    $log_statistics_interval = $::kafkatee::log_statistics_interval
    file { '/usr/lib/ganglia/python_modules/kafkatee.py':
        source  => 'puppet:///modules/kafkatee/kafkatee_ganglia.py',
        require => Package['ganglia-monitor'],
        notify  => Service['gmond'],
    }

    # Metrics reported by kafkatee_ganglia.py are
    # not known until the kafkatee.stats.json file is
    # parsed.  Run it with the --generate-pyconf option to
    # generate the .pyconf file now.
    exec { 'generate-kafkatee.pyconf':
        require => File['/usr/lib/ganglia/python_modules/kafkatee.py'],
        command => "/usr/bin/python /usr/lib/ganglia/python_modules/kafkatee.py --generate --tmax=${log_statistics_interval} ${log_statistics_file} > /etc/ganglia/conf.d/kafkatee.pyconf.new",
        onlyif  => "/usr/bin/test -f ${log_statistics_file}",
    }

    exec { 'replace-kafkatee.pyconf':
        cwd     => '/etc/ganglia/conf.d',
        path    => '/bin:/usr/bin',
        unless  => 'diff -q kafkatee.pyconf.new kafkatee.pyconf && rm kafkatee.pyconf.new',
        command => 'mv kafkatee.pyconf.new kafkatee.pyconf',
        require => Exec['generate-kafkatee.pyconf'],
        notify  => Service['gmond'],
    }
}
