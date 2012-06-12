project_root = File.expand_path(File.dirname(__FILE__) + '/..')
lib_dir      = File.join(project_root, 'lib')

$LOAD_PATH.unshift(lib_dir)
require 'dir_validator'
