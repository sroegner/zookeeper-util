localpath = File.expand_path(File.dirname(__FILE__))
require 'java'
require 'optparse'
require File.join(localpath, 'zookeeper.rb')

include Zookeeper

options = {}

optparse = OptionParser.new do|opts|
   opts.banner = "Usage: #{File.basename(__FILE__)} [options] -c <host:port>"

   options[:verbose]          = false
   options[:connect_string]   = ""
   options[:column_separator] = "::"
   options[:start_path]       = "/"

   opts.on( '-c', '--connectstring host:port', String, "the server to connect to"){|x| options[:connect_string] = x}
   opts.on( '-s', '--separator sep', String, 'separator /path[::]data' ){|cs| options[:column_separator] = cs}
   opts.on( '-p', '--start_path path', String, "path to dump, defaults to '/'"){|sp| options[:start_path] = sp}
   opts.on( '-v', '--verbose', 'Output more information' ){options[:verbose] = true}
   opts.on( '-h', '--help', 'Display this screen' ){puts opts; exit}

   if(ARGV.size == 0)
     puts opts
     exit
   end


 end
optparse.parse!

connect_string = options[:connect_string]
colsep         = options[:column_separator]
start_path     = options[:start_path]

puts "# Using connect string #{connect_string}" if options[:verbose]
puts "# Column separator will be #{colsep}" if options[:verbose]
puts "# Start path will be #{start_path}" if options[:verbose]

zk = Zookeeper::Zookeeper.new
zk.connect(connect_string)
zk.dump(start_path, colsep)
