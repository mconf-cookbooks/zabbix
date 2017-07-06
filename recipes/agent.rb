include_recipe "zabbix::agent_#{node['zabbix']['agent']['install_method']}"
include_recipe 'zabbix::agent_common'

# Install TLS security to be used when communicating with Zabbix server.
include_recipe 'zabbix::_agent_security'

# Install configuration.
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

# Copy scripts from files/default to scripts/.
remote_directory node['zabbix']['agent']['scripts_dir'] do
  source 'zabbix-scripts'
  owner 'root'
  group 'root'
  mode '0755'
  ignore_failure true
  notifies :restart, 'service[zabbix_agentd]'
end

# Copy userparameters from files/default to agent_include/.
remote_directory node['zabbix']['agent']['include_dir'] do
  source 'agent_include'
  owner 'root'
  group 'root'
  mode '0755'
  ignore_failure true
  notifies :restart, 'service[zabbix_agentd]'
end

# Register the agent to the server.
# TODO: Caution with idempotence.
if node['zabbix']['agent']['registration']
  include_recipe 'zabbix::_agent_registration'
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
