action :create_or_update do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
    get_mediatype_request = {
      :method => 'mediatype.get',
      :params => {
        :filter => {
          :description => new_resource.description
        }
      }
    }
    mediatypes = connection.query(get_mediatype_request)

    if mediatypes.size == 0
      Chef::Log.info 'Proceeding to create this mediatype to the Zabbix server'
      run_action :create
    else
      Chef::Log.debug 'Going to update this mediatype'
      run_action :update
    end
  end
  new_resource.updated_by_last_action(true)
end

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

action :update do
  Chef::Zabbix.with_connection(new_resource.server_connection) do |connection|
      
    get_mediatype_request = {
      :method => 'mediatype.get',
      :params => {
        :filter => {
          :description => new_resource.description
        }
      }
    }

    mediatype = connection.query(get_mediatype_request).first

    if mediatype.nil?
      Chef::Application.fatal! "Could not find #{new_resource.description}"
    end

    new_resource.params['mediatypeid'] = mediatype['mediatypeid']

    mediatype_update_request = {
      :method => 'mediatype.update',
      :params => new_resource.params
    }
    connection.query(mediatype_update_request)
  end
  new_resource.updated_by_last_action(true)
end
