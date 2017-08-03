# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Modified: Kazuki Yokoyama (<yokoyama.km@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe 'zabbix::common'

include_recipe "zabbix::server_#{node['zabbix']['server']['install_method']}"

# Install web interface if enabled.
include_recipe 'zabbix::web' if node['zabbix']['web']['install']

include_recipe 'zabbix::_import_templates'
include_recipe 'zabbix::_import_mediatypes'
include_recipe 'zabbix::_import_users'

# Alway restart the service at the end of the recipe.
service 'zabbix_server' do
  action :start
end
