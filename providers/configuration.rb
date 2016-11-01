rules = {
    :applications => {
          :createMissing => true,
          :updateExisting => true
    },
    :discoveryRules => {
          :createMissing => true,
          :updateExisting => true
    },
    :graphs => {
          :createMissing => true,
          :updateExisting => true
    },
    :groups => {
          :createMissing => true,
    },
    :hosts => {
          :createMissing => true,
          :updateExisting => true
    },
    :images => {
          :createMissing => true,
          :updateExisting => true
    },
    :items => {
          :createMissing => true,
          :updateExisting => true
    },
    :maps => {
          :createMissing => true,
          :updateExisting => true
    },
    :screens => {
          :createMissing => true,
          :updateExisting => true
    },
    :templateScreens => {
          :createMissing => true,
          :updateExisting => true
    },
    :triggers => {
          :createMissing => true,
          :updateExisting => true
    },
    :valueMaps => {
          :createMissing => true,
          :updateExisting => true
    },
    :templates => {
          :createMissing => true,
          :updateExisting => true
    },
    :templateLinkage => {
          :createMissing => true,
    }
}

action :import do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
      import_template_request = {
        :method => 'configuration.import',
        :params => {
          :format => 'xml',
          :rules => rules,
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
