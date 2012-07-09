require 'spec_helper'

describe("Integration tests: various project examples", :integration => true) do

  before(:all) do
    @druid_re = /[a-z]{2} \d{3} [a-z]{2} \d{4}/x
    @extra = DirValidator::Validator::EXTRA_VID
  end

  it "Revs" do
    dv = DirValidator.new(fixture_item(:revs))
    dv.dirs('druid_dirs', :re => @druid_re).each do |dir|
      dir.files('tifs', :pattern => '*.tif')
      dir.files('checksums', :name => 'checksums.txt')
      dir.files('checksums', :name => 'manifest.csv')
    end
    dv.validate
    dv.warnings.map { |w| [w.vid, w.opts] }.should == [
      ['checksums', {:base_dir=>"bb000bb0001", :name=>"manifest.csv", :got=>0} ],
      [@extra,      {:path=>"blah.txt"} ],
    ]
  end

  it "Paired files" do
    dv = DirValidator.new(fixture_item(:paired_files))
    dv.files('word_files', :pattern => '*.doc').each do |f|
      nm = f.basename('.doc') + '.xls'
      f.file('excel_files', :name => nm)
    end
    dv.validate
    dv.warnings.map { |w| [w.vid, w.opts] }.should == [
      ['excel_files', {:got=>0, :n=>"1", :name=>"c.xls"} ],
      [@extra,        {:path=>"foo.bar"} ],
    ]
  end

  it "Hummel" do
    dv = DirValidator.new(fixture_item(:hummel))
    dv.dirs('druid_dirs', :re => @druid_re).each do |dir|
      d0 = dir.dir('00', :name => '00').first
      d1 = dir.dir('01', :name => '01').first
      d2 = dir.dir('02', :name => '02').first
      d0.files('tifs', :pattern => '*.tif').each do |tif|
        tif_base = tif.basename('.tif')
        d1.file('jpg', :name => tif_base + '.jpg')
        d2.file('jp2', :name => tif_base + '.jp2')
      end
    end
    dv.validate
    dv.warnings.map { |w| [w.vid, w.opts] }.should == [
      ['jp2',  {:got=>0, :base_dir=>"bb000bb0001/02", :n=>"1", :name=>"b.jp2"} ],
      [@extra, {:path=>"aa000aa0001/00/blort.txt"} ],
    ]
  end

  it "Simple outline structure" do
    dv = DirValidator.new(fixture_item(:outline))
    dv.dirs('A..Z', :re => /\A[A-Z]\z/).each do |dir|
      dir.dirs('a..z', :re => /\A[a-z]\z/).each do |sdir|
        sdir.file('file', :name => 'data')
      end
    end
    dv.validate
    dv.warnings.map { |w| [w.vid, w.opts] }.should == [
      ["file", {:base_dir=>"A/x", :got=>0, :n=>"1", :name=>"data"}],
      ["a..z", {:re=>/\A[a-z]\z/, :base_dir=>"Y", :got=>0}],
      ["_EXTRA_", {:path=>"blort.txt"}],
      ["_EXTRA_", {:path=>"D/blah.txt"}],
      ["_EXTRA_", {:path=>"D/d/xxx.doc"}],
    ]
  end

  it "Quantity variants" do
    dv = DirValidator.new(fixture_item(:quantities))
    dv.dirs('blahs', :re => /\Ablah/, :n => '+').each do |dir|
      dir.dirs('blah-subdirs',         :pattern => 'd?',     :n => '*')
      dir.dirs('blah-optional-subdir', :name    => 'xxx',    :n => '?')
      dir.files('blah-files',          :re      => '\A[ab]', :n => '1+')
      dir.files('blah-optional-file',  :name    => 'yyy',    :n => '0-1')
    end
    dv.file('xxx', :name => 'xxx')
    dv.dir('yyy',  :name => 'yyy')
    dv.files('foo-files', :pattern => 'foo.*', :n => '1-4')
    dv.files('bar-files', :pattern => 'bar.*', :n => '2-5')
    dv.validate
    dv.warnings.map { |w| [w.vid, w.opts] }.should == [
      ["bar-files", {:pattern=>"bar.*", :got=>1, :n=>"2-5"}],
    ]
  end

end
