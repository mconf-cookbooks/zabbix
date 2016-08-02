action :import do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
      import_template_request = {
        :method => 'configuration.import',
        :params => {
          :format => 'xml',
          :rules => {
              :templates => {
                  :createMissing => true,
                  :updateMissing => true
              },
              :templateLinkage => {
                  :createMissing => true,
                  :updateMissing => true
              },
              :groups => {
                  :createMissing => true
              }
          },
          :source => new_resource.source
        }
      }
      connection.query(import_template_request)
    end
  new_resource.updated_by_last_action(true)
end

def load_current_resource
  run_context.include_recipe 'zabbix::_providers_common'
  require 'zabbixapi'
end
