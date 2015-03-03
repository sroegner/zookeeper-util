require 'java'
require 'json'

share_dir = File.dirname(File.dirname(File.dirname(__FILE__)))
Dir.glob(File.join(share_dir, "java/zookeeper-util/*jar")).each {|p| $CLASSPATH << p}

module Zookeeper

  Stat              = org.apache.zookeeper.data.Stat
  DEFAULT_SEPARATOR = "::"

  class Zookeeper

    def connect(connect_string, timeout=1000)
      begin
        @zk = org.apache.zookeeper.ZooKeeper.new(connect_string,
                                                         timeout,
                                                         Proc.new{nil})
      rescue Exception => e
        puts "#{e.cause}"
      end
    end

    def path_exists?(p)
      stat = Stat.new()
      stat = @zk.exists(p, false)
      !!stat
    end

    def create_path(path, data="", acl=nil, mode=nil)
      pp = get_parent_path(path)

      unless path_exists?(pp)
        create_path_recursively(pp)
      end

      # now we can get to the last link in the chain and add the data
      create_acl  = acl.nil? ? default_acl : acl
      create_mode = mode.nil? ? default_mode : mode
      bytes       = to_byte_array(data)

      begin
        @zk.create(path, bytes, create_acl, create_mode)
      rescue
        puts "#{$!}"
      end
    end

    def delete(path, version = -1)
      begin
        puts "Deleting path #{path}"
        @zk.delete(path, version)
      rescue Exception
        puts "#{$!}"
      end
    end

    # can set the data even for non-existing nodes
    # delete the data by leaving the data argument nil or blank
    
    def set_data(path, data = "", version = -1)
      unless path_exists?(path)
        create_path_recursively(path)
      end

      bytes = to_byte_array(data)
      begin
        @zk.set_data(path, bytes, version)
      rescue
        puts "#$!"
      end
    end

    def get_data(path)
      stat = Stat.new
      data = ""
      begin
        bytes = @zk.get_data(path, false, stat)
        data = String.from_java_bytes(bytes) if stat.getDataLength > 0  
      rescue
        puts "#$!"
      end
      return data
    end

    def dump(path, separator=DEFAULT_SEPARATOR)
      @zk.get_children(path, false).each do |node|
        next if path.eql?('/') && node.eql?('zookeeper')
        stat = Stat.new
        new_path = File.join(path, node)
        d = @zk.get_data(new_path, false, stat) || ''.to_java_bytes
        node_data = "#{String.from_java_bytes(d)}".force_encoding("ISO-8859-1").encode("UTF-8").to_json
        puts node_data.to_s.empty? ? "#{new_path}" : "#{new_path}#{separator}#{node_data}"

        dump(new_path, separator) unless (stat.getNumChildren == 0)
      end
    end

    def purge(path)
      @purge_path_top = path
      purge_path(@purge_path_top)
    end


    private

      def purge_path(path)
        @zk.get_children(path, false).each do |node|
          next if path.eql?('/') && node.eql?('zookeeper')

          stat = Stat.new

          new_path = File.join(path, node)
          stat = @zk.exists(new_path, false)
          next if stat.nil?

          if(stat.getNumChildren == 0)
            delete(new_path)
            purge_path(get_parent_path(path)) unless path.eql?(@purge_path_top)
          else
            purge_path(new_path)
          end
        end
      end

      def create_path_recursively(path)
        # given '/a/b/c, this will yield an array with ["a","b","c"]
        tmp_path = path_to_array(path)
        # now starting from the beginning, createall elements like so:
        # create("/a"), create("/a/b"), create("/a/b/c")
        1.upto(tmp_path.size) do |i|
          part = "/#{tmp_path[0,i].join('/')}"
          create_part_of_path(part) unless path_exists?(part)
        end
      end

      # these paths are all created with standard (open) permissions
      def create_part_of_path(path)
        begin
          @zk.create(path, "".to_java_bytes, default_acl, default_mode)
        rescue
          puts "#{$!}"
        end
      end

      def to_byte_array(data)
        data.is_a?(String) ? data.to_java_bytes : data
      end

      def default_mode
        org.apache.zookeeper.CreateMode::PERSISTENT
      end

      # will make newly created paths accessible to everyone
      def default_acl
        acl      = org.apache.zookeeper.data.ACL.new
        acl_id   = org.apache.zookeeper.data.Id.new
        acl_list = java.util.ArrayList.new
              
        acl.set_perms(127)
        acl_id.setId("anyone")
        acl_id.setScheme("world")
        acl.setId(acl_id)

        acl_list.add(acl)
        return acl_list
      end

      def get_parent_path(path)
        a = path_to_array(path)
        a.size == 0 ? '/' : array_to_path(a[0, a.size-1])
      end

      def path_to_array(path)
        path.sub(/\//,'').split('/')
      end

      def array_to_path(a)
        path = a.join('/')
        "/#{path}"
      end

  end
end
