require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/baby-bro'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'baby-bro' do
  self.developer 'Bill Doughty', 'billdoughty@capitalthought.com'
  self.post_install_message = 'PostInstall.txt' # TODO remove  post-install message not required
  self.rubyforge_name       = self.name # TODO this is default value
  self.summary = %Q{File activity monitor for time tracking.}
  self.description = %Q{Baby Bro monitors the timestamps changes for files in directories on your filesystem and records activity and estimates time spent actively working in those directories.}
  # self.extra_deps         = [['activesupport','>= 2.0.2']]

end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
