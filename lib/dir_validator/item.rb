class DirValidator::Item

  attr_accessor(
    :type,
    :path,
    :matched
  )

  def initialize(validator, path)
    @validator = validator
    @path      = path
    @type      = File.file?(path) ? :file : :dir
    @matched   = false
  end

  def is_file
    @type == :file
  end

  def is_dir
    @type == :dir
  end

end
