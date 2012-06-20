class DirValidator::Validator

  attr_reader(:root_path, :catalog, :warnings)

  FILE_SEP = File::SEPARATOR

  def initialize(root_path)
    @root_path = root_path
    @catalog   = DirValidator::Catalog.new(self)
    @warnings  = []
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
    return process_items(@catalog.unmatched_dirs, vid, opts)
  end

  def files(vid, opts = {})
    return process_items(@catalog.unmatched_files, vid, opts)
  end

  def dir(vid, opts = {})
    opts = opts.merge({:n => '1'})
    return dirs(vid, opts)
  end

  def file(vid, opts = {})
    opts = opts.merge({:n => '1'})
    return files(vid, opts)
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
    add_warning(vid, "Expected #{quant.spec.inspect}, got #{sz}.") unless sz >= quant.min_n

    # Mark the Items as matched. This means that subsequent validations
    # will not return the same Items.
    items.each { |i| i.matched = true }

    return items
  end


  ####
  # Name-related filtering.
  ####

  def name_filtered(items, opts)
    # Filter the items to those in the base_dir.
    # If there is no base_dir, no filtering occurs.
    base_dir = normalized_base_dir(opts)
    sz       = base_dir.size
    items    = items.select { |i| i.path.start_with?(base_dir) } if sz > 0

    # Set the item.target values.
    # If there is no base_dir, the target is the same as item.path.
    items.each { |i| i.target = i.path[sz .. -1] }

    # Filter items to immediate children, unless user wants to recurse.
    items = items.reject { |i| i.target.include?(FILE_SEP) } unless opts[:recurse]

    # Return the items having targets matching the name regex.
    rgx = name_regex(opts)
    return items.select { |i| i.target_match(rgx) }
  end

  def normalized_base_dir(opts)
    bd = opts[:base_dir]
    return '' unless bd
    bd += FILE_SEP unless bd.end_with?(FILE_SEP)
    return bd
  end

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

  def name_to_re(name)
    return az_wrap(Regexp.quote(name))
  end

  def pattern_to_re(pattern)
    return az_wrap(Regexp.quote(pattern).gsub(/\\\*/, '.*').gsub(/\\\?/, '.'))
  end

  def az_wrap(s)
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

  def add_warning(vid, msg)
    @warnings << "#{vid}: #{msg}"
  end

  def report
    validate()
    @warnings.each { |w| puts w }
  end

  def validate
    warn_about_unmatched()
  end

  def warn_about_unmatched
    @catalog.unmatched_items.each do |item|
      add_warning('EXTRA', item.path)
    end
  end

end
