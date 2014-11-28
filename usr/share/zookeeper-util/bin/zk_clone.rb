localpath = File.expand_path(File.dirname(__FILE__))
require 'java'
require 'optparse'
require File.join(localpath, 'zookeeper.rb')

include Zookeeper

options = {}

optparse = OptionParser.new do|opts|
   opts.banner = "Usage: #{File.basename(__FILE__)} [options] -s <host:port> -t <host:port>"

   options[:verbose] = false
   options[:path]    = "/"
   options[:source]  = ""
   options[:target]  = ""

   opts.on( '-s', '--source_connectstring host:port', String, "Server info for clone source"){|cs| options[:source] = cs}
   opts.on( '-t', '--target_connectstring host:port', String, "Server info for clone target"){|cs| options[:target] = cs}
   opts.on( '-p', '--start_path path', String, "Path to clone, defaults to '/'"){|p| options[:path] = p}
   opts.on( '-v', '--verbose', 'Output more information' ){options[:verbose] = true}
   opts.on( '-h', '--help', 'Display this screen' ){puts opts; exit}
 end
optparse.parse!

source = options[:source]
target = options[:target]
path   = options[:path]

if (source == "" || target == "") 
   puts optparse
   exit
end

puts "# Cloning #{source} into #{target}" if options[:verbose]
puts "# Start path will be \"#{path}\"" if options[:verbose]

zkSource = Zookeeper::Zookeeper.new
zkSource.connect(source)

zkTarget = Zookeeper::Zookeeper.new
zkTarget.connect(target)
zkTarget.verbose = options[:verbose]

zkTarget.clone(zkSource, path)
