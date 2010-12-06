module BabyBro
  module MonitorConfig
    def process_monitor_config( config )
      @polling_interval = eval(config[:monitor][:polling_interval].gsub(/\s/, '.')) || 5
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
    
    def initialize_databases
      @projects.map!{|p| Project.new(p, config)}
    end
    
  end
end