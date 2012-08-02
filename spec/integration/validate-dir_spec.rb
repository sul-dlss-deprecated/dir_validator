require 'spec_helper'

describe("validate-dir", :integration => true) do

  it "can run validate-dir without errors" do
    output = `ruby -Ilib bin/validate-dir spec/fixtures/hummel_validate.rb`
    output.should =~ /\A#{DirValidator::Validator.report_columns[0]}/
  end

end
