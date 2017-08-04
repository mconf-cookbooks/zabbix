# Manage Agent service
case node['zabbix']['agent']['init_style']
when 'sysvinit'
  init_template =
    case node['platform_family']
    when 'rhel'
      'zabbix_agentd.init-rh.erb'
    else
      if node['platform_version'].to_f >= 16
        'zabbix_agentd16_04.init.erb'
      else
        'zabbix_agentd14_04.init.erb'
      end
    end

  template '/etc/init.d/zabbix_agentd' do
    source init_template
    owner 'root'
    group 'root'
    mode '754'
  end

  # Define zabbix_agentd service
  service 'zabbix_agentd' do
    supports :status => true, :start => true, :stop => true, :restart => true
    action :nothing
  end
when 'windows'
  service 'zabbix_agentd' do
    service_name 'Zabbix Agent'
    provider Chef::Provider::Service::Windows
    supports :restart => true
    action :nothing
  end
end
