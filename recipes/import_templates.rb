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

tmp_templates = "/tmp/zabbix_imports/templates"

directory tmp_templates do
	owner node['zabbix']['login']
	group node['zabbix']['group']
	mode '0600'
	recursive true
end.run_action(:create)

node['zabbix']['server']['template_files'].each do |file|
	tmp_path = ::File.join(tmp_templates, file)

	cookbook_file tmp_path do
		source "zabbix-templates/#{file}"
		owner node['zabbix']['login']
		group node['zabbix']['group']
		mode '0400'
	end.run_action(:create)

	configuration_data = ::File.read(tmp_path)
	zabbix_configuration node['zabbix']['web']['fqdn'] do
    server_connection connection_info
    source configuration_data
    action :import
	end
end

directory tmp_templates do
	owner node['zabbix']['login']
	group node['zabbix']['group']
	mode '0600'
	recursive true
	action :delete
end
