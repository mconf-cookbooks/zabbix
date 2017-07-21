default['zabbix']['web']['login']                       = 'admin'
default['zabbix']['web']['password']                    = 'zabbix'
default['zabbix']['web']['install_method']              = 'apache'
default['zabbix']['web']['fqdn']                        = node['fqdn']
default['zabbix']['web']['aliases']                     = ['zabbix']
default['zabbix']['web']['port']                        = 80
default['zabbix']['web']['install']                     = false
default['zabbix']['web']['ssl']['enable']               = false
default['zabbix']['web']['ssl']['port']                 = 443
default['zabbix']['web']['ssl']['certificate_file']     = nil
default['zabbix']['web']['ssl']['certificate_key_file'] = nil
default['zabbix']['web']['connection_retries']          = 1
default['zabbix']['web']['protocol']                    = node['zabbix']['web']['ssl']['enable'] ? 'https' : 'http'
default['zabbix']['web']['url']                         = "#{node['zabbix']['web']['protocol']}://#{node['zabbix']['web']['fqdn']}/api_jsonrpc.php"
default['apache']['mpm']                                = "prefork"

default['zabbix']['web']['php']['fastcgi_listen'] = '127.0.0.1:9000' # only applicable when using php-fpm (nginx)
default['zabbix']['web']['php']['settings']    = {
  'memory_limit'        => '256M',
  'post_max_size'       => '32M',
  'upload_max_filesize' => '16M',
  'max_execution_time'  => '600',
  'max_input_time'      => '600',
  'date.timezone'       => "'America/Sao_Paulo'",
}

default['zabbix']['web']['packages'] = value_for_platform_family(
  'debian' =>
    if node['platform_version'].to_f < 16.0
      %w(php5-mysql php5-gd libapache2-mod-php5 apache2-mpm-prefork)
    else
      %w(php-mysql php-gd libapache2-mod-php7.0)
    end,
  'rhel' =>
    if node['platform_version'].to_f < 6.0
      %w(php53-mysql php53-gd php53-bcmath php53-mbstring)
    else
      %w(php php-mysql php-gd php-bcmath php-mbstring php-xml)
    end
  )
