# Server's database settings for Zabbix 3.0.0.

# Database settings.

default['zabbix']['database']['install_method']     = 'mysql'
default['zabbix']['database']['dbname']             = 'zabbix'
default['zabbix']['database']['dbuser']             = 'zabbix'
default['zabbix']['database']['dbhost']             = 'localhost'
default['zabbix']['database']['dbpassword']         = 'password' # Change it in solo.json.
default['zabbix']['database']['dbport']             = '3306'
default['zabbix']['database']['dbsocket']           = '/var/run/mysql-default/mysqld.sock'
default['zabbix']['database']['root_password']      = 'password'
default['zabbix']['database']['allowed_user_hosts'] = 'localhost'

default['zabbix']['database']['rds_master_user']      = nil
default['zabbix']['database']['rds_master_password']  = nil

# SCHEMA is relevant only for IBM_DB2 database.
default['zabbix']['database']['schema'] = nil

# mconf-db cookbook installs Redis by default.
# Since we are not interested in installing Redis here, we must disable it.
default['mconf-db']['redis']['install'] = false
