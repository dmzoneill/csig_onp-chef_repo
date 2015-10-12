module DelConfigFiles

  def keep_ufd( file_content , ufds_enabled )
    if file_content =~ /\[Network\]\s+BindCarrier=/
      if file_content =~ /\[Match\]\s+Name=(\w+)\s+/
        enabled_test_case = $1
        ufds_enabled.each do | ufd |
          if enabled_test_case == ufd
            return 1  
          end
        end
      end
    end
    return 0
  end


  def keep_team( file_content , teams_enabled )
    if file_content =~ /\[(Match|NetDev|Network)\]\s+(Name)=(\w+)\s+\[(Match|NetDev|Network)\]\s+(Team)=(\w+)/
      enabled_test_case = $6
      teams_enabled.each do | team |
        if enabled_test_case == team
          return 1
        end
      end
    elsif file_content =~ /\[(Match|NetDev|Network)\]\s+(Name|Team)=(\w+)\s+/
      enabled_test_case = $3
      teams_enabled.each do | team |
        if enabled_test_case == team
          return 1
        end
      end
    end

    return 0
  end


  def keep_link( file_content , ports_enabled )
    if file_content =~ /\[Match\]\s+(Name|PhysPortID)=(\w+)\s+/
      text_grep = $1
      enabled_test_case = $2
      ports_enabled.each do | port |
        port_num = ""
        if port =~ /sw\dp(\d+)/
          port_num = $1
        end 

        if text_grep == "Name"
          if enabled_test_case == port
            return 1
          end
        elsif text_grep == "PhysPortID"
          if enabled_test_case == port_num
            return 1
          end
        end
      end
    end
    return 0
  end


  def del_files( ports_enabled, ufds_enabled, teams_enabled )
    
    ret = 0
    cc = Mixlib::ShellOut.new( "ls /etc/systemd/network" )
    file_array = cc.run_command.stdout.to_s.split( " " )

    ports_enabled.push( "sw0p0" )

    file_array.each do | file |
      if file == "p1p1.network"
	log( "#{file} found: not deleting" )
      elsif file =~ /\.(swport|network|link|netdev)/
        cc = Mixlib::ShellOut.new( "cat /etc/systemd/network/" + file )
        file_content = cc.run_command.stdout.to_s

        k1 = keep_ufd( file_content , ufds_enabled )
        k2 = keep_team( file_content , teams_enabled )
        k3 = keep_link( file_content , ports_enabled )        

        if k1 == 0 && k2 == 0 && k3 == 0
          log( "deleting #{file}" )
          file "/etc/systemd/network/#{file}" do
            action :delete
            manage_symlink_source false
          end

          ret = 1
        end
      end
    end

    return ret

  end

end

Chef::Recipe.send(:include, DelConfigFiles)
