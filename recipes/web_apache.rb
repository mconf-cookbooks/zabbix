# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Cookbook Name:: zabbix
# Recipe:: web
#
# Copyright 2011, Efactures
#
# Apache 2.0
#

include_recipe 'zabbix::common'

directory node['zabbix']['install_dir'] do
  mode '0755'
end

unless node['zabbix']['web']['user']
  node.normal['zabbix']['web']['user'] = 'apache'
end

user node['zabbix']['web']['user']

node['zabbix']['web']['packages'].each do |pkg|
  package pkg do
    action :install
    notifies :restart, 'service[apache2]'
  end
end

zabbix_source 'extract_zabbix_web' do
  branch node['zabbix']['server']['branch']
  version node['zabbix']['server']['version']
  source_url node['zabbix']['server']['source_url']
  code_dir node['zabbix']['src_dir']
  target_dir "zabbix-#{node['zabbix']['server']['version']}"
  install_dir node['zabbix']['install_dir']
  action :extract_only
end

link node['zabbix']['web_dir'] do
  to "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/frontends/php"
end

directory "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/frontends/php/conf" do
  owner node['apache']['user']
  group node['apache']['group']
  mode '0755'
  action :create
end

# install zabbix PHP config file
template "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/frontends/php/conf/zabbix.conf.php" do
  source 'zabbix_web.conf.php.erb'
  owner 'root'
  group 'root'
  mode '754'
  variables(
    :database => node['zabbix']['database'],
    :server => node['zabbix']['server']
  )
end

# install vhost for zabbix frontend
web_app node['zabbix']['web']['fqdn'] do
  server_name node['zabbix']['web']['fqdn']
  server_port node['zabbix']['web']['port']
  server_aliases node['zabbix']['web']['aliases']
  docroot node['zabbix']['web_dir']
  not_if { node['zabbix']['web']['fqdn'].nil? }
  php_settings node['zabbix']['web']['php']['settings']
  ssl_enable node['zabbix']['web']['ssl']['enable']
  ssl_port node['zabbix']['web']['ssl']['port']
  certificate_file node['zabbix']['web']['ssl']['certificate_file']
  certificate_key_file node['zabbix']['web']['ssl']['certificate_key_file']
  protocol node['zabbix']['web']['ssl']['enable'] ? "https" : "http"
  template 'apache-site.conf.erb'
  notifies :restart, 'service[apache2]', :immediately
end

apache_site '000-default' do
  enable false
end

php_ini_filepath = if node['platform_version'].to_f < 16 then
                     '/etc/php5/apache2/php.ini'
                   else
                     '/etc/php/7.0/apache2/php.ini'
                   end


template php_ini_filepath do
  source 'zabbix_web.php.ini.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables(:dbsocket => node['zabbix']['database']['dbsocket'])
  notifies :restart, 'service[apache2]', :immediately
end

if node['zabbix']['web']['ssl']['enable']
  include_recipe "apache2::mod_ssl"
end
