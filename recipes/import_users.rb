# Author:: Kazuki Yokoyama (yokoyama.km@gmail.com)
# Cookbook Name:: zabbix
# Recipe:: import_users
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

tmp_users = ::File.join(node['zabbix']['imports_tmp_dir'], "users")

directory tmp_users do
	owner node['zabbix']['login']
	group node['zabbix']['group']
	mode '0600'
	recursive true
end.run_action(:create)

node['zabbix']['server']['user_files'].each do |file|
	tmp_path = ::File.join(tmp_users, file)

	cookbook_file tmp_path do
		source "zabbix-users/#{file}"
		owner node['zabbix']['login']
		group node['zabbix']['group']
		mode '0400'
	end.run_action(:create)

	user_data = JSON.parse(::File.read(tmp_path))
	zabbix_user user_data['alias'] do
		server_connection connection_info
		user_alias user_data['alias']
		password user_data['passwd']
		first_name user_data['name']
		surname user_data['surname']
		type user_data['type']	
		medias user_data['user_medias']
		groups user_data['usrgrps']
		create_missing_groups user_data['create_missing_groups']
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
