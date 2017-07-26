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

# Every interaction with Zabbix server is performed through the API available
# on its web interface. Here we set the credentials to be used as if it was a
# real user accessing the web interface.
connection_info = {
  :url => node['zabbix']['web']['url'],
  :user => zabbix_server['zabbix']['web']['login'],
  :password => zabbix_server['zabbix']['web']['password']
}

tmp_users = ::File.join(node['zabbix']['imports_tmp_dir'], "users")

# Create a temp directory to hold users files in the host.
# Every file in the files/default/server/users/ directory is also copied
# to this temp directory in host. It removes the need of the user specifying
# which files should be imported. It is implicity that all files must be a
# valid file.
remote_directory tmp_users do
  source "server/users"
  owner node['zabbix']['login']
  group node['zabbix']['group']
  mode '0600'
  recursive true
  action :create
end

# Import users into Zabbix server.
# It reads each file in the temp directory created just above, parses it as a
# JSON file and uses zabbix_configuration resource to import it into Zabbix server.
ruby_block 'import_users' do
  block do
    ::Dir.foreach(tmp_users) do |item|
      if ::File.extname(item) == ".json"
        user_data = JSON.parse(::File.read(item))

        # Although a little weird, this allows us to use resources
        # (in this case zabbix_configuration) inside a ruby_block resource.
        # It is necessary, because ruby_block is executed by Chef at convergence
        # time when all resources have been already queued at compile time.
        # This way when ruby_block is compiled by Chef, the inner resource is
        # correctly queued to be executed after.

        # Create a new resource object.
        user = Chef::Resource::ZabbixConfiguration.new(user_data['alias'], run_context)

        # Configure the new resource object.
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

        # Add the resource to the Chef resources queue.
        run_context.resource_collection << user
      end
    end
  end
  action :run
end

# Remove the temp directory as it is no longer needed.
directory 'delete_tmp_users' do
  path tmp_users
  owner node['zabbix']['login']
  group node['zabbix']['group']
  mode '0600'
  recursive true
  action :delete
end
