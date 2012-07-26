require 'pathname'

class DirValidator::Item

  attr_reader(
    :pathname,
    :path,
    :dirname,
    :dirname2,
    :catalog_id,
    :matched,
    :target,
    :match_data,
    :filetype)

  def initialize(validator, path, catalog_id = nil)
    @validator  = validator
    @pathname   = Pathname.new(path).cleanpath
    @path       = @pathname.to_s
    @dirname    = @pathname.dirname.to_s
    @dirname2   = @dirname == '.' ? '' : @dirname
    @catalog_id = catalog_id
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

  def mark_as_matched
    @matched = true
  end

  def set_target(t)
    @target = t
  end

  def target_match(regex)
    @match_data = regex.match(@target)
    return @match_data
  end

  def dirs(vid, opts = {})
    return @validator.dirs(vid, item_opts(opts))
  end

  def files(vid, opts = {})
    return @validator.files(vid, item_opts(opts))
  end

  def dir(vid, opts = {})
    return @validator.dir(vid, item_opts(opts))
  end

  def file(vid, opts = {})
    return @validator.file(vid, item_opts(opts))
  end

  def item_opts(opts)
    # Takes a hash of validation opts.
    # Returns a new hash of opts with the appropriate value
    # for :base_dir. That value depends on whether the current Item
    # is a dir or file, and whether the file has a parent dir.
    if is_dir
      return opts.merge(:base_dir => @path)
    elsif @dirname == '.'
      return opts
    else
      return opts.merge(:base_dir => @dirname)
    end
  end

end
