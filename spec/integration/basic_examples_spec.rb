require 'spec_helper'

describe("Integration tests: basic project examples", :integration => true) do

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

end
