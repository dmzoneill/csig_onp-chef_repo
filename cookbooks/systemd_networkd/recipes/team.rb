# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

#
# Cookbook Name:: systemd_networkd_team
# Recipe:: default
#
# Copyright 2014, Intel Corp
#
# All rights reserved - Do Not Redistribute
#

outdir = node['SystemdNetworkd']['outdir']

### Create network/team directory if necessary ###
ensure_networkd_subdir('team')

if node.include?('SystemdNetworkd') && node['SystemdNetworkd'].include?('Teams')
  node['SystemdNetworkd']['Teams'].each_key do |team_name|
    template "#{outdir}/team/team_#{team_name}.netdev" do
      source 'team/team_netdev.erb'
      variables({
                  TeamName: team_name
                })
      mode 0o644
      owner 'systemd-network'
      group 'systemd-network'
      action :create
    end

    template "#{outdir}/team/team_#{team_name}.swport" do
      source 'team/team_swport.erb'
      variables(DevName: team_name)
      mode 0o644
      owner 'systemd-network'
      group 'systemd-network'
      action :create
      only_if do
        node['SystemdNetworkd']['Teams'][team_name].include?('Attributes') ||
          node['SystemdNetworkd']['Teams'][team_name].include?('Vlans')
      end
    end

    template "#{outdir}/team/team_#{team_name}.network" do
      source 'team/team_network.erb'
      variables(DevName: team_name)
      mode 0o644
      owner 'systemd-network'
      group 'systemd-network'
      action :create
      notifies :restart, 'service[systemd-networkd]', :delayed
      only_if { node['SystemdNetworkd']['Teams'][team_name].include?('FDB') }
    end

    if node['SystemdNetworkd']['Teams'][team_name].include?('Members')
      node['SystemdNetworkd']['Teams'][team_name]['Members'].each do |member|
        template "#{outdir}/team/team_#{team_name}_#{member}.network" do
          source 'team/team_network_member.erb'
          variables({
                      TeamName: team_name,
                      Member: member
                    })
          mode 0o644
          owner 'systemd-network'
          group 'systemd-network'
          action :create
          notifies :restart, 'service[systemd-networkd]', :delayed
        end

        link "#{outdir}/team_#{team_name}_#{member}.network" do
          to "#{outdir}/team/team_#{team_name}_#{member}.network"
          only_if do
            node['SystemdNetworkd']['Teams'][team_name]['Enabled'] == true || node['SystemdNetworkd']['Backup'] == true
          end
        end
      end
    end

    next unless node['SystemdNetworkd']['Teams'][team_name].include?('Enabled')

    unless node['SystemdNetworkd']['Teams'][team_name]['Enabled'] == true || node['SystemdNetworkd']['Backup'] == true
      next
    end

    link "#{outdir}/team_#{team_name}.netdev" do
      to "#{outdir}/team/team_#{team_name}.netdev"
    end

    link "#{outdir}/team_#{team_name}.swport" do
      to "#{outdir}/team/team_#{team_name}.swport"
      only_if do
        team = node['SystemdNetworkd']['Teams'][team_name]
        team.include?('Attributes') || team.include?('Vlans')
      end
    end

    link "#{outdir}/team_#{team_name}.network" do
      to "#{outdir}/team/team_#{team_name}.network"
      only_if { node['SystemdNetworkd']['Teams'][team_name].include?('FDB') }
    end
  end
end
# rubocop:enable Metrics/BlockLength
