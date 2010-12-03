$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$:.unshift(File.join(File.dirname(__FILE__), 'baby-bro')) unless $:.include?( $:.unshift(File.join(File.dirname(__FILE__), 'baby-bro')) )

module BabyBro
  VERSION = '0.0.1'
end

require 'baby-bro/hash_object'
require 'baby-bro/monitor'
