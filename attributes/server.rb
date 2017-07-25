# Server configuration for Zabbix 3.2.0.

# Load 'database.rb' to use node['zabbix']['database'].
include_attribute 'zabbix::database'

# Installation options.

default['zabbix']['server']['install']                = false
default['zabbix']['server']['version']                = '3.2.0'
default['zabbix']['server']['branch']                 = 'ZABBIX%20Latest%20Stable'
default['zabbix']['server']['source_url']             = nil
default['zabbix']['server']['install_method']         = 'source'
default['zabbix']['server']['configure_options']      = ['--with-libcurl', '--with-net-snmp', '--with-openssl']

default['zabbix']['server']['host'] = 'localhost'
default['zabbix']['server']['port'] = 10_051
default['zabbix']['server']['name'] = nil

# Default parameters.

default['zabbix']['server']['configurations']['AlertScriptsPath']      = node['zabbix']['alert_dir']
default['zabbix']['server']['configurations']['CacheSize']             = '8M'
default['zabbix']['server']['configurations']['DBName']                = node['zabbix']['database']['dbname']
default['zabbix']['server']['configurations']['DBUser']                = node['zabbix']['database']['dbuser']
default['zabbix']['server']['configurations']['DBHost']                = node['zabbix']['database']['dbhost']
default['zabbix']['server']['configurations']['DBPassword']            = node['zabbix']['database']['dbpassword']
default['zabbix']['server']['configurations']['DBPort']                = node['zabbix']['database']['dbport']
default['zabbix']['server']['configurations']['DBSocket']              = node['zabbix']['database']['dbsocket']
default['zabbix']['server']['configurations']['DebugLevel']            = 3
default['zabbix']['server']['configurations']['ExternalScripts']       = '/usr/local/scripts/zabbix/externalscripts/'
default['zabbix']['server']['configurations']['HousekeepingFrequency'] = '1'
default['zabbix']['server']['configurations']['Include']               = '/opt/zabbix/server_include'
default['zabbix']['server']['configurations']['JavaGateway']           = '127.0.0.1'
default['zabbix']['server']['configurations']['JavaGatewayPort']       = 10_052
default['zabbix']['server']['configurations']['LogFile']               = ::File.join(node['zabbix']['log_dir'], 'zabbix_server.log')
default['zabbix']['server']['configurations']['MaxHousekeeperDelete']  = '10000'
default['zabbix']['server']['configurations']['PidFile']               = ::File.join(node['zabbix']['run_dir'], 'zabbix_server.pid')
default['zabbix']['server']['configurations']['StartJavaPollers']      = 0
default['zabbix']['server']['configurations']['StartPollers']          = 5
default['zabbix']['server']['configurations']['Timeout']               = '3'
default['zabbix']['server']['configurations']['ValueCacheSize']        = '8M'
