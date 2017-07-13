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
  :url => node['zabbix']['web']['url'],
  :user => zabbix_server['zabbix']['web']['login'],
  :password => zabbix_server['zabbix']['web']['password']
}

tmp_templates = ::File.join(node['zabbix']['imports_tmp_dir'], "templates")

remote_directory tmp_templates do
  source "server/templates"
  owner node['zabbix']['login']
  group node['zabbix']['group']
  mode '0644'
  #files_owner node['zabbix']['login']
  #files_group node['zabbix']['group']
  #files_mode '0444'
  recursive true
  action :create
end

ruby_block 'import_templates' do
  block do
    ::Dir.foreach(tmp_templates) do |item|
      if ::File.extname(item) == ".xml"
        item_path = ::File.join(tmp_templates, item)
        configuration_data = ::File.read(item_path)

        config = Chef::Resource::ZabbixConfiguration.new(node['zabbix']['web']['fqdn'], run_context)

        config.server_connection connection_info
        config.source configuration_data
        config.action :import

        run_context.resource_collection << config
      end
    end
  end
  action :run
end

directory 'delete_tmp_templates' do
  path tmp_templates
  owner node['zabbix']['login']
  group node['zabbix']['group']
  mode '0600'
  recursive true
  action :delete
end
