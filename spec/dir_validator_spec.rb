describe DirValidator do

  it "can call new() on the module" do
    DirValidator.new('.').should be_kind_of DirValidator::Validator
  end

end
