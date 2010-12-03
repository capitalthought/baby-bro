%w(files session).each do |file|
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
      self.monitor_start_file = File.join( self.data_dir, "monitor_start" )
      FileUtils.touch( self.monitor_start_file ) unless File.exist?( self.monitor_start_file )
      self.last_activity_file = File.join( self.data_dir, "last_activity" )
      self.reports_dir = File.join( self.data_dir, "reports" )
      FileUtils.mkdir_p( self.reports_dir )
      self.sessions_dir = File.join( self.data_dir, "sessions" )
      FileUtils.mkdir_p( self.sessions_dir )
    end
    
    def last_checked
      file_timestamp self.last_checked_file
    end
    
    def last_activity
      file_timestamp self.last_activity_file if File.exist?( self.last_activity_file )
    end
    
    def update_last_checked ( time=Time.now )
      touch_file( self.last_checked_file, time )
    end
    
    def update_last_activity ( time=Time.now )
      touch_file( self.last_activity_file, time )
    end
    
    def get_updated_files
      @check_time = Time.now
      files = find_files_newer_than_file(self.directory, self.last_checked_file)
      update_last_checked( @check_time-1 )
      files.split("\n")
    end
    
    def find_active_session
      session_files = find_recent_files(self.sessions_dir, self.monitor_options.idle_interval)
      session_files = session_files.split("\n").reject{|e| e.strip!;e.nil? || e=="" || e == self.sessions_dir}
      if session_files.length > 1
        session_files.sort!
      end
      Session.load_session(session_files.last) if session_files.any?
    end

    def log_updates
      updated_files = get_updated_files
      updated_files.each do |file|
        puts file
      end
      if updated_files.any?
        process_activity
      end
    end
    
    def process_activity
      update_last_activity( @check_time )
      if session = find_active_session
        session.update_activity( @check_time )        
        if session.start_date < Date.today # start a new session for today
          session = Session.create_session( @check_time, self.sessions_dir )
        end
      else
        session = Session.create_session( @check_time, self.sessions_dir )
      end
      puts "Session Activity: "
      puts "  start_time: #{session.start_time}"
      puts "  duration: #{session.duration_in_english}"
    end
  end
end