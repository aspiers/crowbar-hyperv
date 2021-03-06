raise if not node[:platform] == "windows"

powershell "register_services" do
  code <<-EOH
    if (-not (Get-Service "#{node[:service][:neutron][:name]}" -ErrorAction SilentlyContinue))
    {
      New-Service -name "#{node[:service][:neutron][:name]}" -binaryPathName "`"#{node[:openstack][:bin]}\\#{node[:service][:file]}`" neutron-hyperv-agent `"#{node[:openstack][:neutron][:installed]}`" --config-file `"#{node[:openstack][:config]}\\neutron_hyperv_agent.conf`"" -displayName "#{node[:service][:neutron][:displayname]}" -description "#{node[:service][:neutron][:description]}" -startupType Automatic
      Start-Service "#{node[:service][:neutron][:name]}"
      Set-Service -Name "#{node[:service][:neutron][:name]}" -StartupType Automatic
    }
    Start-Service -Name MSiSCSI
    Set-Service -Name MSiSCSI -StartupType Automatic
  EOH
end

service "neutron-hyperv-agent" do
  service_name node[:service][:neutron][:name]
  action [:enable, :start]
  subscribes :restart, "template[#{node[:openstack][:config].gsub(/\\/, "/")}/neutron_hyperv_agent.conf]"
end
