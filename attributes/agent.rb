# Load default.rb to use node['zabbix']['etc_dir']
include_attribute 'zabbix'
include_attribute 'zabbix::server'

# Agent configuration for Zabbix 3.0.0

default['zabbix']['agent']['alias']                     = nil
default['zabbix']['agent']['allow_root']                = nil
default['zabbix']['agent']['buffer_send']               = nil
default['zabbix']['agent']['buffer_size']               = nil
default['zabbix']['agent']['debug_level']               = nil
default['zabbix']['agent']['enable_remote_commands']    = 1
default['zabbix']['agent']['host_metadata']             = nil
default['zabbix']['agent']['host_metadata_item']        = nil
default['zabbix']['agent']['hostname']                  = node['fqdn']
default['zabbix']['agent']['hostname_item']             = nil
default['zabbix']['agent']['include']                   = ::File.join(node['zabbix']['etc_dir'], 'agent_include')
default['zabbix']['agent']['listen_ip']                 = []
default['zabbix']['agent']['listen_port']               = '10050'
default['zabbix']['agent']['load_module']               = nil
default['zabbix']['agent']['load_module_path']          = nil
default['zabbix']['agent']['log_file']                  = '/tmp/zabbix_agentd.log'
default['zabbix']['agent']['log_file_size']             = nil
default['zabbix']['agent']['log_type']                  = nil
default['zabbix']['agent']['log_remote_commands']       = nil
default['zabbix']['agent']['max_lines_per_second']      = nil
default['zabbix']['agent']['pid_file']                  = nil
default['zabbix']['agent']['refresh_active_checks']     = nil
default['zabbix']['agent']['server']                    = []
default['zabbix']['agent']['server_active']             = []
default['zabbix']['agent']['source_ip']                 = nil
default['zabbix']['agent']['start_agents']              = nil
default['zabbix']['agent']['timeout']                   = '3'
default['zabbix']['agent']['tls_accept']                = []
default['zabbix']['agent']['tls_ca_file']               = nil
default['zabbix']['agent']['tls_cert_file']             = nil
default['zabbix']['agent']['tls_connect']               = nil
default['zabbix']['agent']['tls_crl_file']              = nil
default['zabbix']['agent']['tls_key_file']              = nil
default['zabbix']['agent']['tls_psk_file']              = nil
default['zabbix']['agent']['tls_psk_identity']          = nil
default['zabbix']['agent']['tls_server_cert_issuer']    = nil
default['zabbix']['agent']['tls_server_cert_subject']   = nil
default['zabbix']['agent']['unsafe_user_parameters']    = []
default['zabbix']['agent']['user']                      = node['zabbix']['server']['install'] ? 'zabbix_agent' : 'zabbix'
default['zabbix']['agent']['user_parameter']            = []

# Installation options

default['zabbix']['agent']['install']           = true
default['zabbix']['agent']['service_state']     = [:start, :enable]

default['zabbix']['agent']['branch']            = 'ZABBIX%20Latest%20Stable'
default['zabbix']['agent']['version']           = '3.0.0'
default['zabbix']['agent']['source_url']        = nil
default['zabbix']['agent']['configure_options'] = ['--with-libcurl', '--with-openssl']

default['zabbix']['agent']['config_file']               = ::File.join(node['zabbix']['etc_dir'], 'zabbix_agentd.conf')
default['zabbix']['agent']['userparams_config_file']    = ::File.join(node['zabbix']['agent']['include'], 'user_params.conf')
default['zabbix']['agent']['userparams_scripts_dir']    = ::File.join(node['zabbix']['etc_dir'], 'scripts')

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
