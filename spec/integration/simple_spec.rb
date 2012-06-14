#! /usr/bin/env ruby

describe "integration" do

  before(:all) do
    @fdir = fixture_item(:simple)
  end

  it "simple case: some missing files" do
    bad_files    = %w(xxx.doc yyy.xls)
    good_files   = dir_contents(@fdir)
    exp_warnings = bad_files.map { |b| "Not found: #{fixture_item(@fdir, b)}" }

    dv = DirValidator.new(@fdir)
    (bad_files + good_files).each { |f| dv.file(:name => f) }

    dv.validate
    dv.all_warnings.should == exp_warnings
  end

end
