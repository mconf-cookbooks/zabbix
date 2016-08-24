rules = {
    :applications => {
          :createMissing => true,
          :updateMissing => true
    },
    :discoveryRules => {
          :createMissing => true,
          :updateMissing => true
    },
    :graphs => {
          :createMissing => true,
          :updateMissing => true
    },
    :groups => {
          :createMissing => true,
    },
    :hosts => {
          :createMissing => true,
          :updateMissing => true
    },
    :images => {
          :createMissing => true,
          :updateMissing => true
    },
    :items => {
          :createMissing => true,
          :updateMissing => true
    },
    :maps => {
          :createMissing => true,
          :updateMissing => true
    },
    :screens => {
          :createMissing => true,
          :updateMissing => true
    },
    :templateScreens => {
          :createMissing => true,
          :updateMissing => true
    },
    :triggers => {
          :createMissing => true,
          :updateMissing => true
    },
    :valueMaps => {
          :createMissing => true,
          :updateMissing => true
    },
    :templates => {
          :createMissing => true,
          :updateMissing => true
    },
    :templateLinkage => {
          :createMissing => true,
    },
    :groups => {
          :createMissing => true
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
