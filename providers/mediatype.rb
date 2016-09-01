action :create do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
      create_mediatype_request = {
        :method => 'mediatype.create',
        :params => new_resource.params
      }
      connection.query(create_mediatype_request)
    end
  new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end
