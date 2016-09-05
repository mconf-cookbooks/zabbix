# Author:: Kazuki Yokoyama (yokoyama.km@gmail.com)
# Cookbook Name:: zabbix
# Recipe:: mediatype
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
  :url => node['zabbix']['web']['url'],
  :user => zabbix_server['zabbix']['web']['login'],
  :password => zabbix_server['zabbix']['web']['password']
}

files_default = ::File.join(Chef::Config['file_cache_path'], 'cookbooks/zabbix/files/default')

node['zabbix']['server']['mediatype_files'].each do |file|
    require 'json'
    filepath = ::File.join(files_default, file)
    file = ::File.read(filepath)
    mediatype_data = JSON.parse(file)

    zabbix_mediatype mediatype_data['description'] do
        server_connection connection_info
        params mediatype_data
        retries node['zabbix']['web']['connection_retries']
        action :create_or_update
    end
end
