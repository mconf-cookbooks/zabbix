# Load default.rb to use node['zabbix']['etc_dir']
include_attribute 'zabbix'
include_attribute 'zabbix::server'

# Agent configuration for Zabbix 3.0.0

# Default parameters.

default['zabbix']['agent']['configurations']['Hostname']   = node['fqdn']
default['zabbix']['agent']['configurations']['Include']    = ::File.join(node['zabbix']['etc_dir'], 'agent_include')
default['zabbix']['agent']['configurations']['ListenPort'] = '10050'
default['zabbix']['agent']['configurations']['LogFile']    = '/tmp/zabbix_agentd.log'
default['zabbix']['agent']['configurations']['Timeout']    = '3'
default['zabbix']['agent']['configurations']['User']       = node['zabbix']['server']['install'] ? 'zabbix_agent' : 'zabbix'

# Installation options

default['zabbix']['agent']['install']           = true
default['zabbix']['agent']['service_state']     = [:start, :enable]

default['zabbix']['agent']['branch']            = 'ZABBIX%20Latest%20Stable'
default['zabbix']['agent']['version']           = '3.0.0'
default['zabbix']['agent']['source_url']        = nil
default['zabbix']['agent']['configure_options'] = ['--with-libcurl', '--with-openssl']

default['zabbix']['agent']['config_file']               = ::File.join(node['zabbix']['etc_dir'], 'zabbix_agentd.conf')
#default['zabbix']['agent']['userparams_config_file']    = ::File.join(node['zabbix']['agent']['include'], 'user_params.conf')
default['zabbix']['agent']['scripts_dir']    = ::File.join(node['zabbix']['etc_dir'], 'scripts')
default['zabbix']['agent']['include_dir']    = ::File.join(node['zabbix']['etc_dir'], 'include_agent')

default['zabbix']['agent']['groups']            = []

case node['platform_family']
when 'rhel', 'debian'
  default['zabbix']['agent']['init_style']      = 'sysvinit'
  default['zabbix']['agent']['install_method']  = 'source'
  default['zabbix']['agent']['pid_file']        = ::File.join(node['zabbix']['run_dir'], 'zabbix_agentd.pid')

  #default['zabbix']['agent']['user']            = 'zabbix'
  #default['zabbix']['agent']['group']           = node['zabbix']['agent']['user']
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

default['zabbix']['agent']['registration']       = false
