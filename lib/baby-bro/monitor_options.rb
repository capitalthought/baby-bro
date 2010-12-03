module BabyBro
  module MonitorOptions
    def process_options( options )
      @projects = options[:projects]
      @data_directory = options[:data_directory]
      @polling_interval = options[:polling_interval] || 5
      raise "data directory not specified" unless @data_directory
      @data_directory.gsub!('~', ENV["HOME"])
      puts "Data Directory: #{@data_directory}"
      FileUtils.mkdir_p( @data_directory )
      raise "no projects specified" unless @projects
      validate_projects( @projects )
    end
    
    def validate_projects( projects )
      projects.each_with_index do |project, i|
        raise "No name given for project #{i}" unless project[:name]
        raise "No directory given for project #{project[:name]}" unless project[:directory]
        project[:directory].gsub!('~', ENV["HOME"])
        begin
          Dir.entries( project[:directory] )
        rescue
          raise "Invalid directory #{project[:directory]} for project #{project[:name]}"
        end
      end
      project_names = projects.map{|p| p[:name]}
      project_dirs = projects.map{|p| p[:directory]}
      dup_names = project_names - project_names.uniq
      dup_dirs = project_dirs - project_dirs.uniq
      raise "ERROR: Duplicate project name(s) not allowed: #{dup_names.join(", ")}" if dup_names.any?
      raise "ERROR: Duplicate project directories(s) allowed: #{dup_dirs.join(", ")}" if dup_dirs.any?
    end    
  end
end