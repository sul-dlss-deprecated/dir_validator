require 'spec_helper'

describe("validate-dir", :integration => true) do

  before(:each) do
    @dir      = "spec/fixtures/hummel"
    @ruby_cmd = "ruby -Ilib bin/validate-dir"
    @exp_rgx  = /\A#{DirValidator::Validator.report_columns[0]}/
  end

  it "can run without errors: supply initialize parameters command line" do
    output = `#{@ruby_cmd} #{@dir}_validate_via_cmd.rb #{@dir}`
    output.should =~ @exp_rgx
  end

  it "can run without errors: supply initialize parameters in code" do
    output = `#{@ruby_cmd} #{@dir}_validate_via_code.rb`
    output.should =~ @exp_rgx
  end

end
