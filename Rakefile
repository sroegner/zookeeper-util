#!/usr/bin/env ruby

require 'yaml'

Dir[File.expand_path(File.dirname(__FILE__)) + "/lib/tasks/**/*.rake"].sort.each { |ext| load ext }

desc "Create packages"
task :release => ['release:zip', 'release:tarball']
     
@project_name = File.basename(File.dirname(__FILE__))
v = YAML.load_file('VERSION.yml')
@version_string = "#{v[:major]}.#{v[:minor]}.#{v[:patch]}"

namespace :release do
  desc "Create a zip archive"
  task :zip do
    sh "git archive --format=zip --prefix=#{@project_name}-#{@version_string}/ HEAD > #{@project_name}-#{@version_string}.zip"
  end

  desc "Create a tarball archive"
  task :tarball do
    sh "git archive --format=tar --prefix=#{@project_name}-#{@version_string}/ HEAD | gzip > #{@project_name}-#{@version_string}.tar.gz"
  end
end


