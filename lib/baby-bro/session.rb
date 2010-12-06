module BabyBro
  class Session
    include Files
    attr_accessor :start_time, :start_date
    
    def self.create_session( time, dirname )
      session = Session.new( time, dirname )
    end
    
    def self.load_session( session_filename )
      Session.new( session_filename )
    end
    
    def update_activity( time )
      touch_file( self.filename, time )
    end
    
    def filename
      basename = @start_time.strftime("%Y-%m-%d_%H:%M:%S")
      File.join(@dirname, basename)
    end
    
    def last_activity
      file_timestamp(self.filename)
    end
    
    def destroy
      File.delete( self.filename )
    end
    
    def duration
      duration = last_activity - @start_time
      duration < 0 ? 0 : duration
    end

    def duration_in_english
      Session.duration_in_english( self.duration )
    end
    
    def self.duration_in_english( duration )
      time = []
      time_duration = duration
      days = hours = minutes = seconds = 0
      if time_duration > 1.day
        days = (time_duration / 1.day).to_i
        time_duration -= days.days
        time << "#{days}d" if days != 0
      end
      if time_duration > 1.hour
        hours = (time_duration / 1.hour).to_i
        time_duration -= hours.hours
        time << "#{hours}h" if hours != 0
      end
      if time_duration > 1.minute
        minutes = (time_duration / 1.minute).to_i
        time_duration -= minutes.minutes
        time << "#{minutes}m"
      end
      time << "#{time_duration.to_i}s"
      breakdown = time.join(' ')
      output = "#{"%05.2f" % (duration/1.hour)} hours or #{breakdown}"
    end
    
    def <=> b
      self.start_date <=> b.start_date
    end
    
    private 
    def initialize( time_or_session_filename, dirname=nil )
      if time_or_session_filename.is_a? Time
        @start_time = time_or_session_filename
        @start_date = Date.civil( @start_time.year, @start_time.month, @start_time.day )
        @dirname = dirname
        self.update_activity( @start_time )
      elsif time_or_session_filename.is_a? String
        date_string = File.basename( time_or_session_filename )
        @dirname = File.dirname( time_or_session_filename )
        date_parts, time_parts = date_string.split('_')
        hour, minutes, seconds = time_parts.split(':').map(&:to_i)
        year, month, day = date_parts.split('-').map(&:to_i)
        @start_time = Time.local( year, month, day, hour, minutes, seconds )
        @start_date = Date.civil( year, month, day )
        unless self.filename == time_or_session_filename
          puts "filename: #{self.filename}"
          puts "time_or_session_filename: #{time_or_session_filename}"
          raise "bad filename for time" 
        end
      else
        raise "Unknown Session initializer"
      end
    end
  end
end