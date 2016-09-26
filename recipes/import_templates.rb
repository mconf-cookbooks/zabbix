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

#files_default = ::File.join(Chef::Config['file_cache_path'], 'cookbooks/zabbix/files/default/zabbix-templates')
#
#node['zabbix']['server']['template_files'].each do |file|
#    filepath = ::File.join(files_default, file)
#	if ::File.exist?(filepath)
#		configuration_data = ::File.read(filepath)
#	else
#		Chef::Log.info('Template file #{filepath} does not exist. Skipping.')
#		next
#	end
#
#    zabbix_configuration node['zabbix']['web']['fqdn'] do
#      server_connection connection_info
#      source configuration_data
#      action :import
#    end
#end

node['zabbix'['server']['template_files'].each do |file|
	tmp_path = ::File.join('/tmp/zabbix/templates', file)
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
