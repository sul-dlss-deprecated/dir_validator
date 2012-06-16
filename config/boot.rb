project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
lib_dir      = File.join(project_root, 'lib')

$LOAD_PATH.unshift(lib_dir)

require 'rubygems'
require 'dir_validator'
require 'awesome_print'
