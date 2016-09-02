actions :create_or_update, :create, :update
default_action :create_or_update

attribute :description, :kind_of => String, :name_attribute => true
attribute :server_connection, :kind_of => Hash, :required => true
attribute :params, :kind_of => Hash, :required => true
