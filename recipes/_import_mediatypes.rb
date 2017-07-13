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

tmp_mediatypes = ::File.join(node['zabbix']['imports_tmp_dir'], "mediatypes")

remote_directory tmp_mediatypes do
  source "server/mediatypes"
  owner node['zabbix']['login']
  group node['zabbix']['group']
  mode '0600'
  recursive true
  action :create
end

ruby_block 'import_mediatypes' do
  block do
    ::Dir.foreach(tmp_mediatypes) do |item|
      if ::File.extname(item) == ".json"
        mediatype_data = JSON.parse(::File.read(item))

        mediatype = Chef::Resource::ZabbixMediatype.new(mediatype_data['description'], run_context)

        mediatype.server_connection connection_info
        mediatype.params mediatype_data
        mediatype.retries node['zabbix']['web']['connection_retries']
        mediatype.action :create_or_update

        run_context.resource_collection << mediatype
      end
    end
  end
  action :run
end

directory 'delete_tmp_mediatypes' do
  path tmp_mediatypes
  owner node['zabbix']['login']
  group node['zabbix']['group']
  mode '0600'
  recursive true
  action :delete
end
