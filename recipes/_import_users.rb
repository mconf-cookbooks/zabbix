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

remote_directory tmp_users do
  source "server/users"
  owner node['zabbix']['login']
  group node['zabbix']['group']
  mode '0600'
  recursive true
  action :create
end

ruby_block 'import_users' do
  block do
    ::Dir.foreach(tmp_users) do |item|
      if ::File.extname(item) == ".json"
        user_data = JSON.parse(::File.read(item))

        user = Chef::Resource::ZabbixConfiguration.new(user_data['alias'], run_context)

        user.server_connection connection_info
        user.user_alias user_data['alias']
        user.password user_data['passwd']
        user.first_name user_data['name']
        user.surname user_data['surname']
        user.type user_data['type']
        user.medias user_data['user_medias']
        user.groups user_data['usrgrps']
        user.create_missing_groups user_data['create_missing_groups']
        user.action :create_or_update

        run_context.resource_collection << user
      end
    end
  end
  action :run
end

directory 'delete_tmp_users' do
  path tmp_users
  owner node['zabbix']['login']
  group node['zabbix']['group']
  mode '0600'
  recursive true
  action :delete
end
