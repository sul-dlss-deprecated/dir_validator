# @!attribute [r] root_path
#   @return [String]
#   The root path of the validator.
# @!attribute [r] warnings
#   @return [Array]
#   The validator's {DirValidator::Warning} objects.
class DirValidator::Validator

  attr_reader(:root_path, :warnings)
  attr_reader(:catalog, :validated)  # @!visibility private

  FILE_SEP  = File::SEPARATOR        # @!visibility private
  EXTRA_VID = '_EXTRA_'              # @!visibility private

  # @param  root_path [String] Path to the directory structure to be validated.
  def initialize(root_path)
    @root_path = root_path
    @catalog   = DirValidator::Catalog.new(self)
    @warnings  = []
    @validated = false
  end

  # Validation method. See {file:README.rdoc} for details.
  #
  # @param vid   [String]  Validation identifier meaningful to the user.
  # @param opts  [Hash]    Validation options.
  #
  # @option opts :name    [String]             Item name must match a literal string.
  # @option opts :re      [String|Regexp]      Item name must match regular expression.
  # @option opts :pattern [String]             Item name must match a glob-like pattern.
  # @option opts :n       [String]             Expected number of items. Plural validation
  #                                            methods default to '1+'. Singular variants
  #                                            force the option to be '1'.
  # @option opts :recurse [false|true] (false) Whether to return items other than immediate
  #                                            children.
  #
  # @return   [DirValidator::Item]  Or nil if no matching items are found.
  def dir(vid, opts = {})
    opts = opts.merge({:n => '1'})
    return dirs(vid, opts).first
  end

  # @see #dir
  # @return   (see #dir)
  def file(vid, opts = {})
    opts = opts.merge({:n => '1'})
    return files(vid, opts).first
  end

  # @see #dir
  # @return   [Array]
  def dirs(vid, opts = {})
    bd = normalized_base_dir(opts, :handle_recurse => true)
    return process_items(@catalog.unmatched_dirs(bd), vid, opts)
  end

  # @see #dir
  # @return   [Array]
  def files(vid, opts = {})
    bd = normalized_base_dir(opts, :handle_recurse => true)
    return process_items(@catalog.unmatched_files(bd), vid, opts)
  end

  # The workhorse for the the validation methods.
  #
  # @!visibility private
  def process_items(items, vid, opts = {})
    # Make sure the user did not forget to pass the validation identifier.
    if vid.class == Hash
      msg = "Validation identifier should not be a hash: #{vid.inspect}"
      raise ArgumentError, msg
    end

    # Get a Quantifier object.
    quant = DirValidator::Quantity.new(opts[:n] || '1+')

    # We are given a list of unmatched Items (either files or dirs).
    # Here we filter the list to those matching the name-related criteria.
    items = name_filtered(items, opts)

    # And here we cap the N of items to be returned. For example, if the
    # user asked for 1-3 Items and we found 5, we will return only 3.
    items = quantity_limited(items, quant)

    # Add a warning if the N of Items is less than the user's expectation.
    sz = items.size
    unless sz >= quant.min_n
      add_warning(vid, opts.merge(:got => sz))
    end

    # Mark the Items as matched so subsequent validations won't return same Items.
    @catalog.mark_as_matched(items)

    return items
  end


  ####
  # Name-related filtering.
  ####

  # Takes an array of items and a validation-method opts hash.
  # Returns the subset of those items matching the name-related 
  # criteria in the opts hash.
  #
  # @!visibility private
  def name_filtered(items, opts)
    # Filter the items to those in the base_dir.
    # If there is no base_dir, no filtering occurs.
    base_dir = normalized_base_dir(opts, :add_file_sep => true)
    sz       = base_dir.size
    items    = items.select { |i| i.path.start_with?(base_dir) } if sz > 0

    # Set the item.target values, which are the values that will
    # be subjected to the name-related test. If there is no base_dir,
    # the target is the same as item.path.
    items.each { |i| i.set_target(i.path[sz .. -1]) }

    # Filter items to immediate children, unless user wants to recurse.
    items = items.reject { |i| i.target.include?(FILE_SEP) } unless opts[:recurse]

    # Return the items having targets matching the name regex.
    rgx = name_regex(opts)
    return items.select { |i| i.target_match(rgx) }
  end

  # Takes a validation-method opts hash.
  # Returns opts[:base_dir] in a normalized form (with trailing separator).
  # Returns nil or '' under certain conditions.
  #
  # @!visibility private
  def normalized_base_dir(opts, nbd_opts = {})
    return nil if opts[:recurse] and nbd_opts[:handle_recurse]
    bd = opts[:base_dir]
    return '' unless bd
    bd.chop! while bd.end_with?(FILE_SEP)
    bd += FILE_SEP if nbd_opts[:add_file_sep]
    return bd
  end

  # Takes a validation-method opts hash.
  # Returns the appropriate Regexp based on the name-related criteria.
  #
  # @!visibility private
  def name_regex(opts)
    name    = opts[:name]
    re      = opts[:re]
    pattern = opts[:pattern]
    return Regexp.new(
      name    ? name_to_re(name)       :
      pattern ? pattern_to_re(pattern) :
      re      ? re                     : ''
    )
  end

  # Takes a validation-method opts[:name] value.
  # Returns the corresponding regex-ready string:
  #   - wrapped in start- and end- anchors
  #   - all special characters quoted
  #
  # @!visibility private
  def name_to_re(name)
    return az_wrap(Regexp.quote(name))
  end

  # Takes a validation-method opts[:pattern] value.
  # Returns the corresponding regex-ready string
  #   - wrapped in start- and end- anchors
  #   - all special regex chacters quoted except for:
  #     * becomes .*
  #     ? becomes .
  #
  # @!visibility private
  def pattern_to_re(pattern)
    return az_wrap(Regexp.quote(pattern).gsub(/\\\*/, '.*').gsub(/\\\?/, '.'))
  end

  # Takes a string.
  # Returns a new string wrapped in Regexp start-of-string and end-of-string anchors.
  #
  # @!visibility private
  def az_wrap(s)
    return "\\A#{s}\\z"
  end


  ####
  # Quantity filtering.
  ####

  # Takes an array of items and a DirValidator::Quantity object.
  # Returns the subset of those items falling within the max allowed
  # by the Quantity.
  #
  # @!visibility private
  def quantity_limited(items, quant)
    return items[0 .. quant.max_index]
  end


  ####
  # Methods related validation warnings and reporting.
  ####

  # Takes a validation identifier and a validation-method opts hash.
  # Creates and new DirValidator::Warning and adds it to the validator's
  # array of warnings.
  #
  # @!visibility private
  def add_warning(vid, opts)
    @warnings << DirValidator::Warning.new(vid, opts)
  end

  # Adds a warning to the validator for all unmatched items in the catalog.
  # Should be run after all validation-methods have been called, typically
  # before producing a report.
  #
  # @!visibility private
  def validate
    return if @validated  # Run only once.
    @catalog.unmatched_items.each do |item|
      add_warning(EXTRA_VID, :path => item.path)
    end
    @validated = true
  end

  # Write a CSV report of the information contained in the validator's warnings.
  #
  # @param io [IO]  IO object to which the report should be written.
  def report(io = STDOUT)
    require 'csv'
    validate()
    report_data.each do |row|
      io.puts CSV.generate_line(row)
    end
  end

  # Returns a matrix of warning information.
  # Used when producing the CSV report.
  #
  # @!visibility private
  def report_data
    rc = DirValidator::Validator.report_columns
    data = [rc]
    @warnings.each do |w|
      cells = rc.map { |c| v = w.opts[c]; v.nil? ? '' : v }
      cells[0] = w.vid
      data.push(cells)
    end
    return data
  end

  # Column headings for the CSV report.
  #
  # @!visibility private
  def self.report_columns
    return [:vid, :got, :n, :base_dir, :name, :re, :pattern, :path]
  end

end
