module BabyBro
  module Files

    def file_timestamp( filename )
      File.new(filename).mtime
    end
    
    def touch_file( filename, time )
      `touch -t #{time.strftime("%Y%m%d%H%M.%S")} #{filename}`
    end
    
    # returns files in the specified directory that are newer than the specified file
    def find_files_newer_than_file( directory, filename )
     `find #{directory} -newer #{filename}`
    end

    # returns files in the specified directory that are newer than the time expression
    # time_interval_expression is in english, eg.  "15 minutes"
    def find_recent_files( directory, time_interval_expression )
     `find '#{directory}' -newermt "#{time_interval_expression} ago"`
    end
  end
end