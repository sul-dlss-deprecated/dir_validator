#! /usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'boot'))

# Suppose that we want to check the following directory structure.
#
#   spec/fixtures/tutorial/
#       aaa/                 # Top-level sub-directories should be 3 lower-case leters.
#           00/              # Should be three second-level directories: 00, 01, and 02.
#               a.tif        # One or more .tif files in the 00 directory.
#               b.tif
#           01/
#               a.jpg        # A parallel set of .jpg files.
#               b.jpg
#           02/
#               a.jp2        # A parallel set of .jp2 files.
#               b.jp2
#               blort.txt    # What?!?
#       aab/
#           00/
#               a.tif
#               b.tif
#           01/
#               a.jpg
#               b.jpg
#           02/
#               a.jp2        # Missing file.
#       baa/
#           00/
#               a.tif
#               b.tif
#           01/
#               a.jpg
#               b.jpg
#           02/
#               a.jp2        # Missing file.

# Set up the validator, passing in the starting path.
dv = DirValidator.new('spec/fixtures/tutorial')

# Here we set up our expectation for the top-level sub-directories. In this
# case, we are looking for 1 or more sub-directories named with exactly 3
# lower-case letters, as defined in the regular expression.
dv.dirs('top-level subdir', :re => /^[a-z]{3}$/).each do |subdir|

  # Within each of those top-level directories, we expect to find three
  # numbered directories. In this case, we pass in literal names to
  # the validation methods rather than a regular expression.
  # Notice also that the validation method is being called on the
  # subdirectory (subdir), not the overall dir-validator (dv).
  d0 = subdir.dir('00', :name => '00')
  d1 = subdir.dir('01', :name => '01')
  d2 = subdir.dir('02', :name => '02')

  # In the 00 subdirectory, we expect to see a bunch of .tif files.
  # We could have used a regular expression, but in this case we'll
  # resort to a simple glob-like pattern.
  d0.files('tifs', :pattern => '*.tif').each do |tif|

    # And finally, we set up the validations for the parallel .jpg
    # and .jp2 files. Those files should reside in the 01 and 02
    # subdirectories (which we stored in d1 and d2 above). Their
    # file names should mirror that of the current .tif file.
    tif_base = tif.basename('.tif')
    d1.file('jpgs', :name => tif_base + '.jpg')
    d2.file('jp2s', :name => tif_base + '.jp2')

  end
end

# We can generate a basic CSV report that will list:
#   - items that we not found
#   - extra items
#
# The CSV output (with extra spacing here for readability):
#   vid,      got,  n,   base_dir,  name,   re,  pattern,  path
#   jp2s,     0,    1,   aab/02,    b.jp2,  "",  "",       ""
#   jp2s,     0,    1,   baa/02,    b.jp2,  "",  "",       ""
#   _EXTRA_,  "",   "",  "",        "",     "",  "",       aaa/02/blort.txt
dv.report()

# Alternatively, we could examine the results programmatically by
# iterating over the dir-validator's warnings.
dv.validate()
dv.warnings.each do |w|
  # ...
end
