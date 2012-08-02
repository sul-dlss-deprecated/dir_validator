require 'spec_helper'

describe("Tutorial demo", :integration => true) do

  it "can run the tutorial without errors" do
    # Read tutorial script.
    tutorial = IO.readlines('tutorial/tutorial.rb')
    # In the testing context, we need an additional command in the tutorial script.
    lp  = "$LOAD_PATH.unshift(File.expand_path(File.join('..', '..', 'lib'), __FILE__))"
    rgx = /\Arequire 'dir_validator'/
    # Write content to a temp file.
    tf = Tempfile.new('tutorial_', 'tmp')
    tutorial.each do |line|
      tf.puts lp if line =~ rgx
      tf.puts line
    end
    tf.puts tutorial
    tf.close
    # Run temp-file version of the tutorial script.
    output = `ruby #{tf.path}`
    output.should =~ /#{DirValidator::Validator.report_columns[0]}/
  end

end
