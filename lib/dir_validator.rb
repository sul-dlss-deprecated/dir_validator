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
  #       # Alternatively, the user can supply those arguments on
  #       # the command line; in that case, this method is unneeded.
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
    # Usage message, and a copy of the args (typically from ARGV).
    usage = lambda { abort "Usage: #{$PROGRAM_NAME} SCRIPT [DIRECTORY]" }
    args = args.dup
    # Require the script, and add its functions to the module.
    script = args.shift
    usage.call unless File.file?(script.to_s)
    require File.expand_path(script)
    module_function(:initialize_validator, :run_validator)
    # Get the initialization parameters for the validator.
    # If the user did not implement the initialize_validator() method,
    # we will get the params from from args (the command line).
    init_params = initialize_validator()
    init_params = [init_params] unless init_params.class == Array
    init_params = args unless init_params.first
    usage.call unless File.directory?(init_params.first.to_s)
    # Create validator and run the validation code supplied by user.
    dv = DirValidator.new(*init_params)
    run_validator(dv)
    dv.validate()
    # Return the validator.
    return dv
  end

  # Users depending on run_script() can implement this method if they
  # prefer to pass arguments to the initializer in Ruby code
  # rather than on the command line.
  #
  # @!visibility private
  def initialize_validator
    return []
  end

end

require 'dir_validator/catalog'
require 'dir_validator/item'
require 'dir_validator/quantity'
require 'dir_validator/validator'
require 'dir_validator/warning'
