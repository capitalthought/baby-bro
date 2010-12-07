%w(files session).each do |file|
  require File.join(File.dirname(__FILE__),file)
end

module BabyBro
  class Project < HashObject
    attr_accessor :config
    include Files
    
    def initialize( hash, config )
      super hash
      @config = config
      self.data_dir = File.join( config.data.directory, self.name.gsub(' ', '_') )
      FileUtils.mkdir_p( self.data_dir )
      self.last_checked_file = File.join( self.data_dir, "last_checked" )
      FileUtils.touch( self.last_checked_file ) unless File.exist?( self.last_checked_file )
      self.monitor_start_file = File.join( self.data_dir, "monitor_start" )
      FileUtils.touch( self.monitor_start_file ) unless File.exist?( self.monitor_start_file )
      self.reports_dir = File.join( self.data_dir, "reports" )
      FileUtils.mkdir_p( self.reports_dir )
      self.sessions_dir = File.join( self.data_dir, "sessions" )
      FileUtils.mkdir_p( self.sessions_dir )
    end
    
    def last_checked
      file_timestamp self.last_checked_file
    end
    
    def update_last_checked ( time=Time.now )
      touch_file( self.last_checked_file, time )
    end
    
    def get_updated_files
      files = find_files_newer_than_file(self.directory, self.last_checked_file)
      files
    end
    
    def find_active_session
      session_files = find_recent_files(self.sessions_dir, self.config.monitor.idle_interval)
      session_files = session_files.reject{|e| e.strip!;e.nil? || e=="" || e == self.sessions_dir}
      if session_files.length > 1
        session_files.sort!
      end
      Session.load_session(session_files.last) if session_files.any?
    end

    def sessions
      session_files = find_files( self.sessions_dir )
      session_files.sort.map{|f| Session.load_session(f)}
    end
    
    def log_activity
      check_time = Time.now
      updated_files = self.get_updated_files
      updated_files.each do |file|
        tron file
      end
      if updated_files.any?
        process_activity( check_time )
      end
      update_last_checked( check_time-1 )
    end
    
    def process_activity( check_time )
      if session = find_active_session
        session.update_activity( check_time )        
        if session.start_date < Date.today # start a new session for today
          session = Session.create_session( check_time, self.sessions_dir )
        end
      else
        session = Session.create_session( check_time, self.sessions_dir )
      end
      tron "#{self.name} Session Activity: "
      tron "  start_time: #{session.start_time}"
      tron "  duration: #{session.duration_in_english}"
    end
    
    private
     def tron string
       if config.tron
         $stdout.puts string 
       end
     end
  end
end