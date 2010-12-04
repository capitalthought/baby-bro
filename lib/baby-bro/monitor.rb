%w(project monitor_options).each do |file|
  require File.join(File.dirname(__FILE__),file)
end

module BabyBro
  class Monitor
    include MonitorOptions
    attr_accessor :data_directory, :projects, :options

    def initialize( options )
      process_base_options( options )
      @options = HashObject.new(options)
      initialize_databases
    end
    
    def run
      @continue = true
      @previous_SIGINT_handler = Kernel.trap( "SIGINT" ) {}
      Kernel.trap( "SIGINT" ) { 
        puts "Baby Bro is shutting down."
        self.stop; 
        if @previous_SIGINT_handler != "DEFAULT" && @previous_SIGINT_handler != "IGNORE"
          Kernel.trap( "SIGINT" ) { @previous_SIGINT_handler.call }
        else
          Kernel.trap( "SIGINT" ) { @main_thread.raise(SystemExit.new) }
        end
      }
      main
    end
    
    def stop
      @continue = false
    end
    
    private
      def main
        while( @continue )
          self.projects.each do |project|
            # puts "Polling #{project.name}: #{project.directory}"
            project.log_updates
          end
          sleep @polling_interval
        end   
      end
      
  end
end