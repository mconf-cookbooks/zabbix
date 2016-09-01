if node['zabbix']['server']['install']
    include_recipe 'zabbix::server_common'
end

include_recipe 'zabbix::_agent_common_user'
include_recipe 'zabbix::common'
include_recipe 'zabbix::_agent_common_directories'
include_recipe 'zabbix::_agent_common_service'
