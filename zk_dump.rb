require 'java'
require 'optparse'

# Add all jars in the local path to the programs CLASSPATH
localpath = File.expand_path(File.dirname(__FILE__))
Dir.glob("#{localpath}/libs/*jar").each {|p| $CLASSPATH << p}

options = {}

optparse = OptionParser.new do|opts|
   opts.banner = "Usage: #{File.basename(__FILE__)} [options] <host:port>"

   options[:verbose] = false
   options[:connect_string] = "localhost:2181"
   options[:column_separator] = "::"
   options[:start_path] = "/"

   opts.on( '-c', '--connectstring host:port', String, "defaults to #{options[:connect_string]}"){|x| options[:connect_string] = x}
   opts.on( '-s', '--separator sep', String, 'separator /path[::]data' ){|cs| options[:column_separator] = cs}
   opts.on( '-p', '--start_path path', String, "path to dump, defaults to '/'"){|sp| options[:start_path] = sp}
   opts.on( '-v', '--verbose', 'Output more information' ){options[:verbose] = true}
   opts.on( '-h', '--help', 'Display this screen' ){puts opts; exit}
 end

optparse.parse!

connect_string = options[:connect_string]
@colsep         = options[:column_separator]

puts "# Using connect string #{connect_string}" if options[:verbose]
puts "# Column separator will be #{@colsep}" if options[:verbose]
puts "# Start path will be #{options[:start_path]}" if options[:verbose]

ZooKeeper = org.apache.zookeeper.ZooKeeper
Stat      = org.apache.zookeeper.data.Stat
@zk = ZooKeeper.new(connect_string, 10000, Proc.new { puts "# Connect Watcher" if options[:verbose] })

def zk_traverse(path)
  @zk.get_children(path, false).each do |node|
    next if node.eql?('zookeeper')
    stat = Stat.new
    new_path = "#{path}/#{node}".sub(/\/\//, '/')
    d = @zk.get_data(new_path, false, stat) || ''.to_java_bytes
    node_data = "#{String.from_java_bytes(d)}"
    puts node_data.to_s.empty? ? "#{new_path}" : "#{new_path}#{@colsep}#{node_data}"    

    zk_traverse(new_path) unless (stat.getNumChildren == 0)
  end
end

zk_traverse(options[:start_path])
