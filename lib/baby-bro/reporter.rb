%w(project monitor_options).each do |file|
  require File.join(File.dirname(__FILE__),file)
end

module BabyBro
  class Reporter
    include MonitorOptions
    attr_accessor :data_directory, :projects, :options

    def initialize( options, args )
      process_base_options( options )
      process_reporting_options( options )
      @options = HashObject.new(options)
      initialize_databases
    end
    
    def run
      puts 
      puts
      @projects.each do |project|
        print_report( project )
      end
    end
    
    private
      def process_reporting_options( options )
        @date 
      end
      
      def print_report( project, date=nil )
        puts "#{project.name}"
        puts "="*project.name.size
        cumulative_time = 0
        project.sessions.each do |session|
          puts "  * #{session.start_time}"
          puts "    #{session.duration_in_english}"
          cumulative_time += session.duration
        end
        puts " Total: #{Session.duration_in_english(cumulative_time)}"
      end
  end
end