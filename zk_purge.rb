require 'java'
require 'optparse'
require 'zookeeper'

include Zookeeper

options = {}
optparse = OptionParser.new do|opts|
   opts.banner = "Usage: #{File.basename(__FILE__)} [options] <host:port>"

   options[:verbose] = false
   options[:connect_string] = "localhost:2181"

   options[:path] = "/"
   options[:delete] = false

   opts.on( '-c', '--connectstring host:port', String, "defaults to #{options[:connect_string]}"){|x| options[:connect_string] = x}
   opts.on( '-p', '--path path', String, "path to purge"){|sp| options[:path] = sp}
   opts.on( '-v', '--verbose', 'Output more information' ){options[:verbose] = true}
   opts.on( '-h', '--help', 'Display this screen' ){puts opts; exit}
 end
optparse.parse!

connect_string = options[:connect_string]
path           = options[:path]
zk             = Zookeeper::Zookeeper.new

zk.connect(connect_string)

puts options.inspect if options[:verbose]
puts "# Purging Path #{path}" if options[:verbose]
zk.purge(path)
