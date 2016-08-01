actions :import
default_action :import

attribute :hostname, :kind_of => String, :name_attribute => true
attribute :server_connection, :kind_of => Hash, :required => true
attribute :format, :kind_of => String, :default => 'xml'
attribute :source, :kind_of => String, :required => true
