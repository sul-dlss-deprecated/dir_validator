require 'spec_helper'

describe("Tutorial demo", :integration => true) do

  it "can run the tutorial without errors" do
    output = `bin/tutorial.rb`
    output.should =~ /#{DirValidator::Validator.report_columns[0]}/
  end

end
