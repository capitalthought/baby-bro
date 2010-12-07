require 'rubygems'
# gem 'hoe', '>= 2.1.0'
# require 'hoe'
require 'fileutils'
require './lib/baby-bro'

# Hoe.plugin :newgem
# # Hoe.plugin :website
# # Hoe.plugin :cucumberfeatures
# 
# # Generate all the Rake tasks
# # Run 'rake -T' to see list of generated tasks (from gem root directory)
# $hoe = Hoe.spec 'baby-bro' do
#   self.developer 'Bill Doughty', 'billdoughty@capitalthought.com'
#   self.post_install_message = 'PostInstall.txt' # TODO remove  post-install message not required
#   self.rubyforge_name       = self.name # TODO this is default value
#   self.summary = %Q{File activity monitor for automatic time tracking.}
#   self.description = %Q{Baby Bro monitors the timestamps changes for files in directories on your filesystem and records time spent actively working in those directories.}
#   # self.extra_deps         = [['activesupport','>= 2.0.2']]
# 
# end
# 
# require 'newgem/tasks'
# Dir['tasks/**/*.rake'].each { |t| load t }
# 
# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "baby-bro"
    gem.summary = %Q{File activity monitor for time tracking.}
    gem.description = %Q{Baby Bro monitors timestamp changes of files and and estimates time spent actively working in project directories.}
    gem.email = "billdoughty@capitalthought.com"
    gem.homepage = "http://github.com/capitalthought/baby-bro"
    gem.authors = ["Bill Doughty"]
    gem.add_development_dependency "rspec", ">= 1.3.1"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "baby-bro #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end                                                                                            
