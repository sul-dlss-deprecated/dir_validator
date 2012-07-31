require 'pathname'

# @!attribute [r] path
#   @return [String]
#   The path to the Item, omitting the root_dir of the {DirValidator::Validator}.
#
# @!attribute [r] dirname
#   @return [String]
#   The path to the parent directory of the Item, or '.' if the parent
#   directory is the root_dir of the {DirValidator::Validator}.
#
# @!attribute [r] match_data
#   @return [MatchData]
#   The MatchData from the most recent regular expression test against the Item.
class DirValidator::Item

  attr_reader(:path, :dirname, :match_data)
  attr_reader(:pathname, :dirname2, :catalog_id, :matched, :target, :filetype) # @!visibility private

  # Returns a new Item, based on these arguments:
  #   - Validator.
  #   - String: path to a file or directory (omitting Validator.root_dir).
  #   - Integer: the Catalog ID assigned by the Catalog class.
  #
  # @!visibility private
  def initialize(validator, path, catalog_id)
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

  # Just a front-end for Ruby's File#basename.
  #
  # @param args          See File#basename.
  # @return     [String] The basename of the Item.
  def basename(*args)
    return @pathname.basename(*args).to_s
  end

  # @!visibility private
  def is_dir
    return @filetype == :dir
  end

  # @!visibility private
  def is_file
    return @filetype == :file
  end

  # @!visibility private
  def mark_as_matched
    @matched = true
  end

  # @!visibility private
  def set_target(t)
    @target = t
  end

  # Takes a Regexp. Trys to match Item.target against the Regexp.
  # Stores the resulting MatchData.
  #
  # @!visibility private
  def target_match(regex)
    @match_data = regex.match(@target)
    return @match_data
  end

  # Validation method, using a {DirValidator::Item} as the receiver.
  #
  # @see DirValidator::Validator#dir
  # @return  (see DirValidator::Validator#dir)
  def dir(vid, opts = {})
    return @validator.dir(vid, item_opts(opts))
  end

  # @see #dir
  # @return  (see DirValidator::Validator#file)
  def file(vid, opts = {})
    return @validator.file(vid, item_opts(opts))
  end

  # @see #dir
  # @return  (see DirValidator::Validator#dirs)
  def dirs(vid, opts = {})
    return @validator.dirs(vid, item_opts(opts))
  end

  # @see #dir
  # @return  (see DirValidator::Validator#files)
  def files(vid, opts = {})
    return @validator.files(vid, item_opts(opts))
  end

  # Takes a validation-method opts hash.
  # Returns a new hash of opts with the appropriate value
  # for :base_dir. That value depends on whether the current Item
  # is a dir or file, and whether the file has a parent dir.
  #
  # @!visibility private
  def item_opts(opts)
    if is_dir
      return opts.merge(:base_dir => @path)
    elsif @dirname == '.'
      return opts
    else
      return opts.merge(:base_dir => @dirname)
    end
  end

end
