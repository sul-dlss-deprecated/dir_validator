require 'spec_helper'

describe("Tutorial demo", :integration => true) do

  it "can run the tutorial without errors" do
    output = `ruby -Ilib tutorial/tutorial.rb`
    output.should =~ /\A#{DirValidator::Validator.report_columns[0]}/
  end

end
