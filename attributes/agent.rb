# Agent configuration for Zabbix 3.0.0

# Load default.rb to use node['zabbix']['etc_dir']
include_attribute 'zabbix'
include_attribute 'zabbix::server'

# Installation settings.

default['zabbix']['agent']['install']           = true
default['zabbix']['agent']['branch']            = 'ZABBIX%20Latest%20Stable'
default['zabbix']['agent']['version']           = '3.0.0'
default['zabbix']['agent']['source_url']        = nil
default['zabbix']['agent']['configure_options'] = ['--with-libcurl', '--with-openssl']
default['zabbix']['agent']['service_state']     = [:start, :enable]

# Directory settings.

default['zabbix']['agent']['config_file']    = ::File.join(node['zabbix']['etc_dir'], 'zabbix_agentd.conf')
default['zabbix']['agent']['scripts_dir']    = ::File.join(node['zabbix']['etc_dir'], 'scripts')
default['zabbix']['agent']['include_dir']    = ::File.join(node['zabbix']['etc_dir'], 'include')

default['zabbix']['agent']['groups']            = []

case node['platform_family']
when 'rhel', 'debian'
  default['zabbix']['agent']['init_style']      = 'sysvinit'
  default['zabbix']['agent']['install_method']  = 'source'
  default['zabbix']['agent']['pid_file']        = ::File.join(node['zabbix']['run_dir'], 'zabbix_agentd.pid')

  default['zabbix']['agent']['user']            = node['zabbix']['server']['install'] ? 'zabbix_agent' : 'zabbix'
  default['zabbix']['agent']['group']           = 'zabbix'

  default['zabbix']['agent']['shell']           = node['zabbix']['shell']
when 'windows'
  default['zabbix']['agent']['init_style']      = 'windows'
  default['zabbix']['agent']['install_method']  = 'chocolatey'
end

default['zabbix']['agent']['start_agents']       = nil # default (3)
default['zabbix']['agent']['debug_level']        = nil # default (3)
default['zabbix']['agent']['templates']          = []
default['zabbix']['agent']['interfaces']         = ['zabbix_agent']
default['zabbix']['agent']['jmx_port']           = '10052'
default['zabbix']['agent']['zabbix_agent_port']  = '10050'
default['zabbix']['agent']['snmp_port']          = '161'

# Register settings.

default['zabbix']['agent']['register']['enabled']            = false
default['zabbix']['agent']['register']['url']                = ""
default['zabbix']['agent']['register']['login']              = ""
default['zabbix']['agent']['register']['password']           = ""
default['zabbix']['agent']['register']['ssl']['enabled']     = true
default['zabbix']['agent']['register']['connection_retries'] = 3

# Default parameters.

default['zabbix']['agent']['configurations']['Hostname']   = node['fqdn']
default['zabbix']['agent']['configurations']['Include']    = ::File.join(node['zabbix']['etc_dir'], 'include')
default['zabbix']['agent']['configurations']['ListenPort'] = '10050'
default['zabbix']['agent']['configurations']['LogFile']    = ::File.join(node['zabbix']['log_dir'], 'zabbix_agentd.log')
default['zabbix']['agent']['configurations']['Timeout']    = '3'
default['zabbix']['agent']['configurations']['User']       = node['zabbix']['agent']['user']
default['zabbix']['agent']['configurations']['PidFile']    = node['zabbix']['agent']['pid_file']
