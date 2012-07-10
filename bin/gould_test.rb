#! /usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'boot'))

dv = DirValidator.new(ARGV[0])

dv.dirs('barcode-dir', :re => '\A(\d{14})(_old)?\z', :n  => '1+').each do |bar_dir|
  bar_code = bar_dir.match_data[1]
  content_dir = bar_dir.dir('00-dir', :name => '00').first
  content_dir.files('jpg-files', :re => /\A#{bar_code}_(00_)?\d{4}\.jpg\z/)
end

dv.report()
