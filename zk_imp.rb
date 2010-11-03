require 'java'
require 'optparse'
require 'zookeeper'

include Zookeeper

options = {}

optparse = OptionParser.new do|opts|
   opts.banner = "Usage: #{File.basename(__FILE__)} [options] <host:port>"

   options[:verbose] = false
   options[:connect_string] = "localhost:2181"
   options[:column_separator] = "::"
   options[:data] = ""
   options[:filename] = ""
   options[:delete] = false

   opts.on( '-c', '--connectstring host:port', String, "defaults to #{options[:connect_string]}"){|x| options[:connect_string] = x}
   opts.on( '-s', '--separator sep', String, 'separator /path[::]data' ){|cs| options[:column_separator] = cs}
   opts.on( '-p', '--path path', String, "path to create or delete"){|sp| options[:path] = sp}
   opts.on( '-n', '--node_data <data>', String, "data to add to the node, if creating"){|sp| options[:data] = sp}
   opts.on( '-d', '--delete', 'Output more information' ){options[:delete] = true}
   opts.on( '-f', '--file FILE', 'the import file to read from' ){|f| options[:filename] = f}
   opts.on( '-v', '--verbose', 'Output more information' ){options[:verbose] = true}
   opts.on( '-h', '--help', 'Display this screen' ){puts opts; exit}
 end
optparse.parse!

connect_string = options[:connect_string]
colsep         = options[:column_separator]


zk = Zookeeper::Zookeeper.new
zk.connect(connect_string)


puts options.inspect if options[:verbose]

stat = Stat.new
path = "#{options[:path]}"
data = "#{options[:data]}".to_java_bytes


if options[:filename].empty?
  # Cannot do anything useful without a path
  if path.empty?
    puts opts
    exit
  end

  if options[:delete]
    puts "# Deleting Path #{path}" if options[:verbose]
    zk.delete(path)
  else
    puts "# Writing data '#{options[:data]}' to Path #{path}" if options[:verbose]
    zk.set_data(path, data)
  end
else
  File.new(options[:filename]).each_line do |line|
    next if line =~ /^\s*\#/
    next if line.empty?

    line.chomp!
    a = line.split(colsep)
    if(a.size == 1)
      puts "# Creating path #{a[0]}" if options[:verbose]
      zk.create_path(a[0].chomp)
    elsif(a.size == 2)
      puts "# Writing data '#{a[1]}' to Path #{a[0]}" if options[:verbose]
      zk.set_data(a[0].chomp, a[1].chomp)
    else
      puts "#{line} is broken"
    end
  end
end
