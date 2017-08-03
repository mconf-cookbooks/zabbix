include_recipe 'zabbix::common'

include_recipe "zabbix::agent_#{node['zabbix']['agent']['install_method']}"

# Install TLS security to be used when communicating with Zabbix server.
include_recipe 'zabbix::_agent_security'

# Install Zabbix agent configuration file.
template node['zabbix']['agent']['config_file'] do
  source 'zabbix.conf.erb'
  unless node['platform_family'] == 'windows'
    owner 'root'
    group 'root'
    mode '644'
  end
  variables(
    :component => "agent",
    :version => node['zabbix']['agent']['version'],
    :configurations => node['zabbix']['agent']['configurations']
  )
  notifies :restart, 'service[zabbix_agentd]'
end

# Copy scripts from files/default to scripts/.
remote_directory node['zabbix']['agent']['scripts_dir'] do
  source 'agent/agent_scripts'
  owner 'root'
  group 'root'
  mode '0755'
  ignore_failure true
  notifies :restart, 'service[zabbix_agentd]'
end

# Copy userparameters from files/default to include/.
remote_directory node['zabbix']['agent']['include_dir'] do
  source 'agent/include'
  owner 'root'
  group 'root'
  mode '0755'
  ignore_failure true
  notifies :restart, 'service[zabbix_agentd]'
end

# Register the agent to the server.
# TODO: Caution with idempotence. It should register only once.
if node['zabbix']['agent']['register']['enabled']
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

# Alway restart the service at the end of the recipe.
service 'zabbix_agentd' do
  action :start
end
