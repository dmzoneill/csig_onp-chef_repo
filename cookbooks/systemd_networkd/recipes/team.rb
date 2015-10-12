#
# Cookbook Name:: systemd_networkd_team
# Recipe:: default
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#

outdir = node[ "SystemdNetworkd" ][ "outdir" ]

### Create network/team directory if necessary ###
directory "#{outdir}/team" do
  owner 'systemd-network'
  group 'systemd-network'
  mode '0755'
  action :create
end

if node.include?( "SystemdNetworkd" )    
  if node[ "SystemdNetworkd" ].include?( "Teams" )    
    node[ "SystemdNetworkd" ][ "Teams" ].each do |team_name,team_settings|

      template "#{outdir}/team/team_#{team_name}.netdev" do
        source "team/team_netdev.erb"
        variables({
          :TeamName => team_name
        })
        mode 0644
        owner "systemd-network"
        group "systemd-network"
        action :create
      end

      template "#{outdir}/team/team_#{team_name}.swport" do
        source "team/team_swport.erb"
        variables(:DevName => team_name)
        mode 0644
        owner "systemd-network"
        group "systemd-network"
        action :create
        only_if { node[ "SystemdNetworkd" ][ "Teams" ][ team_name ].include?( "Attributes" ) || 
                  node[ "SystemdNetworkd" ][ "Teams" ][ team_name ].include?( "Vlans" )
        }
      end

      template "#{outdir}/team/team_#{team_name}.network" do
        source "team/team_network.erb"
        variables(:DevName => team_name)
        mode 0644
        owner "systemd-network"
        group "systemd-network"
        action :create
        notifies :restart, "service[systemd-networkd]", :delayed
        only_if { node[ "SystemdNetworkd" ][ "Teams" ][ team_name ].include?( "FDB" ) }
      end

      if node[ "SystemdNetworkd" ][ "Teams" ][ team_name ].include?( "Members" )
        node[ "SystemdNetworkd" ][ "Teams" ][ team_name ][ "Members" ].each do |member|
        
          template "#{outdir}/team/team_#{team_name}_#{member}.network" do
            source "team/team_network_member.erb"
            variables({
                :TeamName => team_name,
                :Member => member
            })
            mode 0644
            owner "systemd-network"
            group "systemd-network"
            action :create
            notifies :restart, "service[systemd-networkd]", :delayed
          end
           
          link "#{outdir}/team_#{team_name}_#{member}.network" do
            to "#{outdir}/team/team_#{team_name}_#{member}.network"
            only_if {
               node[ "SystemdNetworkd" ][ "Teams" ][ team_name ][ "Enabled" ] == true || node[ "SystemdNetworkd" ][ "Backup" ] == true
            }
          end

        end
      end

      if node[ "SystemdNetworkd" ][ "Teams" ][ team_name ].include?( "Enabled" )
        if node[ "SystemdNetworkd" ][ "Teams" ][ team_name ][ "Enabled" ] == true || node[ "SystemdNetworkd" ][ "Backup" ] == true
        
          link "#{outdir}/team_#{team_name}.netdev" do
            to "#{outdir}/team/team_#{team_name}.netdev"
          end

          link "#{outdir}/team_#{team_name}.swport" do
            to "#{outdir}/team/team_#{team_name}.swport"
            only_if { 
              node[ "SystemdNetworkd" ][ "Teams" ][ team_name ].include?( "Attributes" ) || node[ "SystemdNetworkd" ][ "Teams" ][ team_name ].include?( "Vlans" )
            }
          end

          link "#{outdir}/team_#{team_name}.network" do
            to "#{outdir}/team/team_#{team_name}.network"
            only_if { node[ "SystemdNetworkd" ][ "Teams" ][ team_name ].include?( "FDB" )  } 
          end

        end
      end

    end
  end
end


