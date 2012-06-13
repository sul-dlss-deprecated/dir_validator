#! /usr/bin/env ruby

# SOHP demo.
def main
  dv = DirValidator.new('some/path')
  dv.file(:name => 'preContentMetadata.xml')
  dv.dirs.each(&druid_dir_validator)
end

def druid_dir_validator(dv)
  druid_re = /^(\w{11})$/
  dv.name =~ druid_re
  druid = dv.name

  img = dv.dir(:name => 'Images')
  pm  = dv.dir(:name => 'PM')
  sl  = dv.dir(:name => 'SL')
  sh  = dv.dir(:name => 'SH')

  fs = img.files(:re => /^(#{druid}_\d+_)img(\d+).jpg$/)
  fs.each do |f|
    img.file(:name => f.basename + '.md5')
  end
  druid_n = fs.first.match_data[1]

  pm.files(:re =~ /^(#{druid_n}_\w+)_pm.wav$/).each do |f|
    prefix = f.match_data[1]
    pm.file(:name => prefix + '.md5')
    sl.file(:name => prefix + '_sl.wav')
    sl.file(:name => prefix + '_sl.wav.md5')
    sl.file(:name => prefix + '_sl.techmd.xml')
    sh.file(:name => prefix + '_sh.wav')
    sh.file(:name => prefix + '_sh.wav.md5')
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
