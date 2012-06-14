module DirValidator

  def self.new(*args, &block)
    return DirValidator::Validator.new(*args, &block)
  end

end

require 'dir_validator/version'
require 'dir_validator/validator'
