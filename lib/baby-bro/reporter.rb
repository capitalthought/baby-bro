%w(project base_config).each do |file|
  require File.join(File.dirname(__FILE__),file)
end

module BabyBro
  class Reporter
    include BaseConfig
    attr_accessor :data_directory, :projects, :config

    def initialize( options, args )
      @config = HashObject.new( process_base_config( options ), true )
      process_reporting_config( @config )
      initialize_database
      date_string = args.shift
      if date_string == 'today'
        @date = Date.today
      elsif date_string == 'yesterday'
        @date = Date.today - 1
      elsif date_string
        begin
          @date = Date.parse(date_string)
        rescue
          @date = Date.today - date_string.to_i
        end
      end
    end
    
    def run
      if @config.brief && @date
        $stdout.puts
        $stdout.puts "#{@date.strftime("%Y-%m-%d")}:" 
      end
      @longest_project_name = @projects.inject(0){|max,p| p.name.size>max ? p.name.size : max}
      @projects.each do |project|
        print_project_report( project, @date )
      end
    end
    
    private
      def process_reporting_config( config )
      end
      
      def print_project_report( project, report_date=nil )
        sessions = project.sessions
        return if @config.brief && sessions.empty?
        if true
          if @config.brief && report_date
            $stdout.print "  #{project.name}#{" "*(@longest_project_name - project.name.size)}  :"
          else
            $stdout.puts
            $stdout.puts "#{project.name}"
            $stdout.puts "="*project.name.size
          end
          cumulative_time = 0
          if sessions.any?
            sessions_by_date = sessions.group_by(&:start_date)
            has_sessions_for_date = false
            sessions_by_date.keys.sort.each do |date|
              next if report_date && date != report_date
              sessions = sessions_by_date[date].sort
              $stdout.puts "  #{date.strftime("%Y-%m-%d")}" unless @config.brief && report_date
              sessions.each do |session|
                $stdout.puts "      #{session.start_time.strftime("%I:%M %p")} - #{session.duration_in_english}" unless @config.brief
                cumulative_time += session.duration
              end
              has_sessions_for_date = true
              $stdout.print "    Total:" unless @config.brief && report_date
              $stdout.print "  #{Session.duration_in_english(sessions.inject(0){|sum,n| sum = sum+n.duration})}"
            end
            $stdout.puts has_sessions_for_date ? "" : "     no activity"
            $stdout.puts "Grand Total: #{Session.duration_in_english(cumulative_time)}" unless @config.brief
          else
            $stdout.puts "  No sessions for this project."
          end
        end
      end
  end
end