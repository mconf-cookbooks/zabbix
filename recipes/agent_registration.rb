# Author:: Guilhem Lettron (<guilhem.lettron@youscribe.com>)
# Cookbook Name:: zabbix
# Recipe:: agent_registration
#
# Apache 2.0
#

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

ip_address = node['ipaddress']
if node['zabbix']['agent']['network_interface']
  target_interface = node['zabbix']['agent']['network_interface']
  if node['network']['interfaces'][target_interface]
    ip_address = node['network']['interfaces'][target_interface]['addresses'].keys[1]
    Chef::Log.debug "zabbix::agent_registration : Using ip address of #{ip_address} for host"
  else
    Chef::Log.warn "zabbix::agent_registration : Could not find interface address for #{target_interface}, falling back to default"
  end
end

interface_definitions = {
  :zabbix_agent => {
    :type => 1,
    :main => 1,
    :useip => 1,
    :ip => ip_address,
    :dns => node['fqdn'],
    :port => node['zabbix']['agent']['zabbix_agent_port']
  },
  :jmx => {
    :type => 4,
    :main => 1,
    :useip => 1,
    :ip => ip_address,
    :dns => node['fqdn'],
    :port => node['zabbix']['agent']['jmx_port']
  },
  :snmp => {
    :type => 2,
    :main => 1,
    :useip => 1,
    :ip => ip_address,
    :dns => node['fqdn'],
    :port => node['zabbix']['agent']['snmp_port']
  }
}

interface_list = node['zabbix']['agent']['interfaces']

interface_data = []
interface_list.each do |interface|
  if interface_definitions.key?(interface.to_sym)
    interface_data.push(interface_definitions[interface.to_sym])
  else
    Chef::Log.warn "WARNING: Interface #{interface} is not defined in agent_registration.rb"
  end
end

tls_connect_definitions = {
  :unencrypted => 1,
  :psk => 2,
  :cert => 3
}

require 'set'

tls_accept_definitions = {
  [:unencrypted].to_set => 1,
  [:psk].to_set => 2,
  [:unencrypted, :psk].to_set => 3,
  [:cert].to_set => 4,
  [:unencrypted, :cert].to_set => 5,
  [:psk, :cert].to_set => 6,
  [:unencrypted, :psk, :cert].to_set => 7
}

if node['zabbix']['agent']['tls_connect'].nil?
  tls_connect = tls_connect_definitions[:unencrypted]
elsif tls_connect_definitions.key?(node['zabbix']['agent']['tls_connect'].to_sym)
  tls_connect = tls_connect_definitions[node['zabbix']['agent']['tls_connect'].to_sym]
else
    Chef::Log.warn "WARNING: TLS connect #{node['zabbix']['agent']['tls_connect']} \
    is not defined in agent_registration.rb"
end

if node['zabbix']['agent']['tls_accept'].nil?
  tls_accept = tls_accept_definitions[[:unencrypted].to_set]
else
  tls_accept_set = if node['zabbix']['agent']['tls_accept'].respond_to?("map")
                     node['zabbix']['agent']['tls_accept'].map(&:to_sym).to_set
                   else
                     Set.new [node['zabbix']['agent']['tls_accept'].to_sym] end

  if tls_accept_definitions.key?(tls_accept_set)
    tls_accept = tls_accept_definitions[tls_accept_set]
  else
    Chef::Log.warn "WARNING: Accept list #{node['zabbix']['agent']['tls_accept']} \
    is not defined in agent_registration.rb"
  end
end


tls_psk = if node['zabbix']['agent']['tls_psk_file'].nil? then ""
              else ::File.read(node['zabbix']['agent']['tls_psk_file']).strip end
tls_psk_identity = if node['zabbix']['agent']['tls_psk_identity'].nil? then ""
                   else node['zabbix']['agent']['tls_psk_identity'] end


zabbix_host node['zabbix']['agent']['hostname'] do
  create_missing_groups true
  server_connection connection_info
  parameters(
    :host => node['hostname'],
    :groupNames => node['zabbix']['agent']['groups'],
    :templates => node['zabbix']['agent']['templates'],
    :interfaces => interface_data,
    :tls_connect => tls_connect,
    :tls_accept => tls_accept,
    :tls_psk => tls_psk,
    :tls_psk_identity => tls_psk_identity
  )
  retries node['zabbix']['web']['connection_retries']
  action :nothing
end

log 'Delay agent registration to wait for server to be started' do
  level :debug
  notifies :create_or_update, "zabbix_host[#{node['zabbix']['agent']['hostname']}]", :delayed
end
