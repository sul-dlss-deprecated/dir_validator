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

end
