# Author:: Nacer Laradji (<nacer.laradji@gmail.com>)
# Modified: Kazuki Yokoyama (<yokoyama.km@gmail.com>)
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

# Web user is different from server or agent users.
unless node['zabbix']['web']['user']
  node.normal['zabbix']['web']['user'] = 'apache'
end

# Create web user.
user node['zabbix']['web']['user']

# There is a list of packages that need to be installed in server in order
# to the web interface work. They are mostly related to PHP.
node['zabbix']['web']['packages'].each do |pkg|
  package pkg do
    action :install
    notifies :restart, 'service[apache2]'
  end
end

# Install Zabbix web interface from source.
zabbix_source 'extract_zabbix_web' do
  branch node['zabbix']['server']['branch']
  version node['zabbix']['server']['version']
  source_url node['zabbix']['server']['source_url']
  code_dir node['zabbix']['src_dir']
  target_dir "zabbix-#{node['zabbix']['server']['version']}"
  install_dir node['zabbix']['install_dir']
  action :extract_only
end

# Create a symbolic link to the Zabbix web frontend directory containing
# all PHP-related files.
link node['zabbix']['web_dir'] do
  to "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/frontends/php"
end

# Create the directory to hold the PHP config file.
directory "#{node['zabbix']['src_dir']}/zabbix-#{node['zabbix']['server']['version']}/frontends/php/conf" do
  owner node['apache']['user']
  group node['apache']['group']
  mode '0755'
  action :create
end

# Install Zabbix PHP config file. It is mainly used to configure the database.
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

# Install vhost for Zabbix web frontend.
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

# Disable 000-default on Apache.
apache_site '000-default' do
  enable false
end

# PHP directory changed in Ubuntu 16.04.
php_ini_filepath = if node['platform_version'].to_f < 16 then
                     '/etc/php5/apache2/php.ini'
                   else
                     '/etc/php/7.0/apache2/php.ini'
                   end

# Install custom php.ini file. This is necessary to configure a different
# MySQL socket as set by mconf-db cookbook.
template php_ini_filepath do
  source 'zabbix_web.php.ini.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables(:dbsocket => node['zabbix']['database']['dbsocket'])
  notifies :restart, 'service[apache2]', :immediately
end

# We must enable SSL manually on Apache2.
if node['zabbix']['web']['ssl']['enable']
  include_recipe "apache2::mod_ssl"
end
