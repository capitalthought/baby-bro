%w(project base_config monitor_config).each do |file|
  require File.join(File.dirname(__FILE__),file)
end

module BabyBro
  class Monitor
    include BaseConfig
    include MonitorConfig
    attr_accessor :data_directory, :projects, :config

    def initialize( options )
      load_config( options )
    end

    def start
      if pid = active_pid && !( @config.force_start )
        puts "ERROR: PID file detected.  Cannot start baby-bro."
        puts "Check if process #{active_pid} is running."
        puts "If it is not, use the -f option to overwrite the PID file (#{pid_file})."
        return false
      end
      @continue = true
      @previous_SIGINT_handler = Kernel.trap( "SIGINT" ) {}
      Kernel.trap( "SIGINT" ) do
        print "Baby Bro monitor is shutting down..."
        $stdout.flush
        @continue = false;
        if @previous_SIGINT_handler != "DEFAULT" && @previous_SIGINT_handler != "IGNORE"
          Kernel.trap( "SIGINT" ) { @previous_SIGINT_handler.call }
        end
      end
      pid = Process.fork
      if pid.nil? then
        # In child
        main
      else
        # In parent
        Process.detach(pid)
        create_pid_file( pid )
        puts "Baby Bro monitor started."
      end
      return true
    end

    def stop
      unless pid = active_pid
        puts "ERROR: No pid file found for Baby Bro (#{pid_file})."
        puts "If Baby Bro monitor is running, you need to kill it manually."
        return false
      end
      begin
        puts "Sending SIGINT to Baby Bro monitor process #{pid}."
        Process.kill( "SIGINT", pid )
      rescue Errno::ESRCH
        puts "No Baby Bro monitor process found with PID #{pid}."
        puts "Removing PID file #{pid_file}."
        remove_pid_file
      end
      sleep_time = 10.0
      while( true )
        begin
          Process.kill( 0, pid ) # check if the process is still alive, raises Errno::ESRCH if not
          sleep 0.1
          sleep_time -= 0.1
          if sleep_time == 0
            Process.kill( "SIGKILL", pid )
            puts "Baby Bro monitor process #{pid} not responding to SIGINT."
            puts "Sending SIGKILL to Baby Bro monitor process #{pid}."
          end
        rescue Errno::ESRCH
          break
        end
      end
      puts "Baby Bro monitor terminated."
      return true
    end

    def status
      if pid = active_pid
        begin
          Process.kill( 0, pid ) # check if the process is still alive, raises Errno::ESRCH if not
          puts "Baby Bro monitor process is running with PID #{pid}."
        rescue Errno::ESRCH
          puts "PID file #{pid_file} found, but no Baby Bro monitor process is running with PID #{pid}."
          remove_pid_file
          puts "PID file removed."
        end
      else
        puts "Baby Bro monitor process is not running."
      end
    end

    private
      def main
        while( @continue )
          load_config( @config ) if base_config_changed
          self.projects.each do |project|
            # tron "Polling #{project.name}: #{project.directory}"
            project.log_activity
          end
          interruptable_sleep( @polling_interval ) do; @continue; end
        end
        remove_pid_file
        puts "complete."
      end

      def active_pid
        File.exist?( pid_file ) && File.read(pid_file).to_i
      end

      def pid_file
        self.config.data.pid_file
      end

      def remove_pid_file
        File.delete( pid_file )
      end

      def create_pid_file( pid )
        File.open( pid_file, 'w' ) do |f|
          f.write( pid.to_s )
        end
      end

      def load_config( options )
        @config = HashObject.new( process_base_config( options ), true )
        process_monitor_config( @config )
        initialize_database
      end

      def tron string
        $stdout.puts if @config && @config.tron
      end

      def interruptable_sleep sleep_time, guard_interval=1
        if block_given?
          while( yield && sleep_time > 0 )
            sleep guard_interval
            sleep_time -= guard_interval
          end
        else
          sleep sleep_time
        end
      end

  end
end