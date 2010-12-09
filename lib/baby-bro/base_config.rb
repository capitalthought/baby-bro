module BabyBro
  module BaseConfig
    def self.included( base )
      base.send(:include, Files)
    end
    
    def process_base_config( options )
      @config_file = options[:config_file]
      config = YAML.load( File.open( @config_file ) )
      @last_config_update = file_timestamp( @config_file )
      @projects = config[:projects]
      @data_directory = config[:data][:directory]
      raise "Data directory not specified" unless @data_directory
      @data_directory.gsub!('~', ENV["HOME"])
      # puts "Data Directory: #{@data_directory}"
      config[:data][:pid_file] = File.join(@data_directory, ".pid")
      raise "No projects specified" unless @projects
      validate_projects( @projects )
      puts "Config file #{@config_file} loaded."
      options.merge(config)
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
    
    def initialize_database
      FileUtils.mkdir_p( @data_directory )
      version_file = File.join(@data_directory, '.version')
      unless File.exist?(version_file)
        File.open(version_file, 'w') do |f|
          f.write(::BabyBro.version)
        end
      end
      @projects.map!{|p| Project.new(p, @config)}
    end
    
    def base_config_changed
      if @last_config_update > file_timestamp( @config_file )
        puts "config new"
        return true
      else
        return false
      end
    end
    
  end
end