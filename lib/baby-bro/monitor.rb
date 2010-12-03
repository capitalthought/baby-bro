%w(monitor_options files).each do |file|
  require File.join(File.dirname(__FILE__),file)
end

module BabyBro
  class Monitor
    include MonitorOptions
    include Files
    attr_accessor :data_directory, :projects

    def initialize( options )
      process_options( options )
      initialize_databases
    end
    
    def run
      @continue = true
      main
    end
    
    private
      def main
        while( @continue )
          self.projects.each do |project|
            puts "Polling #{project.name}: #{project.directory}"
            
          end
          sleep 5
        end   
      end
      
      def log_changes( project )
        last_checked = 1
      end
      
      def initialize_databases
        @projects.each do |project|
          project.data_dir = File.join( @data_directory, project.name.gsub(' ', '_') )
          FileUtils.mkdir_p( project.data_dir )
          project.last_checked_file = File.join( project.data_dir, "last_checked" )
          FileUtils.touch( project.last_checked_file ) unless File.exist?( project.last_checked_file )
          project.reports_dir = File.join( project.data_dir, "reports" )
          FileUtils.mkdir_p( project.reports_dir )
          project.timestamps = File.join( project.data_dir, "timestamps" )
          FileUtils.mkdir_p( project.timestamps )
        end
      end
  end
end