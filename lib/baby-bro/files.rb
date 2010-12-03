module BabyBro
  module Files

    def file_timestamp( filename )
      File.new(filename).mtime
    end
    
    def touch_file( filename )
      FileUtils.touch( filename )
    end
    
  end
end