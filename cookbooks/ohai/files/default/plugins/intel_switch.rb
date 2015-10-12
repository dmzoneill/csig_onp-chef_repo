#
# Author:: David O Neill (<david.m.oneill@intel.com>)
# Copyright:: Copyright (c) 2010 Intel Corp.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


Ohai.plugin(:IntelSwitch) do
  provides "intel_switch"


  # Gets the configuration for a port
  # Params:
  # +port+:: the netdev to query
  # Returns:
  # (Mash) the mash of the port configuration
  def get_attributes( port )
    ret = Array.new

    attrs_sysfs = %w[ def_cfi def_dscp def_pri def_swpri drop_bv drop_tagged
                      eee_mode eee_tx_activity_timeout eee_tx_lpi_timeout
                      fabric_loopback ignore_ifg_errors learning loopback
                      parse_mpls parser parser_store_mpls parser_vlan1_tag tagging
                      timestamp_generation update_dscp update_ttl autoneg
                      autoneg_basepage autoneg_link_inhb_timer autoneg_link_inhb_timer_kx
                      replace_dscp routed_frame_update_fields rx_class_pause
                      rx_cut_through swpri_dscp_pref swpri_source tx_class_pause
                      tx_cut_through pause_mode def_pri2 def_vlan2 dot1x_state
                      parser_vlan2_tag security_action tagging2 bcast_flooding
                      ucast_flooding mcast_flooding mcast_pruning bcast_pruning
                      ucast_pruning mac_table_address_aging_time max_frame_size lag_mode  ]
   
    attrs_sd = %w[ DefCfi DefDscp DefPri DefSwpri DropBv DropTagged
                   EeeMode EeeTxActivityTimeout EeeTxLpiTimeout
                   FabricLoopback IgnoreIfgErrors Learning Loopback
                   ParseMpls Parser ParserStoreMpls ParserVlan1Tag Tagging
                   TimestampGeneration UpdateDscp UpdateTtl Autoneg
                   AutonegBasepage AutonegLinkInhbTimer AutonegLinkInhbTimerKx
                   ReplaceDscp RoutedFrameUpdateFields RxClassPause
                   RxCutThrough SwpriDscpPref SwpriSource TxClassPause
                   TxCutThrough PauseMode DefPri2 DefVlan2 Dot1xState
                   ParserVlan2Tag SecurityAction Tagging2 BcastFlooding
                   UcastFlooding McastFlooding McastPruning BcastPruning
                   UcastPruning MacTableAddressAgingTime MaxFrameSize LagMode ]

    for index in 0 ... attrs_sysfs.size
      val = get_attr( port , attrs_sysfs[ index ] )
      if val != ""
        if val.include?( "index" )
          ret = attr_add_multiple( ret , attrs_sd[ index ] , val )
        else
          attrarr = [ attrs_sd[ index ] , val ]
          ret.push( attrarr )
        end
      end
    end

    return ret
  end


  # Gets the QOS configuration for a port
  # Params:
  # +port+:: the netdev to query
  # Returns:
  # (Mash) the mash of the QOS configuration
  def get_qos( port )
    ret = Array.new

    attrs_sysfs = %w[ auto_pause_mode dscp_swpri_map global_usage priv_wm shared_pri_wm
                      shared_soft_drop_wm shared_soft_drop_wm_hog shared_soft_drop_wm_jitter
                      shared_usage swpri_tc_map tc_smp_map trap_class_swpri_map vpri_swpri_map
                      tc_enable private_pause_on_wm private_pause_off_wm shared_pause_off_wm
                      shared_pause_on_wm shared_pause_enable tc_pc_map pc_rxmp_map l2_vpri1_map
                      rx_priority_map tx_priority_map sched_groups smp_lossless_pause
                      sched_group_weight sched_pri_sets sched_group_strict shaping_group_max_rate
                      shaping_group_min_rate shaping_group_max_burst cir_rate cir_action
                      cir_capacity color_source eir_action eir_capacity eir_rate
                      dscp_mkdn_map swpri_mkdn_map mkdn_dscp mkdn_swpri del_policer ]

    attrs_sd = %w[ AutoPauseMode DscpSwpriMap GlobalUsage PrivWm SharedPriWm
                   SharedSoftDropWm SharedSoftDropWmHog SharedSoftDropWmJitter
                   SharedUsage SwpriTcMap TcSmpMap TrapClassSwpriMap VpriSwpriMap
                   TcEnable PrivatePauseOnWm PrivatePauseOffWm SharedPauseOffWm
                   SharedPauseOnWm SharedPauseEnable TcPcMap PcRxmpMap L2Vpri1Map
                   RxPriorityMap TxPriorityMap SchedGroups SmpLosslessPause
                   SchedGroupWeight SchedPriSets SchedGroupStrict ShapingGroupMaxRate
                   ShapingGroupMinRate ShapingGroupMaxBurst CirRate CirAction
                   CirCapacity ColorSource EirAction EirCapacity EirRate
                   DscpMkdnMap SwpriMkdnMap MkdnDscp MkdnSwpri DelPolicer ]

    for index in 0 ... attrs_sysfs.size
      val = get_attr( port , attrs_sysfs[ index ] )
      if val != ""
        if val.include?( "index" )
          ret = attr_add_multiple( ret , attrs_sd[ index ] , val )
        else
          attrarr = [ attrs_sd[ index ] , val ]
          ret.push( attrarr )
        end
      end
    end

    return ret
  end


  # Gets the rate limiting configuration
  # Params:
  # +port+:: the netdev to query
  # Returns:
  # (Mash) the mash of the port configuration
  def get_rate_limit( port )
    ret = Mash.new

    attrs_sysfs = %w[ bcast_rate bcast_capacity mcast_rate mcast_capacity cpu_mac_rate cpu_mac_capacity 
                      igmp_rate igmp_capacity icmp_rate icmp_capacity reserved_mac_rate reserved_mac_capacity 
                      mtu_viol_rate mtu_viol_capacity ]

    attrs_sd = %w[ BcastRate BcastCapacity McastRate McastCapacity CpuMacRate CpuMacCapacity 
                   IgmpRate IgmpCapacity IcmpRate IcmpCapacity ReservedMacRate ReservedMacCapacity 
                   MtuViolRate MtuViolCapacity ]

    for index in 0 ... attrs_sysfs.size
      val = get_attr( port , attrs_sysfs[ index ] )
      if val != ""
        ret[ attrs_sd[ index ] ] = val 
      end
    end

    return ret
  end


  # Gets the L2 hashing configuration for a port
  # Params:
  # +port+:: the netdev to query
  # Returns:
  # (Mash) the mash of the L2 configuration
  def get_l2_hash_key( port )
    ret = Mash.new

    attrs_sysfs = %w[ smac_mask dmac_mask ethertype_mask vlan_id1_mask vlan_pri1_mask symmetrize_mac
                      use_l3_hash use_l2_if_ip ]

    attrs_sd = %w[ SmacMask DmacMask EthertypeMask VlanId1Mask VlanPri1Mask SymmetrizeMac 
                   UseL3Hash UseL2IfIp ]

    for index in 0 ... attrs_sysfs.size
      val = get_attr( port , "l2_hash_key_" + attrs_sysfs[ index ] )
      if val != ""
        ret[ attrs_sd[ index ] ] = val 
      end
    end

    return ret
  end


  # Gets the L3 hashing configuration for a port
  # Params:
  # +port+:: the netdev to query
  # Returns:
  # (Mash) the mash of the L3 configuration
  def get_l3_hash_config( port )
    ret = Mash.new

    attrs_sysfs = %w[ sip_mask dip_mask l4_src_mask l4_dst_mask dscp_mask isl_user_mask 
                         protocol_mask flow_mask symmetrize_l3_fields ecmp_rotation protocol1 protocol2 
                         use_tcp use_udp use_protocol1 use_protocol2 ]

    attrs_sd = %w[ SipMask DipMask L4SrcMask L4DstMask DscpMask IslUserMask 
                      ProtocolMask FlowMask SymmetrizeL3Fields EcmpRotation Protocol1 Protocol2 
                      UseTcp UseUdp UseProtocol1 UseProtocol2 ]

    for index in 0 ... attrs_sysfs.size
      val = get_attr( port , "l3_hash_config_" + attrs_sysfs[ index ] )
      if val != ""
        ret[ attrs_sd[ index ] ] = val 
      end
    end

    return ret
  end


  # Gets the port atrribute value
  # Params:
  # +arr+:: the arr to add the values to
  # +key+:: the attribute to query from sysfs
  # +indexvals+:: the index values that are to be split 
  # Returns:
  # (Mash) return the entire Mash
  def attr_add_multiple( arr , key , indexvals )
    indexvals = indexvals.strip

    if indexvals.include?( "\n" )
      lines = indexvals.split( "\n" )
      for line in 0 ... lines.size
        parts = lines[ line ].split( /index/ )
        attrarr = [ key , parts[1].strip + " " + parts[0].strip ]
        arr.push( attrarr )
      end
    else
      parts = indexvals.split( /index/ )
      attrarr = [ key , parts[1].strip + " " + parts[0].strip ]
      arr.push( attrarr )
    end
    
    return arr
  end


  # Gets the port atrribute value
  # Params:
  # +port+:: the netdev to query
  # +attr+:: the attribute to query from sysfs
  # Returns:
  # (string) the value
  def get_attr( port , attr )
    if File.exists?( "/sys/class/net/" + port + "/switch/" + attr )
      begin
        fb = File.open( "/sys/class/net/" + port + "/switch/" + attr , "r" )
        contents = fb.read
      rescue SystemCallError
        contents = ""
      end
    else
      contents = ""
    end
    return contents.chomp
  end


  # Gets the up/down state of a port
  # Params:
  # +port+:: the netdev to query
  # Returns:
  # (string) "true" / "false"
  def get_state( port )
    line = shell_out( "ip link show " + port + " | head -n 1" ).stdout.strip

    if line =~ /state (\w+)/
      if $1.downcase == "up"
        return true
      else
        return false
      end
    end

    return false
  end


  # Inspects Port configuration
  # Params:
  def get_ports
    ports = Mash.new

    so = shell_out( "ls /sys/class/net/" )

    so.stdout.lines do |line|
      if File.directory?( "/sys/class/net/" + line.strip + "/switch" )
        if line.strip == "sw0p0"
          ports[ line.strip ] = {
            :Attributes => get_attributes( line.strip ),
            :QOS => get_qos( line.strip ),
            :RateLimit => get_rate_limit( line.strip ),
            :L2HashKey => get_l2_hash_key( line.strip ),
            :L3HashConfig => get_l3_hash_config( line.strip )
          }
        else
          if is_port( line.strip ) == true
            ports[ line.strip ] = {
              :Enabled => get_state( line.strip ),
              :Attributes => get_attributes( line.strip ),
              :RateLimit => get_rate_limit( line.strip ),
              :Vlans => get_vlans( line.strip ),
              :QOS => get_qos( line.strip ),
              :FDB => get_fdbs( line.strip )
            }
          end
        end
      end
    end

    return ports
  end


  # Checks to see if netdev is a port
  # Params:
  def is_port( netdev )
    so = shell_out( "ip link" )

    so.stdout.lines do |line|
      if line =~ /master #{netdev}/
        return false
      end
    end

    return true
  end


  # Inspects the team configuration
  # Params:
  def get_teams
    teams = Mash.new

    so = shell_out( "ls /sys/class/net/" )

    # get all the masters
    so.stdout.lines do |line|
      if File.directory?( "/sys/class/net/" + line.strip + "/switch" )
        portline = shell_out( "ip link show " + line.strip + " | head -n 1" ).stdout.strip
        if portline =~ /master (\w+)/
          if teams.key?( $1 ) == false
            teams[ $1 ] = {
              "Enabled" => get_state( $1 ),
              "Members" => get_team_members( $1 ),
              "Attributes" => get_attributes( $1 ),
              "Vlans" => get_vlans( $1 ),
              "FDB" => get_fdbs( $1 )
            }
          end
        end
      end
    end

    return teams
  end


  # Gets the members of a team netdev
  # Params:
  # +master+:: The team netdev to get the member ports
  def get_team_members( master )
    members = Array.new

    so = shell_out( "ls /sys/class/net/" )

    # get all the masters
    so.stdout.lines do |line|
      if File.directory?( "/sys/class/net/" + line.strip + "/switch" )
        portline = shell_out( "ip link show " + line.strip + " | head -n 1" ).stdout.strip
        if portline =~ /\d+: (\w+):.*?master #{master}/
          members.push( $1 )
        end
      end
    end

    return members
  end


  # Gets the vlans assigned to a netdev
  # Params:
  # +master+:: The netdev to get the vlans off
  def get_vlans( netdev )
    vlans = Mash.new
    ids = Array.new

    so = shell_out( "bridge vlan show dev " + netdev )

    # port    vlan ids
    # team1    1 PVID Egress Untagged
    #          20 Egress Untagged
    #          25
    #
    # team1    1 PVID Egress Untagged
    #          20 Egress Untagged
    #          25

    i = 1
    hasvlan = false

    so.stdout.lines do |line|
    
      if line =~ /^port\s+vlan\s+ids$/
        hasvlan = true
      else
        if hasvlan == false
          break
        end

        tag = "tag" + i.to_s
        
        if line =~ /\s(\d+)\s+(Egress Untagged)?/
          tagged = ( $2 == nil ) ? "false" : "true"
          unless ids.include?( $1 )
            [ tag ]= {
              "Id" => $1,
              "EgressUntagged" => tagged
            }
            i += 1
            ids.push( $1 )
          end
        end

        if line =~ /\s(\d+)\s+i(PVID )(Egress Untagged)?/
          tagged = ( $3 == nil ) ? "false" : "true"
          unless ids.include?( $1 )
            vlans[ tag ] = {
              "Id" => $1,
              "Pvid" => $2,
              "EgressUntagged" => tagged
            }
            i += 1
            ids.push( $1 )
          end
        end

      end

    end
   
    return vlans
  end
  
  
  # Inspects FDB configuration
  # Params:
  def get_fdbs( netdev )
    fdbs = Array.new

    so = shell_out( "bridge fdb show brport " + netdev )
    
    so.stdout.lines do |line|
      # ab:bc:cc:00:01:02 vlan 3 self permanent
      if line.strip =~ /^(([0-9a-fA-F][0-9a-fA-F]:){5}([0-9a-fA-F][0-9a-fA-F])) vlan (\d+).*?$/ 
        line.strip.match /^(([0-9a-fA-F][0-9a-fA-F]:){5}([0-9a-fA-F][0-9a-fA-F])) vlan (\d+).*?$/
        entry = [ "MACAddress" , $1 , "VLANId" , $4 ]
        fdbs.push( entry )
      end
    end

    return fdbs
  end
  
 
  # Gets any ports bound to this netdev and returns them as an array 
  def get_ufd_port_binds( netdev )
    Ohai::Log.debug( "Master: " + netdev )   
    bound = false
    boundports = Array.new
    so = shell_out( "networkctl status " + netdev )

    so.stdout.lines do |line|
      if bound == true
        if line.strip.match( /([a-zA-Z0-9]+)/ )
          Ohai::Log.debug( "Match: " + $1 )
          if is_port( $1 ) == true
            Ohai::Log.debug( "Add port: " + $1 )
            boundports.push( $1 )
          else
            break
          end
        else
          break
        end
      elsif line.strip.match( /Carrier Bound To:\s+([a-zA-Z0-9]+)/ )
        Ohai::Log.debug( "Carrier bound to: " + $1 )
        if is_port( $1 ) == true
          Ohai::Log.debug( "Confirmed master: " + $1 )
          boundports.push( $1 )
          bound = true
        end
      end
    end

    return boundports
  end

  # Inspects UFD configuration
  # Params:
  def get_ufd
    ret = Mash.new
    
    soports = shell_out( "ls /sys/class/net/" )

    # get all the masters
    soports.stdout.lines do |port|
      if File.directory?( "/sys/class/net/" + port.strip + "/switch" )

        boundports = get_ufd_port_binds( port.strip )  
        if boundports.length > 0
          ret[ port.strip ] = {
            "Enabled" => true,
            "BindCarrier" => boundports.join( " " )
          }
        end

      end
    end

    return ret
  end


  collect_data do
    intel_switch Mash.new
    intel_switch[:Teams] = get_teams
    intel_switch[:UFD] = get_ufd
    intel_switch[:Ports] = get_ports
  end

end

