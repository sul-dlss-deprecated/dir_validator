#! /usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path(File.join('..', '..', 'lib'), __FILE__))
require 'dir_validator'

def main

  dv = DirValidator.new('spec/fixtures/sohp')
  # create root_parent Validator
  # load the Catalog

  dv.file('foobar', :name => 'bogus1.txt')

  ds = dv.dirs('druid_dir', :re => /^(\w{11})$/, :n  => '1+')
  # When calling dirs(), dir(), files(), and file(), the user supplies:
  #   a validation identifier (will be used when reporting problems)
  #   optional name-related specs
  #   optional quantity-related specs
  #
  # dirs() returns an enumerable object of Catalog Items, such that:
  #   Item.filetype is directory.
  #   Item.already_matched is false.
  #   regex tests pass.
  #
  # In addition:
  #   Item.already_matched will now be set true.
  #   A warning is logged if the N of matching Items < N wanted.
  #   The method never returns more than N wanted, and excess Items will remain unmatched.

  ds.each { |dir| druid_dir_validator(dir) }
  # Caller is responsible for passing the DirValidator into their own methods.

  dv.report()
  # Caller requests report with various options.

end

def druid_dir_validator(dir)

  dir.file('blort', :name => 'bogus2.txt')

  dir.file('preCM', :name => 'preContentMetadata.xml')
  # file() returns
  #   - Same as above: returns an enumerable object.
  #   - But there will never be more than 1 Item in the list.
  #   - Caller must handle 0 Items, if it matters to subsequent code.
  #
  # Note that we are calling file() on a Catalog Item.
  #   - Translates into a file() call on main DirValidator.
  #   - But regex is framed relative to cwd of Item, not DirValidator.

  druid = dir.basename
  # Items provide various convenience methods to obtain file name components.

  img = dir.dir('Images', :name => 'Images')
  pm  = dir.dir('PM',     :name => 'PM')
  sl  = dir.dir('SL',     :name => 'SL')
  sh  = dir.dir('SH',     :name => 'SH')
  # dir() returns a Catalog item ... (same as above)

  druid_n = nil
  img.files('Images-jpg', :re => /^(#{druid}_\d+)_img_(\d+).jpg$/).each do |f|
    druid_n = f.match_data[1]
    # Whenever a regex check is run against an Item, the MatchData stored.

    img.file('Images-md5', :name => f.basename + '.md5')
  end

  pm.files('PM-wav', :re => /^(#{druid_n}_\w+)_pm.wav$/).each do |f|
    prefix = f.match_data[1]
    pm.file('PM-md5',     :name => f.basename + '.md5')
    sl.file('SL-mp3',     :name => prefix + '_sl.mp3')
    sl.file('SL-mp3-md5', :name => prefix + '_sl.mp3.md5')
    sl.file('SL-techmd',  :name => prefix + '_sl_techmd.xml')
    sh.file('SH-wav',     :name => prefix + '_sh.wav')
    sh.file('SH-md5',     :name => prefix + '_sh.wav.md5')
  end

end

main()
