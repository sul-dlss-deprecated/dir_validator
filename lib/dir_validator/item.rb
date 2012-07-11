require 'pathname'

class DirValidator::Item

  attr_accessor(:matched, :target)
  attr_reader(:pathname, :path, :catalog_id, :match_data, :filetype)

  def initialize(validator, path, catalog_id = nil)
    @validator  = validator
    @pathname   = Pathname.new(path).cleanpath
    @path       = @pathname.to_s
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
    return @validator.dirs(vid, item_opts(opts, :n => '1'))
  end

  def file(vid, opts = {})
    return @validator.files(vid, item_opts(opts, :n => '1'))
  end

  def item_opts(opts, other_opts = {})
    # Takes one or two hashes of validation opts.
    # Returns a new, merged hash of opts with the appropriate value
    # for :base_dir. That value depends on whether the current Item
    # is a dir or file, and whether the file has a parent dir.
    opts = opts.merge(other_opts)
    if is_dir
      opts = opts.merge(:base_dir => @path)
    else
      dn   = @pathname.dirname.to_s
      opts = opts.merge(:base_dir => dn) unless dn == '.'
    end
    return opts
  end

end
