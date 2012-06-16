#! /usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'boot'))


def main

  dv = DirValidator.new('spec/fixtures/sohp')
  # create root_parent Validator
  # load the Catalog

  ds = dv.dirs('druid_dir', :re => /^(\w{11})$/, :n  => '1+')
  # When calling dirs(), dir(), files(), and file(), the user supplies:
  #   a validation identifier (will be used when reporting problems)
  #   optional name-related specs
  #   optional quantity-related specs
  #
  # dirs() returns an enumerable object of Catalog Items, such that:
  #   Item.type is directory.
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

  fs = dir.file('preCM', :name => 'preContentMetadata.xml')
  # file() returns
  #   - Same as above, but there will never be more than 1 Item.
  #   - Caller must handle 0 Items, if it matters to subsequent code.
  #
  # Note that we are calling file() on a Catalog Item.
  #   - Translates into a file() call on main DirValidator.
  #   - But regex is framed relative to cwd of Item, not DirValidator.

  f = fs.first
  ap dir.path
  ap f.path
  return

  druid = dir.basename
  # Items provide various convenience methods to obtain file name components.

  img = dir.dir(:name => 'Images')
  pm  = dir.dir(:name => 'PM')
  sl  = dir.dir(:name => 'SL')
  sh  = dir.dir(:name => 'SH')
  # dir() returns a Catalog item ... (same as above)

  fs = img.files(:re => /^(#{druid}_\d+_)img(\d+).jpg$/)
  # dir() returns a Catalog item ... (same as above)

  druid_n = fs.first.match_data[1]
  # Provide a mechanism allowing caller to retrieve MatchData from a Catalog Item.

  fs.each { |f| img.file(:name => f.basename + '.md5') }

  fs = pm.files(:re =~ /^(#{druid_n}_\w+)_pm.wav$/)
  # Again calling files() on a Catalog Item.
  
  fs.each do |f|
    prefix = f.match_data[1]

    pm.file(:name => prefix + '.md5')
    sl.file(:name => prefix + '_sl.wav')
    sl.file(:name => prefix + '_sl.wav.md5')
    sl.file(:name => prefix + '_sl.techmd.xml')
    sh.file(:name => prefix + '_sh.wav')
    sh.file(:name => prefix + '_sh.wav.md5')
    # Again calling file() on a Catalog Item.

  end

end

main()


__END__

def foo(a, b, &c)
  puts [a,b].inspect
  c.call
end

def bar(a, b)
  puts [a,b].inspect
  yield
end

x = lambda { puts "BLOCK" }
foo(11, 22, &x)
bar(11, 22, &x)

foo(11, 22) {
  puts "block"
}

bar(11, 22) {
  puts "block"
}


__END__

class DirValidator


  def initialize
    @catalog = [11,22,33,44,55]
  end

  def dirs
    return @catalog.select { |c| c.odd? }
  end

end


def druid_dir_validator(*args)
  puts args.inspect
end

def main
  dv = DirValidator.new
  dv.dirs.each { |c| druid_dir_validator(dv, c) }
end

main
