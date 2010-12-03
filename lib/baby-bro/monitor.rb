%w(project monitor_options).each do |file|
  require File.join(File.dirname(__FILE__),file)
end

module BabyBro
  class Monitor
    include MonitorOptions
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
            project.log_updates
          end
          sleep @polling_interval
        end   
      end
      
      def initialize_databases
        @projects.map!{|p| Project.new(p, @data_directory)}
      end
  end
end