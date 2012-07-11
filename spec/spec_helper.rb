require 'rspec'
require 'rspec/autorun'
require 'tempfile'
require 'stringio'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'boot'))


def fixture_item(dir, file = nil)
  # Takes directory name and, optionally, a file name.
  # Returns the path the dir/file within the fixtures directory.
  item   = dir.to_s
  item   = File.join(item, file.to_s) if file
  fixdir = File.join('spec', 'fixtures')
  return item.start_with?(fixdir) ? item : File.join(fixdir, item)
end

def i2p(items)
  # Items-to-paths. Takes a list of Items and returns
  # a list of their paths.
  return items.map { |i| i.path }.sort
end

def p2i(paths)
  # Paths-to-Items. Takes a list of paths and returns
  # a list of Item objects. Paths ending in forward slash
  # will be treated as directories.
  catalog_id = -1
  return paths.map do |p|
    if p.end_with?('/')
      filetype = :dir
      p.chop!          # String will be modified for caller as well.
    else
      filetype = :file
    end
    catalog_id += 1
    item = DirValidator::Item.new(nil, p, catalog_id)
    item.instance_variable_set('@filetype', filetype)
    item
  end
end
