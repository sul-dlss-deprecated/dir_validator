require 'pathname'

class DirValidator::Item

  attr_accessor(:matched, :target)
  attr_reader(:pathname, :path, :match_data, :filetype)

  def initialize(validator, path)
    @validator  = validator
    @pathname   = Pathname.new(path).cleanpath
    @path       = @pathname.to_s
    @matched    = false
    @target     = nil
    @match_data = nil
    @filetype   = @pathname.file?      ? :file :
                  @pathname.directory? ? :dir  : nil
  end

  def basename(*args)
    return @pathname.basename(*args).to_s
  end

  def is_dir
    return @filetype == :dir
  end

  def is_file
    return @filetype == :file
  end

  def target_match(regex)
    @match_data = regex.match(@target)
    return @match_data
  end

  def dirs(vid, opts = {})
    opts = opts.merge(base_dir_opts)
    return @validator.dirs(vid, opts)
  end

  def files(vid, opts = {})
    opts = opts.merge(base_dir_opts)
    return @validator.files(vid, opts)
  end

  def dir(vid, opts = {})
    opts = opts.merge({:n => '1'}).merge(base_dir_opts)
    return @validator.dirs(vid, opts)
  end

  def file(vid, opts = {})
    opts = opts.merge({:n => '1'}).merge(base_dir_opts)
    return @validator.files(vid, opts)
  end

  def base_dir_opts
    if is_dir
      return {:base_dir => @path}
    else
      dn = @pathname.dirname.to_s
      return dn == '.' ? {} : {:base_dir => dn}
    end
  end

end
