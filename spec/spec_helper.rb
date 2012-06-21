require 'rspec'
require 'rspec/autorun'
require 'tempfile'

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'boot'))


def fixture_item(dir, file = nil)
  item   = dir.to_s
  item   = File.join(item, file.to_s) if file
  fixdir = File.join('spec', 'fixtures')
  return item.start_with?(fixdir) ? item : File.join(fixdir, item)
end

def i2p(items)
  return items.map { |i| i.path }.sort
end
