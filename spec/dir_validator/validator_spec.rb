describe DirValidator::Validator do

  before(:each) do
    @fdir = fixture_item(:simple)
    @dv   = DirValidator::Validator.new(@fdir)
  end

  describe "initialization and other setup" do

    it "can initialize a validator" do
      @dv.should be_kind_of DirValidator::Validator
    end

  end

  describe "file()" do

    it "can add file() expectations" do
      names = %w(foo bar quux)
      names.each_with_index do |nm, i|
        @dv.validators.size == i
        @dv.file(:name => nm)
        @dv.validators.size == i + 1
        @dv.validators.last.exp_name.should == nm
      end
    end

  end

  describe "is_top_parent?()" do

    it "returns true if the validator is the top parent" do
      @dv.is_top_parent?.should == true
    end

    it "returns false for all other validators" do
      %w(foo bar).each { |n| @dv.file(:name => n) }
      @dv.validators.each do |v|
        v.is_top_parent?.should == false
      end
    end

  end

  describe "catalog()" do

    it "......" do
      @dv.catalog.keys.sort.should == %w(. .. bar.xml foo.txt)
    end

  end

end
