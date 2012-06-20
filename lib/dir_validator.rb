module DirValidator

  def self.new(*args, &block)
    return DirValidator::Validator.new(*args, &block)
  end

end

require 'dir_validator/catalog'
require 'dir_validator/item'
require 'dir_validator/quantity'
require 'dir_validator/validator'
