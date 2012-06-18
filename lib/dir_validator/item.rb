require 'pathname'

class DirValidator::Item

  attr_accessor(
    :pathname,
    :matched,
    :type,
    :match_data)

  def initialize(validator, path)
    @validator = validator
    @pathname  = Pathname.new(path).cleanpath
    @matched   = false
    setup()
  end

  def setup
    @type = @pathname.file?      ? :file : 
            @pathname.directory? ? :dir  : nil
  end

  def path
    return @pathname.to_s
  end

  def is_file
    @type == :file
  end

  def is_dir
    @type == :dir
  end

  def basename
    @pathname.basename.to_s
  end

  def match(regex, base_dir = nil)
    p = base_dir ? @pathname.relative_path_from(Pathname.new(base_dir)) : @pathname
    @match_data = regex.match(p.to_s)
    return @match_data
  end

  def files(vid, opts = {})
    opts = opts.merge({:base_dir => path})
    return @validator.files(vid, opts)
  end

  def dirs(vid, opts = {})
    opts = opts.merge({:base_dir => path})
    return @validator.dirs(vid, opts)
  end

  def file(vid, opts = {})
    opts = opts.merge({:n => '1', :base_dir => path})
    return @validator.files(vid, opts)
  end

  def dir(vid, opts = {})
    opts = opts.merge({:n => '1', :base_dir => path})
    return @validator.dirs(vid, opts)
  end

end
