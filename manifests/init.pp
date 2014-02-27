# == Class: kafkatee
#
# Installs and configures a kafkatee instance. This does not configure any
# inputs or outputs for the kafkatee instance.  You should configure them
# using the kafkatee::input and kafkatee::output defines.
#
# == Parameters:
# $kafka_brokers             - Array of Kafka broker addresses.
# $kafka_offset_store_path   - Path in which to store consumed Kafka offsets.
#                              Default: /var/cache/kafkatee/offsets
# $kafka_offset_reset        - Where to consume from if the offset from which to
#                              consume is not on the broker, or if there is no
#                              stored offset yet.  One of: smallest, largest, error.
#                              Default: largest
# $kafka_message_max_bytes   - Maximum message size.  Default: undef (4000000).
# $pidfile                   - Location of kafkatee pidfile.
#                              Default: /var/run/kafkatee/kafkatee.pid
# $log_statistics_file       - Path in which to store kafkatee .json statistics.
#                              Default: /var/cache/kafkatee/kafkatee.stats.json
# $log_statistics_interval   - How often to write statistics to $log_statistics_file.
#                              Default: 60
# $output_encoding           - If this is string and inputs are json, then the JSON
#                              input will be transformed according to $output_format
#                              before they are sent to the configured outputs.
#                              Default: string
# $output_format             - Format string with which to transform JSON data into
#                              string output.  See kafkatee.conf documentation
#                              for more info.
#                              Default: SEE PARAMETER
# $output_queue_size         - Maximum queue size for each output, in number of messages.
#                              Default: undef, (1000000)
# $config_file               - Main kafkatee config file.
#                              Default: /etc/kafkatee.conf
# $config_directory          - kafkatee config include directory.
#                              Default: /etc/kafkatee.d
#
class kafkatee(
    $kafka_brokers,
    $kafka_offset_store_path = '/var/cache/kafkatee/offsets',
    $kafka_offset_reset      = 'largest',
    $kafka_message_max_bytes = undef,
    $pidfile                 = '/var/run/kafkatee/kafkatee.pid',
    $log_statistics_file     = '/var/cache/kafkatee/kafkatee.stats.json',
    $log_statistics_interval = 60,
    $output_encoding         = 'string',
    $output_format           = '%{hostname}	%{sequence}	%{dt}	%{time_firstbyte}	%{ip}	%{cache_status}/%{http_status}	%{response_size}	%{http_method}	http://%{uri_host}%{uri_path}%{uri_query}	-	%{content_type}	%{referer}	%{x_forwarded_for}	%{user_agent}	%{accept_language}	%{x_analytics}',
    $output_queue_size       = undef,
)
{
    package { 'kafkatee':
        ensure => 'installed',
    }

    file { '/etc/kafkatee.conf':
        content => template('kafkatee/kafkatee.conf.erb'),
        require  => Package['kafkatee'],
    }

    service { 'kafkatee':
        ensure     => 'running',
        provider   => 'upstart',
        hasrestart => 'true',
        subscribe  => File['/etc/kafkatee.conf'],
    }
}
