include_recipe "zabbix::agent_#{node['zabbix']['agent']['install_method']}"
include_recipe 'zabbix::agent_common'

# Generate PSK key and identity. Should it be moved to its own resource?
if node['zabbix']['agent']['tls_accept'].include?('psk') or
  node['zabbix']['agent']['tls_connect'] == 'psk'
  unless node['zabbix']['agent']['tls_psk_file']
    psk_file = node['hostname'] + ".psk"
    node.default['zabbix']['agent']['tls_psk_file'] =
      ::File.join("/etc", psk_file)
    require 'securerandom'
    random_key32 = SecureRandom.hex(32)
    ::File.open(node['zabbix']['agent']['tls_psk_file'], "w") do |file|
      file.puts(random_key32)
    end
  end

  unless node['zabbix']['agent']['tls_psk_identity']
    node.default['zabbix']['agent']['tls_psk_identity'] = node['hostname']
  end
end


# Install configuration
template 'zabbix_agentd.conf' do
  path node['zabbix']['agent']['config_file']
  source 'zabbix_agentd.conf.erb'
  unless node['platform_family'] == 'windows'
    owner 'root'
    group 'root'
    mode '644'
  end
  notifies :restart, 'service[zabbix_agentd]'
end

# Install optional additional agent config file containing UserParameter(s)
template 'user_params.conf' do
  path node['zabbix']['agent']['userparams_config_file']
  source 'user_params.conf.erb'
  unless node['platform_family'] == 'windows'
    owner 'root'
    group 'root'
    mode '644'
  end
  notifies :restart, 'service[zabbix_agentd]'
  only_if { node['zabbix']['agent']['user_parameter'].length > 0 }
end

if node['zabbix']['agent']['registration']
    include_recipe 'zabbix::agent_registration'
end

ruby_block 'start service' do
  block do
    true
  end
  Array(node['zabbix']['agent']['service_state']).each do |action|
    notifies action, 'service[zabbix_agentd]'
  end
end

ruby_block 'restart service' do
  block do
    true
  end

  notifies :restart, 'service[zabbix_agentd]'
end
