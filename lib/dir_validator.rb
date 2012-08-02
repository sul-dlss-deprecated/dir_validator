module DirValidator

  # Syntactic sugar: a module method for creating a new validator.
  #
  # @param (see DirValidator::Validator#new)
  # @return [DirValidator::Validator]
  def self.new(*args, &block)
    return DirValidator::Validator.new(*args, &block)
  end

  # Takes the file name of a Ruby script as a command-line argument.
  # The script should define the following methods:
  #
  #   module DirValidator
  #     def initialize_validator
  #       # Should return the arguments to DirValidator.new().
  #     end
  #
  #     def run_validator(dv)
  #       # Receives the DirValidator::Validator object.
  #       # Should execute the desired validation code.
  #     end
  #   end
  #
  # Requires the script, runs its code, and returns the validator.
  #
  # Used by the validate-dir executable. Also useful for applications
  # wanting to offer the functionality of the dir_validator gem and
  # to receive the validation code as an input.
  def self.run_script(args)
    # Require the script, and add its functions to the module.
    script = args.first
    abort "Usage: #{$PROGRAM_NAME} SCRIPT" unless File.file?(script.to_s)
    require script
    module_function(:initialize_validator, :run_validator)
    # Create validator, run the validation code supplied by user.
    dv = DirValidator.new(initialize_validator)
    run_validator(dv)
    dv.validate()
    # Return the validator.
    return dv
  end

end

require 'dir_validator/catalog'
require 'dir_validator/item'
require 'dir_validator/quantity'
require 'dir_validator/validator'
require 'dir_validator/warning'
