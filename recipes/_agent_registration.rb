# Author:: Guilhem Lettron (<guilhem.lettron@youscribe.com>)
# Cookbook Name:: zabbix
# Recipe:: _agent_registration
#
# Apache 2.0
#

zabbix_web = node['zabbix']['agent']['register']

connection_info = {
  :url => "#{node['zabbix']['agent']['register']['url']}/api_jsonrpc.php",
  :user => zabbix_web['login'],
  :password => zabbix_web['password']
}

ip_address = node['ipaddress']
if node['zabbix']['agent']['network_interface']
  target_interface = node['zabbix']['agent']['network_interface']
  if node['network']['interfaces'][target_interface]
    ip_address = node['network']['interfaces'][target_interface]['addresses'].keys[1]
    Chef::Log.debug "zabbix::_agent_registration : Using ip address of #{ip_address} for host"
  else
    Chef::Log.warn "zabbix::_agent_registration : Could not find interface address for #{target_interface}, falling back to default"
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
    Chef::Log.warn "WARNING: Interface #{interface} is not defined in _agent_registration.rb"
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

if node['zabbix']['agent']['configurations']['TLSConnect'].nil?
  tls_connect = tls_connect_definitions[:unencrypted]
elsif tls_connect_definitions.key?(node['zabbix']['agent']['configurations']['TLSConnect'].to_sym)
  tls_connect = tls_connect_definitions[node['zabbix']['agent']['configurations']['TLSConnect'].to_sym]
else
    Chef::Log.warn "WARNING: TLS connect #{node['zabbix']['agent']['configurations']['TLSConnect']} \
    is not defined in _agent_registration.rb"
end

if node['zabbix']['agent']['configurations']['TLSAccept'].nil?
  tls_accept = tls_accept_definitions[[:unencrypted].to_set]
else
  # TODO: TLSAccept should support multiple values.
  tls_accept_set = if node['zabbix']['agent']['configurations']['TLSAccept'].respond_to?("map")
                     node['zabbix']['agent']['configurations']['TLSAccept'].map(&:to_sym).to_set
                   else
                     Set.new [node['zabbix']['agent']['configurations']['TLSAccept'].to_sym]
                   end

  if tls_accept_definitions.key?(tls_accept_set)
    tls_accept = tls_accept_definitions[tls_accept_set]
  else
    Chef::Log.warn "WARNING: Accept list #{node['zabbix']['agent']['configurations']['TLSAccept']} \
    is not defined in _agent_registration.rb"
  end
end


tls_psk = if node['zabbix']['agent']['configurations']['TLSPSKFile'].nil?
            ""
          else
            ::File.read(node['zabbix']['agent']['configurations']['TLSPSKFile']).strip
          end

tls_psk_identity = if node['zabbix']['agent']['configurations']['TLSPSKIdentity'].nil?
                     ""
                   else
                     node['zabbix']['agent']['configurations']['TLSPSKIdentity']
                   end


zabbix_host node['zabbix']['agent']['hostname'] do
  create_missing_groups true
  server_connection connection_info
  parameters(
    :groupNames => node['zabbix']['agent']['groups'],
    :templates => node['zabbix']['agent']['templates'],
    :interfaces => interface_data,
    :tls_connect => tls_connect,
    :tls_accept => tls_accept,
    :tls_psk => tls_psk,
    :tls_psk_identity => tls_psk_identity
  )
  retries zabbix_web['connection_retries']
  action :nothing
end

log 'Delay agent registration to wait for server to be started' do
  level :debug
  notifies :create_or_update, "zabbix_host[#{node['zabbix']['agent']['hostname']}]", :delayed
end
