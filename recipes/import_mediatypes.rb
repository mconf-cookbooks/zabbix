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

directory tmp_mediatypes do
	owner node['zabbix']['login']
	group node['zabbix']['group']
	mode '0600'
	recursive true
end.run_action(:create)

node['zabbix']['server']['mediatype_files'].each do |file|
	tmp_path = ::File.join(tmp_mediatypes, file)

	cookbook_file tmp_path do
		source "zabbix-mediatypes/#{file}"
		owner node['zabbix']['login']
		group node['zabbix']['group']
		mode '0400'
	end.run_action(:create)

	mediatype_data = JSON.parse(::File.read(tmp_path))
	zabbix_mediatype mediatype_data['description'] do
			server_connection connection_info
			params mediatype_data
			retries node['zabbix']['web']['connection_retries']
			action :create_or_update
	end
end

directory node['zabbix']['imports_tmp_dir'] do
	owner node['zabbix']['login']
	group node['zabbix']['group']
	mode '0600'
	recursive true
	action :delete
end
