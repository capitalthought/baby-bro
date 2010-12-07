desc "Auto generate the Manifest.txt file"
task :create_manifest do
  $root = File.join(File.dirname(__FILE__), '..')
  file_specs = %W{
    History.txt
    Manifest.txt
    PostInstall.txt
    README.rdoc
    Rakefile
    bin/*
    lib/**/*.rb
    spec/*
    tasks/*
  }
  files = file_specs.inject([]){|files, spec| files += Dir.glob( File.join($root, spec) ).map{|filename| filename.gsub(/^#{$root}\//,'')}}
  File.open(File.join($root, 'Manifest.txt'), 'w') do |manifest|
    files.each do |f| 
      manifest.puts f
      puts f
    end
  end
end
  