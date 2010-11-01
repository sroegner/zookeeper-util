require 'java'

# Add all jars in the local path to the programs CLASSPATH
localpath = File.expand_path(File.dirname(__FILE__))
Dir.glob("#{localpath}/libs/*jar").each {|p| $CLASSPATH << p}


host = "192.168.1.34"
port = "2181"
connect_string = "#{host}:#{port}"
SEPARATOR="::"

ZooKeeper = org.apache.zookeeper.ZooKeeper
Stat      = org.apache.zookeeper.data.Stat
@zk = ZooKeeper.new(connect_string, 10000, Proc.new { puts "# main watcher" })

def zk_traverse(path)
  @zk.get_children(path, false).each do |node|
    next if node.eql?('zookeeper')
    stat = Stat.new
    new_path = "#{path}/#{node}".sub(/\/\//, '/')
    d = @zk.get_data(new_path, false, stat) || ''.to_java_bytes
    node_data = "#{String.from_java_bytes(d)}"
    puts node_data.to_s.empty? ? "#{new_path}" : "#{new_path}#{SEPARATOR}'#{node_data}'"    

    zk_traverse(new_path) unless (stat.getNumChildren == 0)
  end
end

zk_traverse('/')
