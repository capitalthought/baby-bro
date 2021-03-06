module BabyBro
  module Files

    def file_timestamp( filename )
      file = File.new(filename)
      mtime = file.mtime
      file.close
      mtime
    end
    
    def touch_file( filename, time )
      `touch -t #{time.strftime("%Y%m%d%H%M.%S")} #{filename}`
    end
    
    # returns files in the specified directory
    def find_files( directory, pattern='*')
     `find -H '#{directory}' -name "#{pattern}"`.split("\n").reject{|f| f==directory}
    end

    # returns files in the specified directory that are newer than the specified file
    def find_files_newer_than_file( directory, filename )
     `find -H '#{directory}' -newer #{filename}`.split("\n")
    end

    # returns files in the specified directory that are newer than the time expression
    # time_interval_expression is in english, eg.  "15 minutes"
    def find_recent_files( directory, time_interval_expression )
     `find -H '#{directory}' -newermt "#{time_interval_expression} ago"`.split("\n")
    end
  end
end