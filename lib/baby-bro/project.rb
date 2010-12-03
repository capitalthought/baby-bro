%w(files).each do |file|
  require File.join(File.dirname(__FILE__),file)
end
module BabyBro
  class Project < HashObject
    include Files
    
    def initialize( hash, data_root_directory )
      super hash
      self.data_dir = File.join( data_root_directory, self.name.gsub(' ', '_') )
      FileUtils.mkdir_p( self.data_dir )
      self.last_checked_file = File.join( self.data_dir, "last_checked" )
      FileUtils.touch( self.last_checked_file ) unless File.exist?( self.last_checked_file )
      self.reports_dir = File.join( self.data_dir, "reports" )
      FileUtils.mkdir_p( self.reports_dir )
      self.timestamps_dir = File.join( self.data_dir, "timestamps" )
      FileUtils.mkdir_p( self.timestamps_dir )
    end
    
    def last_checked
      file_timestamp self.last_checked_file
    end
    
    def last_checked=( time=Time.now )
      touch_file self.last_checked_file
    end
    
    def updated_files
      puts `find #{self.directory} -newer #{self.last_checked_file}`
    end

    def log_updates
      updated_files
    end
    
  end
end