require 'spec_helper'

describe("Integration tests: DirValidator::Catalog", :integration => true) do

  it "load_items() returns correct N of items from a directory" do
    fdir = fixture_item(:basic)
    dv   = DirValidator.new(fdir)
    cat  = DirValidator::Catalog.new(dv)
    cat.load_items.size.should == 60
    cat.items.select { |i| i.is_dir }.size.should  == 12
    cat.items.select { |i| i.is_file }.size.should == 48
  end

end
