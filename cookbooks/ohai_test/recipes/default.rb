#
# Cookbook Name:: ohai_test
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

if node.include?( "intel_switch" )
  if node[ "intel_switch" ].include?( "Ports" )
    if node[ "intel_switch" ][ "Ports" ].include?( "sw0p2" )
      if node[ "intel_switch" ][ "Ports" ][ "sw0p2" ].include?( "Enabled" )
        if node[ 'intel_switch' ][ 'Ports' ][ 'sw0p2' ][ 'Enabled' ] == "false"

          log "swp0p2 is disabled" do
            level :debug
          end

        end
      end
    end
  end
end

