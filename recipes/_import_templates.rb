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

# Every interaction with Zabbix server is performed through the API available
# on its web interface. Here we set the credentials to be used as if it was a
# real user accessing the web interface.
connection_info = {
  :url => node['zabbix']['web']['url'],
  :user => zabbix_server['zabbix']['web']['login'],
  :password => zabbix_server['zabbix']['web']['password']
}

tmp_templates = ::File.join(node['zabbix']['imports_tmp_dir'], "templates")

# Create a temp directory to hold templates files in the host.
# Every file in the files/default/server/templates/ directory is also copied
# to this temp directory in host. It removes the need of the user specifying
# which files should be imported. It is implicity that all files must be a
# valid file.
remote_directory tmp_templates do
  source "server/templates"
  owner node['zabbix']['login']
  group node['zabbix']['group']
  mode '0644'
  recursive true
  action :create
end

# Import templates into Zabbix server.
# It reads each file in the temp directory created just above, parses it as a
# JSON file and uses zabbix_configuration resource to import it into Zabbix server.
ruby_block 'import_templates' do
  block do
    ::Dir::glob(::File.join(tmp_templates, "*")).sort.each do |item|
      if ::File.extname(item) == ".xml"
        Chef::Log.info("Importing template #{item}")
        configuration_data = ::File.read(item)

        # Although a little weird, this allows us to use resources
        # (in this case zabbix_configuration) inside a ruby_block resource.
        # It is necessary, because ruby_block is executed by Chef at convergence
        # time when all resources have been already queued at compile time.
        # This way when ruby_block is compiled by Chef, the inner resource is
        # correctly queued to be executed after.

        # Create a new resource object.
        config = Chef::Resource::ZabbixConfiguration.new(node['zabbix']['web']['fqdn'], run_context)

        # Configure the new resource object.
        config.server_connection connection_info
        config.source configuration_data
        config.action :import

        # Add the resource to the Chef resources queue.
        run_context.resource_collection << config
      end
    end
  end
  action :run
end

# Remove the temp directory as it is no longer needed.
directory 'delete_tmp_templates' do
  path tmp_templates
  owner node['zabbix']['login']
  group node['zabbix']['group']
  mode '0600'
  recursive true
  action :delete
end
