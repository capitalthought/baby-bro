require 'optparse'
require 'fileutils'
require 'pp'
require 'yaml'

module BabyBroExec
  # This module handles the various BabyBro executables (`baby-bro`, etc).
  module Exec
    class Generic
      # @param args [Array<String>] The command-line arguments
      def initialize(args)
        @args = args
        @options = {}
      end

      # Parses the command-line arguments and runs the executable.
      # Calls `Kernel#exit` at the end, so it never returns.
      #
      # @see #parse
      def parse!
        begin
          parse
        rescue Exception => e
          raise e if @options[:tron] || e.is_a?(SystemExit) || true

          $stderr.print "#{e.class}: " unless e.class == RuntimeError
          $stderr.puts "#{e.message}"
          $stderr.puts "  Use --tron for stacktrace."
          exit 1
        end
        exit 0
      end

      # Parses the command-line arguments and runs the executable.
      # This does not handle exceptions or exit the program.
      #
      # @see #parse!
      def parse
        @opts = OptionParser.new(&method(:set_opts))
        @opts.parse!(@args)

        process_result

        @options
      end

      # @return [String] A description of the executable
      def to_s
        @opts.to_s
      end

      protected

      # Finds the line of the source template
      # on which an exception was raised.
      #
      # @param exception [Exception] The exception
      # @return [String] The line number
      def get_line(exception)
        # SyntaxErrors have weird line reporting
        # when there's trailing whitespace,
        # which there is for BabyBro documents.
        return (exception.message.scan(/:(\d+)/).first || ["??"]).first if exception.is_a?(::SyntaxError)
        (exception.backtrace[0].scan(/:(\d+)/).first || ["??"]).first
      end

      # Tells optparse how to parse the arguments
      # available for all executables.
      #
      # This is meant to be overridden by subclasses
      # so they can add their own options.
      #
      # @param opts [OptionParser]
      def set_opts(opts)
        opts.banner = <<END
Usage: bro [options] [command]

Command is one of the following:

  start - starts the monitor process in the background
  stop - stops the monitor process
  status - prints the status of the monitor process
  restart - restarts the monitor process (forces re-reading of config file)
  report - prints out time tracking reports
  
END

        @options[:config_file] = "#{ENV["HOME"]}/.babybrorc"
        @options[:tron] = false
        opts.on('-c', '--config FILE', "Use this config file.  default is #{@options[:config_file]}") do |config_file|
          @options[:config_file] = config_file
        end

        opts.on('-t', '--tron', :NONE, 'Trace on.  Show debug output and a full stack trace on error') do
          @options[:tron] = true
        end

        opts.on('-f', '--force', :NONE, 'Force starting of monitor when PID file is stale.') do
          @options[:force_start] = true
        end

        opts.on_tail("-?", "-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("-v", "--version", "Print version") do
          puts("BabyBro #{::BabyBro::VERSION}")
          exit
        end
      end

      # Processes the options set by the command-line arguments.
      #
      # This is meant to be overridden by subclasses
      # so they can run their respective programs.
      def process_result
      end

      COLORS = { :red => 31, :green => 32, :yellow => 33 }

      # Prints a status message about performing the given action,
      # colored using the given color (via terminal escapes) if possible.
      #
      # @param name [#to_s] A short name for the action being performed.
      #   Shouldn't be longer than 11 characters.
      # @param color [Symbol] The name of the color to use for this action.
      #   Can be `:red`, `:green`, or `:yellow`.
      def puts_action(name, color, arg)
        printf color(color, "%11s %s\n"), name, arg
      end

      # Wraps the given string in terminal escapes
      # causing it to have the given color.
      # If terminal esapes aren't supported on this platform,
      # just returns the string instead.
      #
      # @param color [Symbol] The name of the color to use.
      #   Can be `:red`, `:green`, or `:yellow`.
      # @param str [String] The string to wrap in the given color.
      # @return [String] The wrapped string.
      def color(color, str)
        raise "[BUG] Unrecognized color #{color}" unless COLORS[color]

        # Almost any real Unix terminal will support color,
        # so we just filter for Windows terms (which don't set TERM)
        # and not-real terminals, which aren't ttys.
        return str if ENV["TERM"].nil? || ENV["TERM"].empty? || !STDOUT.tty?
        return "\e[#{COLORS[color]}m#{str}\e[0m"
      end

      private

      def open_file(filename, flag = 'r')
        return if filename.nil?
        flag = 'wb' if @options[:unix_newlines] && flag == 'w'
        File.open(filename, flag)
      end

      def handle_load_error(err)
        dep = err.message[/^no such file to load -- (.*)/, 1]
        raise err if @options[:tron] || dep.nil? || dep.empty?
        $stderr.puts <<MESSAGE
Required dependency #{dep} not found!
    Run "gem install #{dep}" to get it.
  Use --tron for stacktrace.
MESSAGE
        exit 1
      end
    end
    
    class Bro < Generic
      # Processes the options set by the command-line arguments.
      #
      # This is meant to be overridden by subclasses
      # so they can run their respective programs.
      def process_result
        args = @args.dup
        command = args.shift
        case command
        when 'start', nil
          monitor = ::BabyBro::Monitor.new( @options )
          monitor.start
        when 'stop'
          monitor = ::BabyBro::Monitor.new( @options )
          monitor.stop
        when 'status'
          monitor = ::BabyBro::Monitor.new( @options )
          monitor.status
        when 'restart'
          monitor = ::BabyBro::Monitor.new( @options )
          monitor.stop && monitor.start
        when 'report'
          reporter = ::BabyBro::Reporter.new( @options, args )
          reporter.run
        else
          puts "Unknown command: #{command}"
        end
      end

    end

  end
end
