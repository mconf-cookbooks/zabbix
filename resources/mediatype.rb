actions :create
default_action :create

attribute :hostname, :kind_of => String, :name_attribute => true
attribute :server_connection, :kind_of => Hash, :required => true
attribute :params, :kind_of => Hash, :required => true
