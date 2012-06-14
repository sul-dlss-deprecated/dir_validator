describe DirValidator::Validator do

  before(:each) do
    @dv = DirValidator::Validator.new('')
  end

  ####################

  describe "initialization and other setup" do

    it "can initialize a validator" do
      @dv.should be_kind_of DirValidator::Validator
    end

  end

  ####################

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

end
