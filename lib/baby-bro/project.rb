%w(files).each do |file|
  require File.join(File.dirname(__FILE__),file)
end
module BabyBro
  class Project < HashObject
    attr_accessor :monitor_options
    include Files
    
    def initialize( hash, monitor_options )
      super hash
      @monitor_options = monitor_options
      self.data_dir = File.join( monitor_options.data_directory, self.name.gsub(' ', '_') )
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
    
    def update_last_checked ( time=Time.now )
      `touch -t #{time.strftime("%Y%m%d%H%M.%S")} #{self.last_checked_file}`
    end
    
    def updated_files
      check_time = Time.now
      puts `find #{self.directory} -newer #{self.last_checked_file}`
      update_last_checked( check_time-self.monitor_options.polling_interval )
    end

    def log_updates
      updated_files
    end
    
  end
end