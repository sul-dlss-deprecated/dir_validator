require 'spec_helper'

describe("Integration tests: DirValidator::Catalog", :integration => true) do

  it "load_items() returns correct N of items and creates the @unmatched hash" do
    exp  = { :total => 60, :dirs => 12, :files => 48 }
    fdir = fixture_item(:basic)
    dv   = DirValidator.new(fdir)
    cat  = DirValidator::Catalog.new(dv)
    ivget(cat, :unmatched).should == {}
    cat.load_items
    cat.items.size.should == exp[:total]
    cat.items.select { |i| i.is_dir }.size.should  == exp[:dirs]
    cat.items.select { |i| i.is_file }.size.should == exp[:files]
    ivget(cat, :unmatched).keys.size.should == exp[:total]
  end

end
