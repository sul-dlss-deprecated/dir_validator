require 'spec_helper'

describe("Tutorial demo", :integration => true) do

  it "can run the tutorial without errors" do
    # Read tutorial script.
    tutorial = IO.readlines('tutorial/tutorial.rb')
    # Swap one of the require lines.
    rq  = "File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'boot'))"
    rgx = /\Arequire 'dir_validator'/
    tutorial.each { |line| break if line.gsub!(rgx, "require #{rq}") }
    # Write content to a temp file.
    tf = Tempfile.new('tutorial_', 'tmp')
    tf.puts tutorial
    tf.close
    # Run temp-file version of the tutorial script.
    output = `ruby #{tf.path}`
    output.should =~ /#{DirValidator::Validator.report_columns[0]}/
  end

end
