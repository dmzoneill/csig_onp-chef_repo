### Determine chipset version ###

so = Mixlib::ShellOut.new( "ethtool -i sw0p0 | grep driver | awk '{print i\$2}' | tr -d '\n'" )
default[ "ONPPlatform" ] = so.run_command.stdout.to_s

### Generate list of devices for the chipset ###
if default[ "ONPPlatform" ] == "fm10ks"
        default[ "SystemdNetworkd" ][ "PortId" ] = [*1..100].map {|s| "sw0p#{s}" }
else
        default[ "SystemdNetworkd" ][ "PortId" ] = 0
end

