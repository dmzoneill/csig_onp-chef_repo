#!/opt/chef/embedded/bin/ruby
require 'rubygems'
require 'json'
require 'date'
require 'mixlib/shellout'

time_string = DateTime.now.strftime( "%Y%m%d%H%M" )

cwp = false
outdir = nil
chefrepo = "/root/chef-repo"

spacer = "-" * 80
puts "Intel Switch Configuration Backup Tool"
puts spacer

while cwp == false do
  puts "Enter chef working copy path [" + chefrepo + "]:"
  outdir = gets.chomp
  if outdir == ""
    outdir = chefrepo
  end

  if Dir.exists?( outdir )
    cwp = true
  else
    puts outdir + " does not exist, try again"
  end
end

puts "Output directory: " + outdir + ""
puts "Executing ohai state collector..."

data = value = %x( ohai intel_switch )
hostname = %x{ hostname }
hostname = hostname.strip
parsed = JSON.parse( data )
root = '{ "name": "' + hostname + '", "run_list" : [ "recipe[systemd_networkd]" ], "normal": "" }'
backup =  '{ "Backup": true }'
hash =  JSON.parse( root )
hash[ "normal" ] = { "SystemdNetworkd" => parsed }
hash[ "normal" ][ "SystemdNetworkd" ].merge!( JSON.parse( backup ) )
jsonf = JSON.pretty_generate( hash )

# create nodes directory if it does not exist
puts "Creating directory: " + outdir + "/nodes"
Dir.mkdir( outdir + "/nodes" ) unless File.exists?( outdir + "/nodes"  )

# delete any conflicting files
if File.exists?( outdir + "/nodes/" + hostname + ".json" )
  puts "Deleting previous configuration: " + outdir + "/nodes/" + hostname + ".json"
  File.delete( outdir + "/nodes/" + hostname + ".json" )
end

# write switch configuration out
File.open( outdir + "/nodes/" + hostname + ".json" , "w" ) do |f|
  puts "Writing configuration file: " + outdir + "/nodes/" + hostname + ".json"
  f.write( jsonf )
end

puts spacer
puts "Executing chef and generating backup"
puts spacer

# generate systemd netowrkd backup from json 
cc = Mixlib::ShellOut.new( "chef-client -N " + hostname + " -z", :cwd => outdir )
chefRunLog = cc.run_command.stdout.to_s 

logname = "now"
if chefRunLog.match( /\/etc\/systemd\/network\/backup\/([0-9]+)\// ) 
  logname = $1
end

# delete afterwards to prevent unwanted usage
File.delete( outdir + "/nodes/" + hostname + ".json" )

# write log file
File.open( "./log-" + logname, "w" ) do |fp|
  puts "See log file: ./log-" + logname
  fp.write( chefRunLog )
end

puts "Backup: /etc/systemd/network/backup/" + logname + "/"
