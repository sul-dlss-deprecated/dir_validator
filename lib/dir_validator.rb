module DirValidator

  # Syntactic sugar: a module method for creating a new validator.
  #
  # @param (see DirValidator::Validator#new)
  # @return [DirValidator::Validator]
  def self.new(*args, &block)
    return DirValidator::Validator.new(*args, &block)
  end

end

require 'dir_validator/catalog'
require 'dir_validator/item'
require 'dir_validator/quantity'
require 'dir_validator/validator'
require 'dir_validator/warning'
