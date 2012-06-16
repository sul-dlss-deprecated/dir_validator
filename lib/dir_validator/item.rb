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

  def file(vid, opts = {})
    return @validator.files( vid, opts.merge({:n => '1', :base_dir => @path}) )
  end

end
