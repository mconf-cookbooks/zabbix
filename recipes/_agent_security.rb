#
# Cookbook Name:: zabbix
# Recipe:: _agent_security
# Author:: Kazuki Yokoyama (<yokoyama.km@gmail.com>)
#
# This file is part of the Mconf project.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

# TODO: TLSAccept should support multiple values.
# Generate PSK key and identity.
if node['zabbix']['agent']['configurations']['TLSAccept'] == 'psk' or
  node['zabbix']['agent']['configurations']['TLSConnect'] == 'psk'

  unless node['zabbix']['agent']['configurations']['TLSPSKFile']
    # Create PSK file and install it in /etc.
    psk_file = node['hostname'] + ".psk"
    node.default['zabbix']['agent']['configurations']['TLSPSKFile'] = ::File.join("/etc", psk_file)

    # Generate 32-bit key and put it in the file just created.
    require 'securerandom'
    random_key32 = SecureRandom.hex(32)
    ::File.open(node['zabbix']['agent']['configurations']['TLSPSKFile'], "w") do |file|
      file.puts(random_key32)
    end
  end

  # Set agent's PSK identity.
  unless node['zabbix']['agent']['configurations']['PSKIdentity']
    node.default['zabbix']['agent']['configurations']['PSKIdentity'] = node['hostname']
  end
end
