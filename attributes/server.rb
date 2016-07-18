include_attribute 'zabbix'

# Server configuration for Zabbix 3.0.0

default['zabbix']['server']['alert_scripts_path']           = node['zabbix']['alert_dir']
default['zabbix']['server']['allow_root']                   = nil
default['zabbix']['server']['cache_size']                   = '8M'
default['zabbix']['server']['cache_update_frequency']       = nil
default['zabbix']['server']['db_host']                      = nil
default['zabbix']['server']['db_name']                      = nil
default['zabbix']['server']['db_password']                  = nil
default['zabbix']['server']['db_port']                      = nil
default['zabbix']['server']['db_schema']                    = nil
default['zabbix']['server']['db_socket']                    = nil
default['zabbix']['server']['db_user']                      = nil
default['zabbix']['server']['debug_level']                  = 3
default['zabbix']['server']['external_scripts']             = '/usr/local/scripts/zabbix/externalscripts/'
default['zabbix']['server']['fping6_location']              = nil
default['zabbix']['server']['history_cache_size']           = nil
default['zabbix']['server']['history_index_cache_size']     = nil
default['zabbix']['server']['housekeeping_frequency']       = '1'
default['zabbix']['server']['include']                      = '/opt/zabbix/server_include'
default['zabbix']['server']['java_gateway']                 = '127.0.0.1'
default['zabbix']['server']['java_gateway_port']            = 10_052
default['zabbix']['server']['listen_ip']                    = nil
default['zabbix']['server']['load_module']                  = nil
default['zabbix']['server']['load_module_path']             = nil
default['zabbix']['server']['log_file']                     = ::File.join(node['zabbix']['log_dir'], 'zabbix_server.log')
default['zabbix']['server']['log_file_size']                = nil
default['zabbix']['server']['log_type']                     = nil
default['zabbix']['server']['log_slow_queries']             = nil
default['zabbix']['server']['max_housekeeper_delete']       = '10000'
default['zabbix']['server']['pid_file']                     = node['zabbix']['run_dir']/zabbix_server.pid
default['zabbix']['server']['proxy_config_frequency']       = nil
default['zabbix']['server']['proxy_data_frequency']         = nil
default['zabbix']['server']['sender_frequency']             = nil
default['zabbix']['server']['snmp_trapper_file']            = nil
default['zabbix']['server']['source_ip']                    = nil
default['zabbix']['server']['start_db_syncers']             = nil
default['zabbix']['server']['start_discoverers']            = nil
default['zabbix']['server']['start_escalators']             = nil
default['zabbix']['server']['start_http_pollers']           = nil
default['zabbix']['server']['start_ipmi_pollers']           = nil
default['zabbix']['server']['start_java_pollers']           = 0
default['zabbix']['server']['start_pingers']                = nil
default['zabbix']['server']['start_pollers_unreachable']    = nil
default['zabbix']['server']['start_pollers']                = 5
default['zabbix']['server']['start_proxy_pollers']          = nil
default['zabbix']['server']['start_snmp_trapper']           = nil
default['zabbix']['server']['start_timers']                 = nil
default['zabbix']['server']['start_vmware_collectors']      = nil
default['zabbix']['server']['timeout']                      = '3'
default['zabbix']['server']['tmp_dir']                      = nil
default['zabbix']['server']['trapper_timeout']              = nil
default['zabbix']['server']['trend_cache_size']             = nil
default['zabbix']['server']['unavailable_delay']            = nil
default['zabbix']['server']['unreachable_delay']            = nil
default['zabbix']['server']['unreachable_period']           = nil
default['zabbix']['server']['user']                         = nil
default['zabbix']['server']['value_cache_size']             = '8M'
default['zabbix']['server']['vmware_cache_size']            = nil
default['zabbix']['server']['vmware_frequency']             = nil
default['zabbix']['server']['vmware_perf_frequency']        = nil
default['zabbix']['server']['vmware_timeout']               = nil

# Installation options

default['zabbix']['server']['version']                = '3.0.0'
default['zabbix']['server']['branch']                 = 'ZABBIX%20Latest%20Stable'
default['zabbix']['server']['source_url']             = nil
default['zabbix']['server']['install_method']         = 'source'
default['zabbix']['server']['configure_options']      = ['--with-libcurl', '--with-net-snmp']

default['zabbix']['server']['host'] = 'localhost'
default['zabbix']['server']['port'] = 10_051
default['zabbix']['server']['name'] = nil
