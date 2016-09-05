# Author:: Kazuki Yokoyama (yokoyama.km@gmail.com)
# Cookbook Name:: zabbix
# Recipe:: import_templates
#
# Apache 2.0

if !Chef::Config[:solo]
  zabbix_server = search(:node, 'recipe:zabbix\\:\\:server').first
  zabbix_server = node
else
  if node['zabbix']['web']['fqdn']
    zabbix_server = node
  else
    Chef::Log.warn('This recipe uses search. Chef Solo does not support search.')
    Chef::Log.warn("If you did not set node['zabbix']['web']['fqdn'], the recipe will fail")
    return
  end
end

connection_info = {
  :url => "http://#{zabbix_server['zabbix']['web']['fqdn']}/api_jsonrpc.php",
  :user => zabbix_server['zabbix']['web']['login'],
  :password => zabbix_server['zabbix']['web']['password']
}

files_default = ::File.join(Chef::Config['file_cache_path'], 'cookbooks/zabbix/files/default')

node['zabbix']['server']['template_files'].each do |file|
    filepath = ::File.join(files_default, file)
    configuration_data = ::File.read(filepath)

    zabbix_configuration node['zabbix']['web']['fqdn'] do
      server_connection connection_info
      source configuration_data
      retries node['zabbix']['web']['connection_retries']
      action :import
    end
end
