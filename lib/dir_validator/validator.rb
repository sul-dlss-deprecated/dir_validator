class DirValidator::Validator

  attr_reader(:root_path, :catalog, :warnings, :validated)

  FILE_SEP  = File::SEPARATOR
  EXTRA_VID = '_EXTRA_'

  def initialize(root_path)
    @root_path = root_path
    @catalog   = DirValidator::Catalog.new(self)
    @warnings  = []
    @validated = false
  end

  ####
  # Validations. The user creates validations using dirs(), files(),
  # dir(), and file(). All of these methods return an array of Item
  # objects from the catalog -- specifically, Item objects that:
  #
  #   (a) meet the user's criteria
  #   (b) have not been matched already by prior validations
  #
  # The call must supply a validation identifier (vid). This is just
  # a string (meaningful only to the user) that is used when generating
  # validation warnings.
  #
  # Validation criteria are supplied by a hash (opts). There are two
  # general types:
  #
  #   -- Name-related (:name, :pattern, and :re). These criteria
  #      affect whether a particular Item will be returned (i.e.,
  #      only if its name matches the criteria).
  #   -- Quantity assertions (:n). These control the max N of
  #      Items that will be returned. They also generate a warning
  #      if too few Items are found.
  #
  # Other attributes that can be supplied in the opts hash:
  #
  #   -- By default, :recurse is false, which means that all
  #      name-related criteria apply only to the contents of
  #      the immediate enclosing directory.
  #
  # The underlying work is done by process_items().
  ####

  def dirs(vid, opts = {})
    bd = normalized_base_dir(opts, :handle_recurse => true)
    return process_items(@catalog.unmatched_dirs(bd), vid, opts)
  end

  def files(vid, opts = {})
    bd = normalized_base_dir(opts, :handle_recurse => true)
    return process_items(@catalog.unmatched_files(bd), vid, opts)
  end

  def dir(vid, opts = {})
    opts = opts.merge({:n => '1'})
    return dirs(vid, opts).first
  end

  def file(vid, opts = {})
    opts = opts.merge({:n => '1'})
    return files(vid, opts).first
  end

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

  def name_filtered(items, opts)
    # Filter the items to those in the base_dir.
    # If there is no base_dir, no filtering occurs.
    base_dir = normalized_base_dir(opts, :add_file_sep => true)
    sz       = base_dir.size
    items    = items.select { |i| i.path.start_with?(base_dir) } if sz > 0

    # Set the item.target values.
    # If there is no base_dir, the target is the same as item.path.
    items.each { |i| i.set_target(i.path[sz .. -1]) }

    # Filter items to immediate children, unless user wants to recurse.
    items = items.reject { |i| i.target.include?(FILE_SEP) } unless opts[:recurse]

    # Return the items having targets matching the name regex.
    rgx = name_regex(opts)
    return items.select { |i| i.target_match(rgx) }
  end

  def normalized_base_dir(opts, nbd_opts = {})
    # Given some validation options, returns opts[:base_dir] in a normalized
    # form (with a trailing separator). Returns empty if the option is missing,
    # and returns nil when we need to handle the :recurse option.
    return nil if opts[:recurse] and nbd_opts[:handle_recurse]
    bd = opts[:base_dir]
    return '' unless bd
    bd.chop! while bd.end_with?(FILE_SEP)
    bd += FILE_SEP if nbd_opts[:add_file_sep]
    return bd
  end

  def name_regex(opts)
    # Given some validation options, returns the appropriate Regexp
    # based on the name-related criteria.
    name    = opts[:name]
    re      = opts[:re]
    pattern = opts[:pattern]
    return Regexp.new(
      name    ? name_to_re(name)       :
      pattern ? pattern_to_re(pattern) :
      re      ? re                     : ''
    )
  end

  def name_to_re(name)
    # Converts a string into a regex-ready string, wrapped in start- and end-
    # anchors and with all special characters quoted.
    return az_wrap(Regexp.quote(name))
  end

  def pattern_to_re(pattern)
    # Converts a quasi-glob pattern to a regex-ready string. Specifically, all
    # special regex chacters are quoted other than these:
    #     * becomes .*
    #     ? becomes .
    return az_wrap(Regexp.quote(pattern).gsub(/\\\*/, '.*').gsub(/\\\?/, '.'))
  end

  def az_wrap(s)
    # Returns a string wrapped in Regexp start-of-string and end-of-string anchors.
    return "\\A#{s}\\z"
  end


  ####
  # Quantity filtering.
  ####

  def quantity_limited(items, quant)
    return items[0 .. quant.max_index]
  end


  ####
  # Methods related validation warnings and reporting.
  ####

  def add_warning(vid, opts)
    @warnings << DirValidator::Warning.new(vid, opts)
  end

  def validate
    return if @validated  # Run only once.
    @catalog.unmatched_items.each do |item|
      add_warning(EXTRA_VID, :path => item.path)
    end
    @validated = true
  end

  def report(io = STDOUT)
    require 'csv'
    validate()
    report_data.each do |row|
      io.puts CSV.generate_line(row)
    end
  end

  def report_data
    data = [report_columns]
    @warnings.each do |w|
      cells = report_columns.map { |c| v = w.opts[c]; v.nil? ? '' : v }
      cells[0] = w.vid
      data.push(cells)
    end
    return data
  end

  def report_columns
    return [:vid, :got, :n, :base_dir, :name, :re, :pattern, :path]
  end

end
