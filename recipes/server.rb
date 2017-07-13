# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: server
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe "zabbix::server_#{node['zabbix']['server']['install_method']}"

include_recipe 'zabbix::_import_templates'
include_recipe 'zabbix::_import_mediatypes'
include_recipe 'zabbix::_import_users'
