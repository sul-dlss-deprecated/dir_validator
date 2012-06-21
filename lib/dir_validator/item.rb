require 'pathname'

class DirValidator::Item

  attr_accessor(:matched, :target)
  attr_reader(:path, :basename, :match_data, :filetype)

  def initialize(validator, path)
    @validator  = validator
    @pathname   = Pathname.new(path).cleanpath
    @path       = @pathname.to_s
    @basename   = @pathname.basename.to_s
    @matched    = false
    @target     = nil
    @match_data = nil
    @filetype   = @pathname.file?      ? :file :
                  @pathname.directory? ? :dir  : nil
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
    opts = opts.merge({:base_dir => path})
    return @validator.dirs(vid, opts)
  end

  def files(vid, opts = {})
    opts = opts.merge({:base_dir => path})
    return @validator.files(vid, opts)
  end

  def dir(vid, opts = {})
    opts = opts.merge({:n => '1', :base_dir => path})
    return @validator.dirs(vid, opts)
  end

  def file(vid, opts = {})
    opts = opts.merge({:n => '1', :base_dir => path})
    return @validator.files(vid, opts)
  end

end
