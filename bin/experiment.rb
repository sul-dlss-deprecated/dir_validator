#! /usr/bin/env ruby

def main

  dv = DirValidator.new('some/path')
  # create root_parent Validator
  # load the Catalog

  ds = dv.dirs(:re => /^(\w{11})$/, :n  => '1+')
  # dirs() returns an enumerable object of Catalog Items, such that:
  #   Item.type is directory.
  #   Item.already_matched is false.
  #   regex tests pass.
  #
  # In addition:
  #   Item.already_matched will now be set true.
  #   A warning is logged if the N of matching Items < N wanted.
  #   The method never returns more than N wanted, and excess Items will remain unmatched.

  ds.each { |dir| druid_dir_validator(dv, dir) }
  # Caller is responsible for passing the DirValidator into their own methods.

end

def druid_dir_validator(dv, dir)

  dv.file(:name => 'preContentMetadata.xml')
  # file() returns a Catalog item, such that:
  #   same as above.
  #
  # In addition:
  #   same as above (in this case, N wanted = 1).

  druid = dir.basename
  # Items provide various convenience methods to obtain file name components.

  img = dv.dir(:name => 'Images')
  pm  = dv.dir(:name => 'PM')
  sl  = dv.dir(:name => 'SL')
  sh  = dv.dir(:name => 'SH')
  # dir() returns a Catalog item ... (same as above)

  fs = img.files(:re => /^(#{druid}_\d+_)img(\d+).jpg$/)
  # dir() returns a Catalog item ... (same as above)

  druid_n = fs.first.match_data[1]
  # Provide a mechanism allowing caller to retrieve MatchData from a Catalog Item.

  fs.each { |f| img.file(:name => f.basename + '.md5') }
  # Here we call file() on a Catalog Item.
  #   - This translates into a file() call on the main DirValidator.
  #   - But with same cwd adjustments: the regexes are framed relative to
  #     the cwd of the Item rather than of the main DirValidator.

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
